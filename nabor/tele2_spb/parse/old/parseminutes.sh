#!/bin/sh


cat /var/log/asterisk/ussd.txt.tmp | grep -o -R "dongle[0-9]*:[0-9]*: Остаток: [0-9\-][0-9\-]*.00 минут из 300 в месяц" | sed 's/ Остаток: //g' | sed 's/.00 минут из 300 в месяц//g'
cat /var/log/asterisk/ussd.txt.tmp | grep -o -R "dongle[0-9]*:[0-9]*: Остаток: [0-9\-][0-9\-]*.00 минут из 300 в месяц" | sed 's/ Остаток: //g' | sed 's/.00 минут из 300 в месяц//g' > /var/log/asterisk/minutes

list=`cat /var/log/asterisk/minutes`

for line in $list
do
echo $line
dongle=`echo "$line" | grep -o -R "dongle[0-9]*"`
imsi=`echo "$line" | grep -o -R ":[0-9]*:" | sed 's/://g'`
min=`echo "$line;" | grep -o -R ":[0-9\-]*;" | sed 's/://g' | sed 's/;//g'`
bal=`cat /var/simbox/sim/statistics/$imsi.balance`
limit_hard= `cat /var/svistok/sim/limits/$imsi.limit_hard.3`

#min1=`echo "($min-2-300)*60+$limit_hard" | bc`
min1=`echo "($min-2)*60" | bc`

min2=`echo "($min-3+(($bal-1+1)/1))*60" | bc`

echo "$dongle>$imsi>$min"
echo "$min1" > /var/svistok/sim/limits/$imsi.limit.3
echo "$min2" > /var/svistok/sim/limits/$imsi.limit.4

#echo "$balance" > /var/simbox/sim/state/$imsi.balance
#date +%s > /var/simbox/sim/$imsi.get_balance_response
done


