#!/bin/sh

list=`cat /var/log/asterisk/imsi.beeline`

for imsi in $list
do
status=`cat /var/log/asterisk/sim/$imsi.status`
#optionstime=`cat /var/log/asterisk/sim/$imsi.status`

status=`echo "$status-1+1" | bc`

if [ "90" -gt "$status" ] ; then
#nowtime=`date +%s`
#difftime=`echo "$nowtime-$optionstime" | bc`
#if [ "$difftime" -gt 10800 ] ; then
    /usr/sbin/asterisk -r -x "dongle setgroupimsi $imsi 102"
#fi
fi

done

