#!/bin/sh

echo "Recommend to run the ./clear_openstack.sh first, especially for alreay installed machines."

#This will add the rdo-release, puppetlabs and foreman yum source
yum install -y http://rdo.fedorapeople.org/openstack/openstack-havana/rdo-release-havana.rpm  

yum update -y

service ntpd stop
ssh 192.168.122.101 "service ntpd stop"

yum install -y openstack-packstack

yum --enablerepo=epel -y install nrpe nagios-plugins

#This will generate an answerfile template for allinone
#packstack --gen-answer-file packstack-answers-template.txt

#for vlan mode
packstack --answer-file packstack-answers-vlan.txt

#for gre mode
#packstack --answer-file packstack-answers-gre.txt
