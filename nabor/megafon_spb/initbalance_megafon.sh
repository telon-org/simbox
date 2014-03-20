#!/bin/sh

exit


. /usr/src/ast/config/config.sh

imsilist=`cat /var/log/asterisk/imsi.megafon`

for imsi in $imsilist
do
dongle=`cat /var/log/asterisk/sim/$imsi.dongle`
status=`cat /var/log/asterisk/sim/$imsi.status`
balance=`cat /var/log/asterisk/sim/$imsi.balance`

status=`echo "$status-1+1" | bc`
balance=`echo "$balance-1+1" | bc`

echo $balance
if [ "100" -gt "$status" ] ; then
if [ "1" -gt "$balance" ] ; then
if [ "$balance" -gt "-1" ] ; then
echo "$dongle status=$status balance=$balance"
/usr/sbin/asterisk -r -x "dongle ussd $dongle $init_balance_ussd_megafon"
echo /usr/sbin/asterisk -r -x "dongle ussd $dongle $init_balance_ussd_megafon"
#sleep 1

fi
fi
fi

done