#!/bin/sh

echo "Recommend to run the ./clear_openstack.sh first, especially for alreay installed machines."

#This will add the rdo-release, puppetlabs and foreman yum source
yum install -y http://rdo.fedorapeople.org/openstack/openstack-havana/rdo-release-havana.rpm  

yum update -y
yum install -y openstack-packstack

#Avoid the failure occured by mirrorlist sometimes
sed -i 's/^mirrorlist=https:\/\/mirrors.fedoraproject.org\/metalink?repo=epel-6&arch=$basearch/#mirrorlist=https:\/\/mirrors.fedoraproject.org\/metalink?repo=epel-6&arch=$basearch/g' /etc/yum.repos.d/epel.repo

service ntpd stop
ssh 192.168.122.101 "service ntpd stop"
ssh 192.168.122.101 "sed -i 's/^mirrorlist=https:\/\/mirrors.fedoraproject.org\/metalink?repo=epel-6&arch=$basearch/#mirrorlist=https:\/\/mirrors.fedoraproject.org\/metalink?repo=epel-6&arch=$basearch/g' /etc/yum.repos.d/epel.repo"


#This will generate an answerfile template for allinone
#packstack --gen-answer-file packstack-answers-template.txt

#for vlan mode
packstack --answer-file packstack-answers-vlan.txt

#for gre mode
#packstack --answer-file packstack-answers-gre.txt
