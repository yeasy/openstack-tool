#!/bin/sh

echo "Recommend to run the ./clear_openstack.sh first, especially for alreay installed machines."

yum install -y http://rdo.fedorapeople.org/openstack/openstack-havana/rdo-release-havana.rpm  
rpm -Uvh http://dl.fedoraproject.org/pub/epel/6/x86_64/epel-release-6-8.noarch.rpm
rpm -Uvh http://rpms.famillecollet.com/enterprise/remi-release-6.rpm
yum install -y openstack-packstack nagios nagios-plugins-all nagios-plugins-nrpe nrpe puppet

#Avoid the failure occured by mirrorlist sometimes
sed -i 's/^mirrorlist=https:\/\/mirrors.fedoraproject.org\/metalink?repo=epel-6&arch=$basearch/#mirrorlist=https:\/\/mirrors.fedoraproject.org\/metalink?repo=epel-6&arch=$basearch/g' /etc/yum.repos.d/epel.repo

service ntpd stop
ssh 192.168.122.101 "service ntpd stop"
ssh 192.168.122.101 "sed -i 's/^mirrorlist=https:\/\/mirrors.fedoraproject.org\/metalink?repo=epel-6&arch=$basearch/#mirrorlist=https:\/\/mirrors.fedoraproject.org\/metalink?repo=epel-6&arch=$basearch/g' /etc/yum.repos.d/epel.repo"

#for vlan mode
packstack --answer-file packstack-answers-vlan.txt

#for gre mode
#packstack --answer-file packstack-answers-gre.txt
