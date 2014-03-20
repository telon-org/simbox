#!/bin/sh



numlist=`cat /var/log/asterisk/sms.txt.tmp | grep "Все включено" | grep -o -R "dongle[0-9]*:[0-9]*:[0-9]*."  | sed 's/\./,/g'`

for num in $numlist
do
echo $num
dongle=`echo "$num" | grep -o -R "dongle[0-9]*"`
imsi=`echo "$num" | grep -o -R ":[0-9]*:" | sed 's/://g'`
#number=`echo "$num" | grep -o -R ":[0-9\-]*," | sed 's/://g' | sed 's/,//g'`
#number=`echo "7$number"`
#if [ $number -ne "7" ] ; then
#
echo "$dongle>$imsi>$number"
echo "Все включено" > /var/simbox/sim/settings/$imsi.tarif
#/usr/sbin/asterisk -r -x "dongle setgroupimsi $imsi 335"
#echo "$number" > /var/simbox/sim/settings/$imsi.number
#fi

done


numlist=`cat /var/log/asterisk/ussd.txt.tmp | grep "Все включено" | grep -o -R "dongle[0-9]*:[0-9]*:[0-9]*."  | sed 's/\./,/g'`

for num in $numlist
do
echo $num
dongle=`echo "$num" | grep -o -R "dongle[0-9]*"`
imsi=`echo "$num" | grep -o -R ":[0-9]*:" | sed 's/://g'`
#number=`echo "$num" | grep -o -R ":[0-9\-]*," | sed 's/://g' | sed 's/,//g'`
#number=`echo "7$number"`
#if [ $number -ne "7" ] ; then
#
echo "$dongle>$imsi>$number"
echo "Все включено" > /var/simbox/sim/settings/$imsi.tarif
#/usr/sbin/asterisk -r -x "dongle setgroupimsi $imsi 335"
#echo "$number" > /var/simbox/sim/settings/$imsi.number
#fi

done