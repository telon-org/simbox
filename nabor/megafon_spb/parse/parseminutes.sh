#!/bin/sh


#cat /var/log/asterisk/sms3 | grep -o -R "dongle[0-9]*:[0-9]*: - 000102: [0-9\-][0-9\-]* мин. на МегаФон" | sed 's/ - 000102: //g' | sed 's/ мин. на МегаФон//g'
cat /var/log/asterisk/sms.txt.tmp | grep -o -R "dongle[0-9]*:[0-9]*: - 000102: [0-9\-][0-9\-]* мин. на МегаФон" | sed 's/ - 000102: //g' | sed 's/ мин. на МегаФон//g' > /var/log/asterisk/minutes
#cat /var/log/asterisk/sms3 | grep -o -R "dongle[0-9]*:[0-9]*: - 000102: [0-9\-][0-9\-]* мин. на МегаФон" | sed 's/ - 000102: //g' | sed 's/ мин. на МегаФон//g'
#cat /var/log/asterisk/sms3 | grep -o -R "dongle[0-9]*:[0-9]*: - 000102: [0-9\-][0-9\-]* мин. на МегаФон" | sed 's/ - 000102: //g' | sed 's/ мин. на МегаФон//g' > /var/log/asterisk/minutes


list=`cat /var/log/asterisk/minutes`

for line in $list
do
echo $line
dongle=`echo "$line" | grep -o -R "dongle[0-9]*"`
imsi=`echo "$line" | grep -o -R ":[0-9]*:" | sed 's/://g'`
min=`echo "$line;" | grep -o -R ":[0-9\-]*;" | sed 's/://g' | sed 's/;//g'`
#bal=`cat /var/simbox/sim/state/$imsi.balance`
#limit_hard= `cat /var/svistok/sim/limits/$imsi.limit_hard.3`

#min1=`echo "($min-2-300)*60+$limit_hard" | bc`

if [ $min -gt 100 ] ; then
min=-995
fi

min1=`echo "($min-20)*60" | bc`
min2=`echo "($min-3+(($bal-1+1)/1))*60" | bc`

echo "$dongle>$imsi>$min"
echo "$min1" > /var/svistok/sim/limits/$imsi.limit.3
#echo "$min2" > /var/svistok/sim/limits/$imsi.limit.4

#echo "$balance" > /var/simbox/sim/state/$imsi.balance
#date +%s > /var/simbox/sim/$imsi.get_balance_response
done


#: - BA2: Минуты: 100 на МегаФон-Россия (кроме Северо-Запада) 
cat /var/log/asterisk/sms.txt.tmp | grep -o -R "dongle[0-9]*:[0-9]*: - BA2: Минуты: [0-9\-][0-9\-]* на МегаФон" | sed 's/ - BA2: Минуты: //g' | sed 's/ на МегаФон//g' > /var/log/asterisk/minutes


list=`cat /var/log/asterisk/minutes`

for line in $list
do
echo $line
dongle=`echo "$line" | grep -o -R "dongle[0-9]*"`
imsi=`echo "$line" | grep -o -R ":[0-9]*:" | sed 's/://g'`
min=`echo "$line;" | grep -o -R ":[0-9\-]*;" | sed 's/://g' | sed 's/;//g'`
#bal=`cat /var/simbox/sim/state/$imsi.balance`
#limit_hard= `cat /var/svistok/sim/limits/$imsi.limit_hard.3`

#min1=`echo "($min-2-300)*60+$limit_hard" | bc`

if [ $min -gt 100 ] ; then
min=-995
fi

min1=`echo "($min-20)*60" | bc`
min2=`echo "($min-3+(($bal-1+1)/1))*60" | bc`

echo "$dongle>$imsi>$min"
echo "$min1" > /var/svistok/sim/limits/$imsi.limit.3
#echo "$min2" > /var/svistok/sim/limits/$imsi.limit.4

#echo "$balance" > /var/simbox/sim/state/$imsi.balance
#date +%s > /var/simbox/sim/$imsi.get_balance_response
done




#- 000102: Скидки не предоставлены. 

#cat /var/log/asterisk/sms3 | grep -o -R "dongle[0-9]*:[0-9]*: - 000102: Скидки не предоставлены"
cat /var/log/asterisk/sms.txt.tmp | grep -o -R "dongle[0-9]*:[0-9]*: - 000102: Скидки не предоставлены. " | sed 's/ Скидки не предоставлены. /-10000/g' > /var/log/asterisk/minutes
#cat /var/log/asterisk/sms3 | grep -o -R "dongle[0-9]*:[0-9]*: - 000102: Скидки не предоставлены. " | sed 's/ Скидки не предоставлены. /-10000/g' > /var/log/asterisk/minutes


list=`cat /var/log/asterisk/minutes`

for line in $list
do
echo $line
dongle=`echo "$line" | grep -o -R "dongle[0-9]*"`
imsi=`echo "$line" | grep -o -R ":[0-9]*:" | sed 's/://g'`
min=`echo "$line;" | grep -o -R ":[0-9\-]*;" | sed 's/://g' | sed 's/;//g'`

min1=-10000

min2=`echo "($min-3+(($bal-1+1)/1))*60" | bc`

echo "$dongle>$imsi>$min"
echo "$min1" > /var/svistok/sim/limits/$imsi.limit.3
#echo "$min2" > /var/svistok/sim/limits/$imsi.limit.4

#echo "$balance" > /var/simbox/sim/state/$imsi.balance
#date +%s > /var/simbox/sim/$imsi.get_balance_response
done



# - BA2: Скидки не предоставлены
cat /var/log/asterisk/sms.txt.tmp | grep -o -R "dongle[0-9]*:[0-9]*: - BA2: Скидки не предоставлены" | sed 's/ Скидки не предоставлены. /-10000/g' > /var/log/asterisk/minutes
#cat /var/log/asterisk/sms3 | grep -o -R "dongle[0-9]*:[0-9]*: - 000102: Скидки не предоставлены. " | sed 's/ Скидки не предоставлены. /-10000/g' > /var/log/asterisk/minutes


list=`cat /var/log/asterisk/minutes`

for line in $list
do
echo $line
dongle=`echo "$line" | grep -o -R "dongle[0-9]*"`
imsi=`echo "$line" | grep -o -R ":[0-9]*:" | sed 's/://g'`
min=`echo "$line;" | grep -o -R ":[0-9\-]*;" | sed 's/://g' | sed 's/;//g'`

min1=-10000

min2=`echo "($min-3+(($bal-1+1)/1))*60" | bc`

echo "$dongle>$imsi>$min"
echo "$min1" > /var/svistok/sim/limits/$imsi.limit.3
#echo "$min2" > /var/svistok/sim/limits/$imsi.limit.4

#echo "$balance" > /var/simbox/sim/state/$imsi.balance
#date +%s > /var/simbox/sim/$imsi.get_balance_response
done
