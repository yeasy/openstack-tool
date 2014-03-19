#ssh login
alias so='ssh -X root@192.168.0.100'
alias sc='ssh -X root@192.168.0.101'

# common commands
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'
alias v='vim -O'
alias ping='ping -n'
alias pa='ps aux|grep'
alias supdate='sudo yum update'
alias prof="vi ~/.bash_profile"
alias nmap="nmap -sT "
alias src="source ~/.bashrc"

# Openstack related
alias novh='nova hypervisor-list'
alias novm='nova-manage service list'
alias vsh="sudo virsh list"
alias lsof6='lsof -P -iTCP -sTCP:LISTEN | grep 66'
alias vsh="sudo virsh list"
alias ns="sudo ip netns exec "
alias ipt="iptables --line-numbers -vnL"

# OVS Aliases
alias ovstart='sudo /usr/share/openvswitch/scripts/ovs-ctl start'
alias ovs='sudo ovs-vsctl show'
alias ovsd='sudo ovsdb-client dump'
alias ovdps='sudo ovs-dpctl show'
alias ovof='sudo ovs-ofctl '
alias logs="sudo journalctl -n 300 --no-pager"
alias ologs="tail -n 300 /var/log/openvswitch/ovs-vswitchd.log"
alias ovaps="sudo ovs-appctl fdb/show "
alias ovapd="sudo ovs-appctl bridge/dump-flows "
alias ovdpd=" sudo ovs-dpctl dump-flows "
alias ovtun="sudo ovs-ofctl dump-flows br-tun"
alias ovint="sudo ovs-ofctl dump-flows br-int"
alias dfl="sudo ovs-ofctl -O OpenFlow13 del-flows "
alias ovls="sudo ovs-ofctl -O OpenFlow13  dump-flows br-int"
alias ofport=" sudo ovs-ofctl -O OpenFlow13 dump-ports br-int"
alias del=" sudo ovs-ofctl -O OpenFlow13 del-flows "
alias ovdelm=" sudo ovs-vsctl del-manager"
alias ovaddm=" sudo ovs-vsctl set-manager tcp:172.16.58.1:6640"
