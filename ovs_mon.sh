#!/bin/bash
#This script can monitor the OpenvSwitches by filtering useful rules from them.
#And the rules are re-formated for better observation.

[ $# -lt 1 ] && echo "[Usage] $0 switch#1 switch#2 ..." && exit

DUMP_CMD="sudo ovs-ofctl dump-flows"
priority=""
rule=""
result=""
new_line=""
tmp_file="/tmp/tmp_result.switch"

[ -f  $tmp_file ] ||touch $tmp_file

for arg in "$@"; do 
    echo "###"$arg
    result=""
    $DUMP_CMD $arg|sed -n '/actions=/p'|grep -v "n_packets=0" >$tmp_file
    while read line; do 
        pkt=`echo $line|cut -d ' ' -f 4| sed -e 's/n_packets/PKT/'| sed -e 's/,//'`
        priority_rule=`echo $line|cut -d ' ' -f 6| sed -e 's/priority=//'`
        if [ `expr match "$priority_rule" ".*,"` -ne 0 ]; then 
            priority=`echo $priority_rule|cut -d ',' -f 1| sed -e 's/,//'` 
            rule=`echo $priority_rule|cut -d ',' -f 2-`
        else
            priority=$priority_rule
            rule="all"
        fi
        action=`echo $line|cut -d ' ' -f 7| sed -e 's/actions/ACT/'`
        new_line=$priority"\t"$pkt"\t"$rule"\t"$action"\n"
        result=${result}${new_line}
    done < $tmp_file
    echo -e $result|sort -n -r | while read line; do 
    priority=`echo $line |cut -d " " -f 1`
    pkt=`echo $line|cut -d " " -f 2`
    rule=`echo $line|cut -d " " -f 3`
    action=`echo $line|cut -d " " -f 4`
    printf "%-8s %-8s %-60s %s\n" $priority $pkt $rule $action
    done
done
