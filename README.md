openstack-tool
==============

Some useful tools for openstack deployment, deployment and operation.


#Deploy

The deployment is suggested to utilize [RDO](openstack.redhat.com).

##Server configuration
* Managment   Network: `192.168.122.0/24`
* Data        Network: `10.0.0.0/24`
* Control Server: `10.0.0.100 (eth0)`, `192.168.122.100 (eth1)`
* Compute Server: `10.0.0.101 (eth0)`, `192.168.122.101 (eth1)`

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

##keystonerc_admin
A reference keystonrc of the admin role.

#Devop

##bashrc
A bashrc template. Please rename this to .bashrc, and put in your home directory.

##bash_aliases
Some useful aliases. Please rename this to .bash_aliases, and put in your home directory.

##bash_color
Will enable colorful bash if supported. Please rename this to .bash_color, and put in your home directory.

##ovs_mon
This script can monitor the OpenvSwitches by filtering useful rules from them.
The rules are re-formated for better observation. Just put it in your PATH such as /usr/local/bin/.

The original way to observe the rules in a switch (e.g., s1) is using ovs-ofctl, while it's hard to explore when there're lots of rules
```
$ sudo ovs-ofctl dump-flows s1
NXST_FLOW reply (xid=0x4):
 cookie=0x0, duration=294.454s, table=0, n_packets=0, n_bytes=0, priority=2400,dl_dst=ff:ff:ff:ff:ff:ff actions=CONTROLLER:65535
 cookie=0x0, duration=294.448s, table=0, n_packets=0, n_bytes=0, priority=801,ip actions=CONTROLLER:65535
 cookie=0x0, duration=294.456s, table=0, n_packets=0, n_bytes=0, priority=2400,arp actions=CONTROLLER:65535
 cookie=0x0, duration=294.455s, table=0, n_packets=4, n_bytes=280, priority=2400,dl_type=0x88cc actions=CONTROLLER:65535
 cookie=0x0, duration=197.693s, table=0, n_packets=0, n_bytes=0, priority=1000,vlan_tci=0x0000,dl_dst=00:00:00:00:00:01 actions=output:1
 cookie=0x0, duration=197.665s, table=0, n_packets=0, n_bytes=0, priority=1000,vlan_tci=0x0000,dl_dst=00:00:00:00:00:02 actions=output:1
 cookie=0x0, duration=294.461s, table=0, n_packets=0, n_bytes=0, priority=1700,ip,dl_dst=fc:3f:03:04:05:b8 actions=CONTROLLER:65535
 cookie=0x0, duration=294.448s, table=0, n_packets=0, n_bytes=0, priority=800 actions=drop
 cookie=0x0, duration=294.454s, table=0, n_packets=0, n_bytes=0, priority=2400,ip,nw_proto=2 actions=CONTROLLER:65535
```
Use ovs_mon, it is easy to watch multiple switches simultaneously, and only output 'useful' rules:
```
$ ovsm s1 s2 s3
###s1
2400     PKT=8    dl_type=0x88cc                                               ACT=CONTROLLER:65535
                                                                               
###s2
2400     PKT=5    dl_type=0x88cc                                               ACT=CONTROLLER:65535
2400     PKT=2    dl_dst=ff::ff                                                ACT=CONTROLLER:65535
2400     PKT=18   arp                                                          ACT=CONTROLLER:65535
1401     PKT=1    ip,dl_src=00::02,nw_src=10.0.0.2                             ACT=CONTROLLER:65535
1401     PKT=1    ip,dl_src=00::01,nw_src=10.0.0.1                             ACT=CONTROLLER:65535
                                                                               
###s3
2400     PKT=5    dl_type=0x88cc                                               ACT=CONTROLLER:65535
```
