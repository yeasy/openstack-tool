#!/bin/sh

[ $# -ne 1 ] && echo "Please give the openstack release name" && exit -1;
RELEASE=$1

echo "Recommend to run the ./rdo_purge.sh first, especially for alreay installed machines."
echo "Checking if the system is clean..."
[ `yum list installed |grep $RELEASE` ] && exit -1;

#This will add the rdo-release, puppetlabs and foreman yum source
#yum install -y http://rdo.fedorapeople.org/openstack/openstack-$RELEASE/rdo-release-$RELEASE.rpm  
yum install -y http://rdo.fedorapeople.org/rdo-release.rpm
yum update -y

#Install some packages, which current rdo might not install automatically
yum install -y cronie

service ntpd stop
ssh 192.168.122.101 "service ntpd stop"
ssh 192.168.122.102 "service ntpd stop"

yum install -y openstack-packstack

#yum --enablerepo=epel -y install nrpe nagios-plugins wget
#This will generate an answerfile template for allinone
#packstack --gen-answer-file packstack-answers-template.txt

#for vlan mode
packstack --answer-file $RELEASE/packstack-answers-vlan.txt || exit 1;

#for gre mode
#packstack --answer-file packstack-answers-gre.txt

#Run some manual config on the management network if RDO does not do that
ifconfig eth1 0.0.0.0
ifconfig br-ex 192.168.122.100/24

#suppose br-eth0 if the private vif
cat "TYPE=OVSPort" >>/etc/sysconfig/network-scripts/ifcfg-eth0
cat "OVSBOOTPROTO=none" >>/etc/sysconfig/network-scripts/ifcfg-eth0
cat "DEVICETYPE=ovs" >>/etc/sysconfig/network-scripts/ifcfg-eth0
cat "OVSBRIDGE=br-eth0" >>/etc/sysconfig/network-scripts/ifcfg-eth0
cat "IPV6INIT=no" >>/etc/sysconfig/network-scripts/ifcfg-eth0

#eth1 is the public vif
sed -i 's/^BOOTPROTO=static\|^NM_CONTROLLED=yes\|^IPADDR=\|^NETMASK=/d' /etc/sysconfig/network-scripts/ifcfg-eth1
cp -f $RELEASE/ifcfg-br-ex /etc/sysconfig/network-scripts/
ovs-vsctl --may-exist add-port br-ex eth1; service network restart
