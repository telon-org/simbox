#!/bin/sh


#numlist=`cat /var/log/asterisk/ussd2 | grep "Ваш абонентский номер"` # | sed 's/ - 03#BB860: Ваш номер //g' | grep -o -R "dongle[0-9]*:[0-9]*:[0-9]*."  | sed 's/\./,/g'`
#cat /var/log/asterisk/ussd2 | grep "Ваш абонентский номер" | sed 's/: Ваш абонентский номер +/:/g'
numlist=`cat /var/log/asterisk/ussd.txt.tmp | grep "Ваш номер" | sed 's/: Ваш номер /:/g'`
#numlist=`cat /var/log/asterisk/ussd2 | grep "Ваш номер" | sed 's/: Ваш номер /:/g'`

for num in $numlist
do
dongle=`echo "$num" | grep -o -R "dongle[0-9]*"`
imsi=`echo "$num" | grep -o -R ":[0-9]*:" | sed 's/://g'`
number=`echo "$num," | grep -o -R ":[0-9\-]*," | sed 's/://g' | sed 's/,//g'`
number=`echo $number-1+1 | bc`


if [ $number -ne "0" ] ; then


#echo "$number"
echo "$dongle>$imsi>$number"

echo "$number" > /var/simbox/sim/settings/$imsi.number
fi

done



#numlist=`cat /var/log/asterisk/ussd2 | grep "Ваш абонентский номер"` # | sed 's/ - 03#BB860: Ваш номер //g' | grep -o -R "dongle[0-9]*:[0-9]*:[0-9]*."  | sed 's/\./,/g'`
#cat /var/log/asterisk/ussd2 | grep "Ваш абонентский номер" | sed 's/: Ваш абонентский номер +/:/g'
numlist=`cat /var/log/asterisk/ussd.txt.tmp | grep "Vash nomer" | sed 's/: Vash nomer /:/g'`
#numlist=`cat /var/log/asterisk/ussd2 | grep "Vash nomer" | sed 's/: Vash nomer /:/g'`

for num in $numlist
do
dongle=`echo "$num" | grep -o -R "dongle[0-9]*"`
imsi=`echo "$num" | grep -o -R ":[0-9]*:" | sed 's/://g'`
number=`echo "$num," | grep -o -R ":[0-9\-]*," | sed 's/://g' | sed 's/,//g'`
number=`echo $number-1+1 | bc`


if [ $number -ne "0" ] ; then


#echo "$number"
echo "$dongle>$imsi>$number"

echo "$number" > /var/simbox/sim/settings/$imsi.number
fi

done