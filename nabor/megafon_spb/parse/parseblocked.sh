#!/bin/sh



#numlist=`cat /var/log/asterisk/sms1 | grep "Ваш номер временно заблокирован" | grep -o -R "dongle[0-9]*:[0-9]*:[0-9]*."  | sed 's/\./,/g'`
numlist=`cat /var/log/asterisk/sms.txt.tmp | grep "Недостаточно средств на счете для совершения вызова" | grep -o -R "dongle[0-9]*:[0-9]*:[0-9]*."  | sed 's/\./,/g'`
#numlist=`cat /var/log/asterisk/sms.txt.tmp | grep "Ваш номер временно заблокирован" |g' | grep -o -R "dongle[0-9]*:[0-9]*:[0-9]*."  | sed 's/\./,/g'`

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
/usr/sbin/asterisk -r -x "dongle setgroupimsi $imsi 335"
#echo "$number" > /var/simbox/sim/settings/$imsi.number
#fi

done