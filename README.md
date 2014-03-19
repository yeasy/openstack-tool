openstack-tool
==============

Some useful tools for openstack deployment and usage, based on [RDO](openstack.redhat.com).

#Server configuration
* Managment   Network: `192.168.122.0/24`
* Data        Network: `10.0.0.0/24`
* Control Server: `10.0.0.100 (eth0)`, `192.168.122.100 (eth1)`
* Compute Server: `10.0.0.101 (eth0)`, `192.168.122.101 (eth1)`

#Document

##install_openstack.sh
Install openstack with RDO and the configuration file.

##init_openstack.sh
After the installation, init by adding a user and a project with net/subnet/vm.
Should get the [Cirros Image] (https://launchpad.net/cirros/trunk/0.3.0/+download/cirros-0.3.0-x86_64-disk.img) and put it under the directory.

##clear_openstack.sh  
Clear the machine which installs openstack.

##packstack-answers-gre
RDO configuration file for multinode, GRE based.

##packstack-answers-vlan
RDO configuration file for multinode, Vlan based.

##bashrc
A bashrc template. Please rename this to .bashrc, and put in your home directory.

##bash_aliases
Some useful aliases. Please rename this to .bash_aliases, and put in your home directory.

##keystonerc_admin
An example keystonrc of the admin role.
