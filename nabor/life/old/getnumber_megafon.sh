#!/bin/sh

imsilist=`cat /var/log/asterisk/imsi.megafon`

for imsi in $imsilist
do

number=`cat /var/log/asterisk/sim/$imsi.number`
dongle=`cat /var/log/asterisk/sim/$imsi.dongle`

number=`echo "$number-1+1" | bc`
if [ "$number" -eq "0" ] ; then
    echo "no number for $imsi $dongle"
    /usr/sbin/asterisk -r -x "dongle ussd $dongle *105*00#"
#    sleep 2
fi

done

