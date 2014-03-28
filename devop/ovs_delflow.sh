#!/bin/bash
#This tool support specifically del a flow from ovs.
#The flow can be given with priority and actions, 
#e.g., "priority=100,ip actions=OUTPUT:1", or
#"priority=100 ip,nw_proto=2 actions=OUTPUT:2"

[ $# -lt 1 ] && echo "[Usage] $0 switch flow" && exit

DUMP_FLOWS="sudo ovs-ofctl dump-flows"
REPLACE_FLOWS="sudo ovs-ofctl replace-flows"
SHOW_BR="sudo ovs-vsctl show"

#printf "%6s \033[01;32m%-12s\033[0m \033[01;34m%-64s\033[0m \033[01;31m%s\033[0m\n" "PRI" "PKT" "MATCH" "ACTION"
#printf "\033[01;31m%6s %-12s %-64s %s\033[0m\n" "PRI" "PKT" "MATCH" "ACTION"

! $SHOW_BR|grep -q $1 && echo -e "$1 Non-Exist" && exit

flow_file="/tmp/tmp_switch_${1}_flows"
[ -f  $flow_file ] || touch $flow_file
>$flow_file

rule=$2
pri=""
match=""
action=""
if echo $rule|grep -q "priority="; then 
    pri=`expr "$rule" : '\(priority=[0-9]*[ ,]\)'|sed -e 's/,//'|sed -e 's/ //g'`
    rule=${rule#priority=[0-9]*[ ,]}
    #echo "priority: "$pri
    #echo "rule: "$rule
fi
if echo $rule|grep -q "actions="; then 
    action=`expr "$rule" : '.*\(actions=.*\)'`
    rule=${rule%actions=*}
    #echo "action: "$action
    #echo "rule: "$rule
fi

match=`echo $rule|sed -e 's/ //g'`
#echo "match: "$match

[ -z $match ] && echo "No match given" && exit

del_flow=$pri","$match" "$action

#echo "del_flow="$del_flow

! $DUMP_FLOWS $1|grep -q "$del_flow" && echo "Flow Non-Exist" && exit

$DUMP_FLOWS $1|grep "cookie="| while read line; do
    if echo $line |grep -q "$del_flow"; then
        echo "del-flow:"$line
    else
        echo $line >> $flow_file
    fi
done

$REPLACE_FLOWS $1 $flow_file
