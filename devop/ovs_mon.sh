#!/bin/bash
#This script can monitor the OpenvSwitches by filtering useful rules from them.
#And the rules are re-formated for better observation.

[ $# -lt 1 ] && echo "[Usage] $0 switch#1 switch#2 ..." && exit

DUMP_FLOWS="sudo ovs-ofctl dump-flows"
SHOW_BR="sudo ovs-vsctl show"
tmp_file="/tmp/tmp_result.switch"

[ -f  $tmp_file ] || touch $tmp_file

for arg in "$@"; do 
    echo "###"$arg
    $SHOW_BR |grep -q $arg || echo "Non-Exist" && continue
    result=""
    $DUMP_FLOWS $arg|sed -n '/actions=/p'|grep -v "n_packets=0" >$tmp_file
    while read line; do 
        nf=`echo $line|grep -o " "|wc -l`
        pkt=`echo $line|cut -d ' ' -f 4| sed -e 's/n_packets/PKT/'| sed -e 's/,//'`
        pri_match=`echo $line|cut -d ' ' -f $nf|sed -e 's/_tci//'| sed -e 's/priority=//'`
        if [ `expr match "$pri_match" ".*,"` -ne 0 ]; then 
            priority=`echo $pri_match|cut -d ',' -f 1| sed -e 's/,//'` 
            match=`echo $pri_match|cut -d ',' -f 2-|sed -e 's/\(..:\)\1\{1,\}/\1:/g'|sed -e 's/0x\(0\)\1\{1,\},/0x0,/g'`
        else
            priority=$pri_match
            match="all"
        fi
        action=`echo $line|cut -d ' ' -f $((nf+1))| sed -e 's/actions/ACT/'`
        result=${result}$priority"\t"$pkt"\t"$match"\t"$action"\n"
    done < $tmp_file
    echo -e $result|sort -n -r | while read line; do 
        priority=`echo $line |cut -d " " -f 1`
        pkt=`echo $line|cut -d " " -f 2`
        match=`echo $line|cut -d " " -f 3`
        action=`echo $line|cut -d " " -f 4`
        printf "%-6s %-12s %-64s %s\n" $priority $pkt $rule $action
    done
done
