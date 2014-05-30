#!/bin/sh
#Clear the vms, nets, routers, tenants, etc. created by demo_init.sh
#In theory, the script is safe to be executed repeatedly.

[ ! -e header.sh ] && echo_r "Not found header file" && exit -1
. ./header.sh

## MAIN PROCESSING START ##

export OS_TENANT_NAME=${TENANT_NAME}
export OS_USERNAME=${USER_NAME}
export OS_PASSWORD=${USER_PWD}

echo_b "Remove security rules and security group..."
nova secgroup-delete-rule default icmp -1 -1 0.0.0.0/0
nova secgroup-delete-rule default tcp 22 22 0.0.0.0/0
nova secgroup-delete-rule default tcp 80 80 0.0.0.0/0
nova secgroup-delete-rule default tcp 443 443 0.0.0.0/0
#nova secgroup-delete default

echo_b "Terminate the demo vm..."
delete_vm ${VM_NAME}

source ${RELEASE}/keystonerc_admin

echo_b "Clear the demo image from glance and the flavor..."
delete_image ${IMAGE_NAME}
[ -n "`nova flavor-list|grep ex.tiny`" ] && nova flavor-delete ex.tiny
[ -n "`nova flavor-list|grep ex.small`" ] && nova flavor-delete ex.small

echo_b "Clear the demo router and its interfaces..."
ROUTER_ID=`neutron router-list|grep ${ROUTER_NAME}|awk '{print $2}'`
SUBNET_INT_ID=$(get_subnetid_by_name ${SUBNET_INT_NAME})
SUBNET_EXT_ID=$(get_subnetid_by_name ${SUBNET_EXT_NAME})
if [ -n "${ROUTER_ID}" -a -n "${SUBNET_INT_ID}" -a -n "${SUBNET_EXT_ID}" ]; then 
    echo_g "Clearing its gateway from the ${SUBNET_EXT_NAME}..."
    [ -n "${NET_EXT_ID}" ] && neutron router-gateway-clear ${ROUTER_ID} ${NET_EXT_ID}
    echo_g "Deleting its interface from the ${SUBNET_INT_NAME}..."
    neutron router-interface-delete ${ROUTER_ID} ${SUBNET_INT_ID}
    neutron router-delete ${ROUTER_ID}
fi

echo_b "Clear the demo external subnet and net..."
delete_net_subnet ${NET_EXT_NAME} ${SUBNET_EXT_NAME}

echo_b "Clear the demo internal subnet and net..."
delete_net_subnet ${NET_INT_NAME} ${SUBNET_INT_NAME}

echo_b "Clear the demo user..."
delete_user ${USER_NAME}

echo_b "Clear the demo project..."
delete_tenant ${TENANT_NAME}

echo_b "Clean all generated network namespace"
for name in `ip netns show`  
do   
    [[ $name == qdhcp-* || $name == qrouter-* ]] &&  ip netns del $name
done

unset OS_TENANT_NAME
unset OS_USERNAME
unset OS_PASSWORD
unset OS_AUTH_URL
echo_g "<<<Done" && exit 0
