#!/bin/sh

numlist=`cat /var/log/asterisk/sms.txt.tmp | grep "Ваш номер [0-9]*." | sed 's/ - 03#BB860: Ваш номер //g' | grep -o -R "dongle[0-9]*:[0-9]*:[0-9]*."  | sed 's/\./,/g'`

for num in $numlist
do
dongle=`echo "$num" | grep -o -R "dongle[0-9]*"`
imsi=`echo "$num" | grep -o -R ":[0-9]*:" | sed 's/://g'`
number=`echo "$num" | grep -o -R ":[0-9\-]*," | sed 's/://g' | sed 's/,//g'`
number=`echo "7$number"`
if [ $number -ne "7" ] ; then

echo "$dongle>$imsi>$number"
echo "$number" > /var/simbox/sim/settings/$imsi.number
fi

done