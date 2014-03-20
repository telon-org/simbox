#!/bin/sh

imsilist=`cat /var/log/asterisk/imsi.beeline`

for imsi in $imsilist
do
status=`cat /var/log/asterisk/sim/$imsi.status`
balance=`cat /var/log/asterisk/sim/$imsi.balance`
dongle=`cat /var/log/asterisk/sim/$imsi.dongle`

status=`echo "$status-1+1" | bc`
balance=`echo "$balance-1+1" | bc`

echo "$dongle status=$status balance=$balance"

if [ "1" -gt "$status" ] ; then
echo "$dongle status=$status balance=$balance"
/usr/src/ast/scripts/system/makecall.sh $dongle 06747073
#sleep 2
echo ! /usr/sbin/asterisk -r -x "dongle setgroupi $imsi 10"
fi

done