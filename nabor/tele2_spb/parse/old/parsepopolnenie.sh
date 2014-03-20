#!/bin/sh


#cat /var/log/asterisk/ussd2 | grep -o -R "dongle[0-9]*:[0-9]*: Баланс:[0-9\-][0-9\-]*"

#cat /var/log/asterisk/ussd2 | grep -o -R "dongle[0-9]*:[0-9]*: Баланс [0-9\-][0-9\-]*" | sed 's/: Баланс /:/g' > /var/log/asterisk/balance
#cat /var/log/asterisk/ussd.txt.tmp | grep -o -R "dongle[0-9]*:[0-9]*: Баланс:[0-9\-][0-9\-]*" | sed 's/: Баланс:/:/g' > /var/log/asterisk/balance


cat /var/log/asterisk/ussd.txt.tmp | grep -o -R "dongle[0-9]*:[0-9]*: - 4B23##A230: BHECEHA CYMMA [0-9]*" | sed 's/: - 4B23##A230: BHECEHA CYMMA/:/g' > /var/log/asterisk/balance

list=`cat /var/log/asterisk/balance`

for bal in $list
do
dongle=`echo "$bal" | grep -o -R "dongle[0-9]*"`
imsi=`echo "$bal" | grep -o -R ":[0-9]*:" | sed 's/://g'`
balance_plus=`echo "$bal;" | grep -o -R ":[0-9\-]*;" | sed 's/://g' | sed 's/;//g'`

echo "$dongle>$imsi>$balance_plus"

if [ $balance_plus -gt "70" ] ; then 
group=`cat /var/svistok/sim/settings/$imsi.group`
if [ $qroup -eq "210" ] ; then 

echo "777" > /var/simbox/sim/state/$imsi.balance
/usr/sbin/asterisk -rx "dongle setgroupimsi $imsi 109"

fi
fi


done


