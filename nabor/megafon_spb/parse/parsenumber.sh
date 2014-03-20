#!/bin/sh


#numlist=`cat /var/log/asterisk/ussd2 | grep "Ваш абонентский номер"` # | sed 's/ - 03#BB860: Ваш номер //g' | grep -o -R "dongle[0-9]*:[0-9]*:[0-9]*."  | sed 's/\./,/g'`
#cat /var/log/asterisk/ussd2 | grep "Ваш абонентский номер" | sed 's/: Ваш абонентский номер +/:/g'


numlist=`cat /var/log/asterisk/ussd.txt.tmp | grep "Ваш абонентский номер" | sed 's/: Ваш абонентский номер +/:/g'`

for num in $numlist
do
dongle=`echo "$num" | grep -o -R "dongle[0-9]*"`
imsi=`echo "$num" | grep -o -R ":[0-9]*:" | sed 's/://g'`
number=`echo "$num," | grep -o -R ":[0-9\-]*," | sed 's/://g' | sed 's/,//g'`
number=`echo $number-1+1 | bc`


if [ $number -ne "0" ] ; then


#echo "$number"
#echo "$dongle>$imsi>$number"

echo "$number" > /var/simbox/sim/settings/$imsi.number
fi

done


#2
numlist=`cat /var/log/asterisk/sms.txt.tmp | grep "Номер" | grep "активирован" | sed 's/ - +79210000002: //g' | sed 's/Номер //g' | sed 's/ активирован/,/g' | grep -o -R "dongle[0-9]*:[0-9]*:[0-9]*,"`

for num in $numlist
do
dongle=`echo "$num" | grep -o -R "dongle[0-9]*"`
imsi=`echo "$num" | grep -o -R ":[0-9]*:" | sed 's/://g'`
number=`echo "$num," | grep -o -R ":[0-9\-]*," | sed 's/://g' | sed 's/,//g'`
number=`echo $number-1+1 | bc`


if [ $number -ne "0" ] ; then


#echo "$number"
#echo "$dongle>$imsi>$number"

echo "7$number" > /var/simbox/sim/settings/$imsi.number
fi

done

#3
numlist=`cat /var/log/asterisk/sms.txt.tmp | grep "Сервис-Гид" | grep "Имя пользователя" | sed 's/: - 000110: Услуга "Сервис-Гид" заказана. Имя пользователя: /:/g' | grep -o -R "dongle[0-9]*:[0-9]*:[0-9]*,"`


for num in $numlist
do
dongle=`echo "$num" | grep -o -R "dongle[0-9]*"`
imsi=`echo "$num" | grep -o -R ":[0-9]*:" | sed 's/://g'`
number=`echo "$num," | grep -o -R ":[0-9\-]*," | sed 's/://g' | sed 's/,//g'`
number=`echo $number-1+1 | bc`


if [ $number -ne "0" ] ; then


#echo "$number"
#echo "$dongle>$imsi>$number"

echo "7$number" > /var/simbox/sim/settings/$imsi.number
fi

done


#3b
numlist=`cat /var/log/asterisk/sms.txt.tmp | grep "Сервис-Гид" | grep "Имя пользователя" | sed 's/: - 000110: Услуга Сервис-Гид заказана. Имя пользователя: /:/g' | grep -o -R "dongle[0-9]*:[0-9]*:[0-9]*,"`


for num in $numlist
do
dongle=`echo "$num" | grep -o -R "dongle[0-9]*"`
imsi=`echo "$num" | grep -o -R ":[0-9]*:" | sed 's/://g'`
number=`echo "$num," | grep -o -R ":[0-9\-]*," | sed 's/://g' | sed 's/,//g'`
number=`echo $number-1+1 | bc`


if [ $number -ne "0" ] ; then


#echo "$number"
#echo "$dongle>$imsi>$number"

echo "7$number" > /var/simbox/sim/settings/$imsi.number
fi

done



#4
numlist=`cat /var/log/asterisk/ussd.txt.tmp | grep ": 79"| sed 's/: 7/:/g' | grep -o -R "dongle[0-9]*:[0-9]*:[0-9]*"`


for num in $numlist
do
echo $num
dongle=`echo "$num" | grep -o -R "dongle[0-9]*"`
imsi=`echo "$num" | grep -o -R ":[0-9]*:" | sed 's/://g'`
number=`echo "$num," | grep -o -R ":[0-9\-]*," | sed 's/://g' | sed 's/,//g'`
number=`echo $number-1+1 | bc`


if [ $number -ne "0" ] ; then


#echo "$number"
#echo "$dongle>$imsi>$number"

echo "7$number" > /var/simbox/sim/settings/$imsi.number
fi

done