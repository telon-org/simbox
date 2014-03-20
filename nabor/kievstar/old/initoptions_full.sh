#!/bin/sh

. /usr/src/ast/config/config.sh


imsilist=`cat /var/log/asterisk/imsi.megafon`
#three="1 2 3"

#for one in $three
#do

for imsi in $imsilist
do
#status=`cat /var/log/asterisk/sim/$imsi.status`
#balance=`cat /var/log/asterisk/sim/$imsi.balance`
dongle=`cat /var/log/asterisk/sim/$imsi.dongle`
#status=`echo "$status-1+1" | bc`
#balance=`echo "$balance-1+1" | bc`
#echo "$dongle $imsi $status"
#if [ "90" -gt "$status" ] ; then
#if [ "$balance" -gt "0" ] ; then
#echo "$dongle $imsi status=$status balance=$balance"
/usr/sbin/asterisk -r -x "dongle ussd $dongle $init_options_ussd_megafon"
echo /usr/sbin/asterisk -r -x "dongle ussd $dongle $init_options_ussd_megafon"
#sleep 2
#fi
#fi

done


#echo "sleep 5"
#sleep 5
#done