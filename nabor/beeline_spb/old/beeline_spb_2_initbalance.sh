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

if [ "100" -gt "$status" ] ; then
if [ "1" -gt "$balance" ] ; then
echo "$dongle status=$status balance=$balance"
/usr/sbin/asterisk -r -x "dongle ussd $dongle *101*1111#"
#sleep 12
fi
fi

done