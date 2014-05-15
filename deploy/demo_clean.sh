#!/bin/sh
#Clear the vms, nets, routers, tenants, etc. created by demo_init.sh
#In theory, the script is safe to be executed repeatedly.

## THOSE VARIABLES CAN BE CUSTOMIZED. ##

# Environment information
CONTROL_IP=192.168.122.100
export OS_AUTH_URL=http://${CONTROL_IP}:35357/v2.0/

# The tenant, user, net, etc... to be created
TENANT_NAME="project_one"
USER_NAME="user"
USER_PWD="user"
INT_NET_NAME="net_int"
INT_SUBNET_NAME="subnet_int"
EXT_NET_NAME="net_ext"
EXT_SUBNET_NAME="subnet_ext"
ROUTER_NAME="router"
IMAGE_NAME="cirros-0.3.0-x86_64"
VM_NAME="cirros"

## DO NOT MODIFY THE FOLLOWING PART, UNLESS YOU KNOW WHAT IT MEANS. ##

echo "Remove security rules and security group..."
export OS_TENANT_NAME=${TENANT_NAME}
export OS_USERNAME=${USER_NAME}
export OS_PASSWORD=${USER_PWD}
nova secgroup-delete-rule default icmp -1 -1 0.0.0.0/0
nova secgroup-delete-rule default tcp 22 22 0.0.0.0/0
#nova secgroup-delete default

echo "Terminate the booted vms..."
if [ -n "`nova list|grep ${VM_NAME}`" ]; then
    VM_ID=`nova list|grep ${VM_NAME}|awk '{print $2}'`
    nova delete ${VM_ID}
    sleep 3;
fi

export OS_TENANT_NAME=admin
export OS_USERNAME=admin
export OS_PASSWORD=admin

echo "Clear the image from glance and the flavor..."
if [ -n "`nova image-list|grep ${IMAGE_NAME}`" ]; then
    IMAGE_ID=`nova image-list|grep ${IMAGE_NAME}|awk '{print $2}'`
    glance -f image-delete ${IMAGE_ID}
    sleep 2;
fi
[ -n "`nova flavor-list|grep ex.tiny`" ] && nova flavor-delete ex.tiny
[ -n "`nova flavor-list|grep ex.small`" ] && nova flavor-delete ex.small

echo "Clear the router and its interfaces..."
if [ -n "`neutron router-list|grep ${ROUTER_NAME}`" ]; then
    ROUTER_ID=`neutron router-list|grep ${ROUTER_NAME}|awk '{print $2}'`
    INT_SUBNET_ID=`neutron subnet-list|grep ${INT_SUBNET_NAME}|awk '{print $2}'`
    #clear router's external gateway at the external net
    [ -n "${EXT_NET_ID}" ] && neutron router-gateway-clear ${ROUTER_ID} ${EXT_NET_ID}
    [ -n "${INT_SUBNET_ID}" ] && neutron router-interface-delete ${ROUTER_ID} ${INT_SUBNET_ID}
    neutron router-delete ${ROUTER_ID}
fi

echo "Clear the external subnet and net..."
if [ -n "`neutron subnet-list|grep ${EXT_SUBNET_NAME}`" ]; then 
    EXT_SUBNET_ID=`neutron subnet-list|grep ${EXT_SUBNET_NAME}|awk '{print $2}'`
    neutron subnet-delete ${EXT_SUBNET_ID}
fi
if [ -n "`neutron net-list|grep ${EXT_NET_NAME}`" ]; then
    EXT_NET_ID=`neutron net-list|grep ${EXT_NET_NAME}|awk '{print $2}'`
    neutron net-delete ${EXT_NET_ID}
fi

echo "Clear the internal subnet and net..."
if [ -n "`neutron subnet-list|grep ${INT_SUBNET_NAME}`" ]; then 
    INT_SUBNET_ID=`neutron subnet-list|grep ${INT_SUBNET_NAME}|awk '{print $2}'`
    neutron subnet-delete ${INT_SUBNET_ID}
fi
if [ -n "`neutron net-list|grep ${INT_NET_NAME}`" ]; then 
    INT_NET_ID=`neutron net-list|grep ${INT_NET_NAME}|awk '{print $2}'`
    neutron net-delete ${INT_NET_ID}
fi

echo "Clear the added user..."
if [ -n "`keystone user-list|grep ${USER_NAME}`" ]; then 
    USER_ID=`keystone user-list|grep ${USER_NAME}|awk '{print $2}'`
    keystone user-delete ${USER_ID}
fi

echo "Clear the created project..."
if [ -n "`keystone tenant-list|grep ${TENANT_NAME}`" ]; then 
    TENANT_ID=`keystone tenant-list|grep ${TENANT_NAME}|awk '{print $2}'`
    keystone tenant-delete ${TENANT_ID}
fi

echo "Done"
