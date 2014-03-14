if [ -f /etc/bash_completion ] && ! shopt -oq posix; then
    . /etc/bash_completion
fi

# Openstack Aliases
alias novh='nova hypervisor-list'
alias novm='nova-manage service list'
alias vsh="sudo virsh list"
alias prof="vi ~/.bash_profile"
alias nmap="nmap -sT "
alias src="source ~/.bashrc"
alias lsof6='lsof -P -iTCP -sTCP:LISTEN | grep 66'
alias vsh="sudo virsh list"
alias ns="sudo ip netns exec "

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

#variables
export OS_USERNAME=admin
export OS_PASSWORD=admin
export OS_TENANT_NAME=admin
export OS_AUTH_URL=http://192.168.122.100:5000/v2.0
