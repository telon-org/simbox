#!/bin/sh


. /usr/src/ast/config/config.sh

imsilist=`cat /var/log/asterisk/imsi.list`

for imsi in $imsilist
do
indone=`cat /var/log/asterisk/sim/$imsi.indone`
outdone=`cat /var/log/asterisk/sim/$imsi.outdone`


status=`cat /var/log/asterisk/sim/$imsi.status`

#balance=`cat /var/log/asterisk/sim/$imsi.balance`
#dongle=`cat /var/log/asterisk/sim/$imsi.dongle`
#number=`cat /var/log/asterisk/sim/$imsi.number`
#state=`cat /var/log/asterisk/sim/$imsi.state`
#lastinc=`cat /var/log/asterisk/sim/$imsi.lastinc`
#secondstotal=`cat /var/log/asterisk/sim/$imsi.stat_calls_duration`
#balance=`echo "$balance-1+1" | bc`
#number=`echo "$number-1+1" | bc`

status=`echo "$status-1+1" | bc`
indone=`echo "$indone-1+1" | bc`
outdone=`echo "$outdone-1+1" | bc`


if [ "$status" -eq "142" ] ; then
if [ "$indone" -eq "1" ] ; then
echo "status was $status"
rm /var/log/asterisk/sim/$imsi.indone
rm /var/log/asterisk/sim/$imsi.datt
$ASTERISK -r -x "dongle setgroupimsi $imsi 102"
fi
fi


if [ "$status" -eq "143" ] ; then
if [ "$indone" -eq "1" ] ; then
echo "status was $status"
rm /var/log/asterisk/sim/$imsi.indone
rm /var/log/asterisk/sim/$imsi.datt
$ASTERISK -r -x "dongle setgroupimsi $imsi 103"
fi
fi


if [ "$status" -eq "152" ] ; then
if [ "$outdone" -eq "1" ] ; then
echo "status was $status"
rm /var/log/asterisk/sim/$imsi.outdone
rm /var/log/asterisk/sim/$imsi.datt
$ASTERISK -r -x "dongle setgroupimsi $imsi 102"
fi
fi

if [ "$status" -eq "153" ] ; then
if [ "$outdone" -eq "1" ] ; then
echo "status was $status"
rm /var/log/asterisk/sim/$imsi.outdone
rm /var/log/asterisk/sim/$imsi.datt
$ASTERISK -r -x "dongle setgroupimsi $imsi 103"
fi
fi




done