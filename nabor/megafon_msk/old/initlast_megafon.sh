#!/bin/sh

. /usr/src/ast/config/config.sh

list=`cat /var/log/asterisk/imsi.list`

for imsi in $list
do
status=`cat /var/log/asterisk/sim/$imsi.status`
optionstime=`cat /var/log/asterisk/sim/$imsi.optionstime`

status=`echo "$status-1+1" | bc`
optionstime=`echo "$optionstime-1+1" | bc`

if [ "$optionstime" -gt "0" ] ; then
if [ "90" -eq "$status" ] ; then
nowtime=`date +%s`
difftime=`echo "$nowtime-$optionstime" | bc`
if [ "$difftime" -gt "$wait_options_megafon" ] ; then
    echo "$imsi $difftime"
    /usr/sbin/asterisk -r -x "dongle setgroupimsi $imsi $activegroup_megafon"
fi
fi
fi

done

