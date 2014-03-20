#!/bin/sh


#numlist=`cat /var/log/asterisk/ussd2 | grep "Ваш абонентский номер"` # | sed 's/ - 03#BB860: Ваш номер //g' | grep -o -R "dongle[0-9]*:[0-9]*:[0-9]*."  | sed 's/\./,/g'`
#cat /var/log/asterisk/ussd2 | grep "Ваш абонентский номер" | sed 's/: Ваш абонентский номер +/:/g'
numlist=`cat /var/log/asterisk/ussd.txt.tmp | grep " Vash nomer velcom: +" | sed 's/: Vash nomer velcom: +/:/g' | sed 's/ //g'`
#numlist=`cat /var/log/asterisk/ussd3 | grep " Vash nomer velcom: +" | sed 's/: Vash nomer velcom: +/:/g'  | sed 's/ //g' `

#numlist=`cat /var/log/asterisk/ussd2 | grep "Ваш номер" | sed 's/: Ваш номер /:/g'`

for num in $numlist
do
echo "--"
echo $num
dongle=`echo "$num" | grep -o -R "dongle[0-9]*"`
imsi=`echo "$num" | grep -o -R ":[0-9][0-9][0-9][0-9]*:" | sed 's/://g'`
number=`echo "$num," | grep -o -R ":[0-9\-]*," | sed 's/://g' | sed 's/,//g'`
number=`echo $number-1+1 | bc`


if [ $number -ne "0" ] ; then


#echo "$number"
echo "$dongle>$imsi>$number"

echo "$number" > /var/simbox/sim/settings/$imsi.number
fi

done