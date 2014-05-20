#!/bin/sh
#Create a project and add a new user with net/subnet/vm/image...
#In the new created vm, you can try ping Internet.
#TODO: May assign a floating ip to the vm image.

[ $# -ne 1 ] && echo "Please give the openstack release name" && exit -1;
RELEASE=$1

## THOSE VARIABLES CAN BE CUSTOMIZED. ##

# Environment information
CONTROL_IP=192.168.122.100
COMPUTE_IP=192.168.122.101
source $RELEASE/keystonerc_admin
#export OS_AUTH_URL=http://${CONTROL_IP}:35357/v2.0/
#export OS_TENANT_NAME=admin
#export OS_USERNAME=admin
#export OS_PASSWORD=admin
ADMIN_NAME=admin
ADMIN_ID=`keystone tenant-list|grep ${ADMIN_NAME}|awk '{print $2}'`

# The tenant, user, net, etc... to be created
TENANT_NAME="project_one"
TENANT_DESC="The first project"
USER_NAME="user"
USER_PWD="user"
USER_EMAIL="user@domain.com"
USER_ROLE="_member_"
USER_ROLE2="Member"
INT_NET_NAME="net_int"
INT_SUBNET_NAME="subnet_int"
EXT_NET_NAME="net_ext"
EXT_SUBNET_NAME="subnet_ext"
ROUTER_NAME="router"
INT_IP_CIDR="192.168.0.0/24"
INT_GATEWAY="192.168.0.1"
FLOAT_IP_START="192.168.122.200"
FLOAT_IP_END="192.168.122.254"
EXT_GATEWAY="192.168.122.1"
EXT_IP_CIDR="192.168.122.0/24"
IMAGE_NAME="cirros-0.3.0-x86_64"
IMAGE_FILE=cirros-0.3.0-x86_64-disk.img
IMAGE_URL=https://launchpad.net/cirros/trunk/0.3.0/+download/cirros-0.3.0-x86_64-disk.img
#if not existed will download from ${IMAGE_URL}
VM_NAME="cirros"

## DO NOT MODIFY THE FOLLOWING PART, UNLESS YOU KNOW WHAT IT MEANS. ##

echo "Check the demo image..."
[ -f ${IMAGE_FILE} ] || wget ${IMAGE_URL}

echo "Create a demo tenant"
[ -z "`keystone tenant-list|grep ${TENANT_NAME}`" ] && keystone tenant-create --name ${TENANT_NAME} --description "${TENANT_DESC}"
TENANT_ID=`keystone tenant-list|grep ${TENANT_NAME}|awk '{print $2}'`

echo "Create a demo user and add it into the demo tenant..."
[ -z "`keystone user-list|grep ${USER_NAME}`" ] && keystone user-create --name ${USER_NAME} --pass ${USER_PWD} --tenant-id ${TENANT_ID} --email ${USER_EMAIL}
USER_ID=`keystone user-list|grep ${USER_NAME}|awk '{print $2}'`
if [ -n "`keystone role-list|grep ${USER_ROLE}`" ]; then
    ROLE_ID=`keystone role-list|grep ${USER_ROLE}|awk '{print $2}'`
elif [ -n "`keystone role-list|grep ${USER_ROLE2}`" ]; then
    ROLE_ID=`keystone role-list|grep ${USER_ROLE2}|awk '{print $2}'`
else
    echo "No role is found"
    exit -1;
fi
[ -z "`keystone user-role-list --tenant-id ${TENANT_ID} --user-id ${USER_ID}|grep ${ROLE_ID}`" ] && keystone user-role-add --tenant-id ${TENANT_ID} --user-id ${USER_ID} --role-id ${ROLE_ID}

echo "Create an internal net and subnet..."
[ -z "`neutron net-list|grep ${INT_NET_NAME}`" ] && neutron net-create --tenant-id ${TENANT_ID} ${INT_NET_NAME}
INT_NET_ID=`neutron net-list|grep ${INT_NET_NAME}|awk '{print $2}'`
[ -z "`neutron subnet-list|grep ${INT_SUBNET_NAME}`" ] && neutron subnet-create --tenant-id ${TENANT_ID} --name ${INT_SUBNET_NAME} ${INT_NET_NAME} ${INT_IP_CIDR} --gateway ${INT_GATEWAY} --dns_nameservers list=true 8.8.8.7 8.8.8.8
INT_SUBNET_ID=`neutron subnet-list|grep ${INT_SUBNET_NAME}|awk '{print $2}'`

echo "Create an external net and subnet..."
[ -z "`neutron net-list|grep ${EXT_NET_NAME}`" ] && neutron net-create --tenant-id ${ADMIN_ID} ${EXT_NET_NAME} --router:external=True
[ -z "`neutron subnet-list|grep ${EXT_SUBNET_NAME}`" ] && neutron subnet-create --tenant-id ${ADMIN_ID} --name ${EXT_SUBNET_NAME} --allocation-pool start=${FLOAT_IP_START},end=${FLOAT_IP_END} --gateway ${EXT_GATEWAY} ${EXT_NET_NAME} ${EXT_IP_CIDR} --enable_dhcp=False
EXT_NET_ID=`neutron net-list|grep ${EXT_NET_NAME}|awk '{print $2}'`

echo "Create a router, add its interface to the internal subnet, and add the external gateway..."
[ -z "`neutron router-list|grep ${ROUTER_NAME}`" ] && neutron router-create --tenant-id ${TENANT_ID} ${ROUTER_NAME}
ROUTER_ID=`neutron router-list|grep ${ROUTER_NAME}|awk '{print $2}'`
#neutron router-interface-delete ${ROUTER_ID} ${INT_SUBNET_ID}
neutron router-interface-add ${ROUTER_ID} ${INT_SUBNET_ID}
#neutron router-gateway-clear ${ROUTER_ID} ${EXT_NET_ID}
neutron router-gateway-set ${ROUTER_ID} ${EXT_NET_ID}

echo "Add the image file into glance and create flavors..."
if [ -f ${IMAGE_FILE} ]; then
    glance image-create --disk-format qcow2 --container-format ovf --name ${IMAGE_NAME} --is-public True --file ${IMAGE_FILE} --progress
    IMAGE_ID=`nova image-list|grep ${IMAGE_NAME}|awk '{print $2}'`
fi
nova flavor-create --is-public true ex.tiny 10 512 2 1
nova flavor-create --is-public true ex.small 11 512 20 1

#if in GRE, then open this to reduce the MTU to improve throughput
#if [ ! -f /etc/neutron/dnsmasq-neutron.conf ]; then
#    echo "dhcp-option-force=26,1454" >  /etc/neutron/dnsmasq-neutron.conf
#fi
#sed -i 's/# dnsmasq_config_file =/dnsmasq_config_file = /etc/neutron/dnsmasq-neutron.conf/g' /etc/neutron/dhcp_agent.ini
#service neutron-dhcp-agent restart

#change to user and add security rules, then start a vm
export OS_TENANT_NAME=${TENANT_NAME}
export OS_USERNAME=${USER_NAME}
export OS_PASSWORD=${USER_PWD}

echo "Add default secgroup rules of allowing ping and ssh..."
nova secgroup-add-rule default icmp -1 -1 0.0.0.0/0
nova secgroup-add-rule default tcp 22 22 0.0.0.0/0

#neutron floatingip-create ${EXT_NET_NAME}

echo "Boot a vm in the internal net..."
sed -i 's/#libvirt_inject_password=false/libvirt_inject_password=true/g' /etc/nova/nova.conf
ssh root@${COMPUTE_IP} "sed -i 's/#libvirt_inject_password=false/libvirt_inject_password=true/g' /etc/nova/nova.conf; /etc/init.d/openstack-nova-compute restart"
sleep 1
nova boot ${VM_NAME} --image ${IMAGE_ID} --flavor 10 --nic net-id=${INT_NET_ID}
sleep 2;

echo "Done"
exit
VM_PORT_ID=`neutron port-list|grep ${INT_SUBNET_ID}|awk '{print $2}'`
