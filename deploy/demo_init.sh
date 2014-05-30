#!/bin/sh
#Create a project and add a new user with net/subnet/vm/image...
#In the new created vm, you can try ping Internet.
#TODO: May assign a floating ip to the vm image.

[ ! -e header.sh ] && echo_r "Not found header file" && exit -1
. ./header.sh

## MAIN PROCESSING START ##

echo_b "Check the demo image..."
[ -f ${IMAGE_FILE} ] || wget ${IMAGE_URL}

echo_b "Create a demo tenant"
TENANT_ID=$(create_tenant "$TENANT_NAME" "$TENANT_DESC") && echo_g "tenant id = ${TENANT_ID}"

echo_b "Create a demo user and add it into the demo tenant..."
create_user "${USER_NAME}" "${USER_PWD}" "${TENANT_ID}" "${USER_EMAIL}"

echo_b "Create an internal net and subnet..."
create_net_subnet "${NET_INT_NAME}" "${SUBNET_INT_NAME}" "${INT_IP_CIDR}" "${INT_GATEWAY}"

SUBNET_INT_ID=$(get_subnetid_by_name "${SUBNET_INT_NAME}")

echo_b "Create an external net and subnet..."
[ -z "`neutron net-list|grep ${NET_EXT_NAME}`" ] && neutron net-create --tenant-id ${ADMIN_ID} ${NET_EXT_NAME} --router:external=True
[ -z "`neutron subnet-list|grep ${SUBNET_EXT_NAME}`" ] && neutron subnet-create --tenant-id ${ADMIN_ID} --name ${SUBNET_EXT_NAME} --allocation-pool start=${FLOAT_IP_START},end=${FLOAT_IP_END} --gateway ${EXT_GATEWAY} ${NET_EXT_NAME} ${EXT_IP_CIDR} --enable_dhcp=False
NET_EXT_ID=$(get_subnetid_by_name ${SUBNET_EXT_NAME})

echo_b "Create a router, add its interface to the internal subnet, and add the external gateway..."
ROUTER_ID=$(create_router "${ROUTER_NAME}" "${TENANT_ID}")
SUBNET_INT_ID=$(get_subnetid_by_name "$SUBNET_INT_NAME")
SUBNET_EXT_ID=$(get_subnetid_by_name "$SUBNET_EXT_NAME")
if [ -n "${ROUTER_ID}" -a -n "${SUBNET_INT_ID}" -a -n "${SUBNET_EXT_ID}" ]; then 
    [ -n "${ROUTER_ID}" -a -n "${SUBNET_INT_ID}" ] && neutron router-interface-add ${ROUTER_ID} ${SUBNET_INT_ID}
    [ -n "${ROUTER_ID}" -a -n "${SUBNET_EXT_ID}" ] && neutron router-gateway-set ${ROUTER_ID} ${NET_EXT_ID}
fi

echo_b "Add the image file into glance and create flavors..."
create_image ${IMAGE_NAME} ${IMAGE_FILE}

[ -z "`nova flavor-list|grep ex.tiny`" ] &&nova flavor-create --is-public true ex.tiny 10 512 2 1
[ -z "`nova flavor-list|grep ex.small`" ] && nova flavor-create --is-public true ex.small 11 512 20 1

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

echo_b "Add default secgroup rules of allowing ping and ssh..."
nova secgroup-add-rule default icmp -1 -1 0.0.0.0/0
nova secgroup-add-rule default tcp 22 22 0.0.0.0/0
nova secgroup-add-rule default tcp 80 80 0.0.0.0/0
nova secgroup-add-rule default tcp 443 443 0.0.0.0/0

#neutron floatingip-create ${NET_EXT_NAME}

echo_b "Booting a vm in the internal net..."
#sed -i 's/#libvirt_inject_password=false/libvirt_inject_password=true/g' /etc/nova/nova.conf
#ssh root@${COMPUTE_IP} "sed -i 's/#libvirt_inject_password=false/libvirt_inject_password=true/g' /etc/nova/nova.conf; /etc/init.d/openstack-nova-compute restart"
#sleep 1
IMAGE_ID=$(get_imageid_by_name "$IMAGE_NAME")
[ -n "$IMAGE_ID" ] && nova boot ${VM_NAME} --image ${IMAGE_ID} --flavor 10 --nic net-id=$(get_netid_by_name ${NET_INT_NAME})
sleep 2;

echo_g "<<<Done" && exit 0
