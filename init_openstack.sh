#!/bin/sh
#Create a project and add a new user with net/subnet/vm image...

#Those variables can be customized.
CONTROL_IP=192.168.122.100
COMPUTE_IP=192.168.122.101
TENANT_NAME="project_one"
TENANT_DESC="The first project"
USER_NAME="user"
USER_PWD="user"
USER_EMAIL="user@domain.com"
USER_ROLE="Member"
INT_NET_NAME="net_int"
INT_SUBNET_NAME="subnet_int"
EXT_NET_NAME="net_ext"
EXT_SUBNET_NAME="subnet_ext"
ROUTER_NAME="router"
INT_IP_CIDR="192.168.0.0/24"
FLOAT_IP_START="192.168.122.200"
FLOAT_IP_END="192.168.122.254"
EXT_GATEWAY="192.168.122.1"
EXT_IP_CIDR="192.168.122.0/24"
IMAGE_NAME="cirros-0.3.0-x86_64"
IMAGE_FILE=cirros-0.3.0-x86_64-disk.img
VM_NAME="cirros"
#source keystonerc_admin
export OS_AUTH_URL=http://${CONTROL_IP}:35357/v2.0/
export OS_TENANT_NAME=admin
export OS_USERNAME=admin
export OS_PASSWORD=admin


## DO NOT MODIFY THE FOLLOWING PART, UNLESS YOU KNOW WHAT IT MEANS. ##

#create a new project
keystone tenant-create --name ${TENANT_NAME} --description ${TENANT_DESC}
TENANT_ID=`keystone tenant-list|grep ${TENANT_NAME}|awk '{print $2}'`

#create a new user and add it into the project
keystone user-create --name ${USER_NAME} --pass ${USER_PWD} --tenant-id ${TENANT_ID} --email ${USER_EMAIL}
USER_ID=`keystone user-list|grep ${USER_NAME}|awk '{print $2}'`
ROLE_ID=`keystone role-list|grep ${USER_ROLE}|awk '{print $2}'`
keystone user-role-add --tenant-id ${TENANT_ID}  --user-id ${USER_ID} --role-id ${ROLE_ID}

#create a new internal net and subnet
neutron net-create --tenant-id ${TENANT_ID} ${INT_NET_NAME}
neutron subnet-create --tenant-id ${TENANT_ID} --name ${INT_SUBNET_NAME} ${INT_NET_NAME} ${INT_IP_CIDR} --dns_nameservers list=true 8.8.8.7 8.8.8.8

#create a router and add it to the subnet
neutron router-create --tenant-id ${TENANT_ID} ${ROUTER_NAME}
SUBNET_ID=`neutron subnet-list|grep ${INT_SUBNET_NAME}|awk '{print $2}'`
ROUTER_ID=`neutron router-list|grep ${ROUTER_NAME}|awk '{print $2}'`
neutron router-interface-add ${ROUTER_ID} ${SUBNET_ID}

#create a new external net and subnet
ADMIN_ID=`keystone tenant-list|grep admin|awk '{print $2}'`
neutron net-create --tenant-id ${ADMIN_ID} ${EXT_NET_NAME} --router:external=True
neutron subnet-create --tenant-id ${ADMIN_ID} --name ${EXT_SUBNET_NAME} --allocation-pool start=${FLOAT_IP_START},end=${FLOAT_IP_END} --gateway ${EXT_GATEWAY} ${EXT_NET_NAME} ${EXT_IP_CIDR} --enable_dhcp=False

#add router's external gateway
EXT_NET_ID=`neutron net-list|grep ${EXT_NET_NAME}|awk '{print $2}'`
neutron router-gateway-set ${ROUTER_ID} ${EXT_NET_ID}

#upload a vm image
if [ -f ${IMAGE_FILE} ]; then
    glance add disk_format=qcow2 container_format=ovf name=${IMAGE_NAME} is_public=true < ${IMAGE_FILE} 
    IMAGE_ID=`nova image-list|grep ${IMAGE_NAME}|awk '{print $2}'`
fi
nova flavor-create --is-public true ex.tiny 10 1024 1 1

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
nova secgroup-add-rule default icmp -1 -1 0.0.0.0/0
nova secgroup-add-rule default tcp 22 22 0.0.0.0/0

#neutron floatingip-create ${EXT_NET_NAME}

sed -i 's/#libvirt_inject_password=false/libvirt_inject_password=true/g' /etc/nova/nova.conf
ssh root@${COMPUTE_IP} "sed -i 's/#libvirt_inject_password=false/libvirt_inject_password=true/g' /etc/nova/nova.conf; /etc/init.d/openstack-nova-compute restart"
exit

nova boot --image ${IMAGE_ID} --flavor 10 ${VM_NAME}
sleep 5;
VM_PORT_ID=`neutron port-list|grep ${SUBNET_ID}|awk '{print $2}'`
