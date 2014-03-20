#!/bin/sh


#cat /var/log/asterisk/ussd2 | grep -o -R "dongle[0-9]*:[0-9]*: Баланс:[0-9\-][0-9\-]*"

#cat /var/log/asterisk/ussd2 | grep -o -R "dongle[0-9]*:[0-9]*: Баланс [0-9\-][0-9\-]*" | sed 's/: Баланс /:/g' > /var/log/asterisk/balance
#cat /var/log/asterisk/ussd.txt.tmp | grep -o -R "dongle[0-9]*:[0-9]*: Баланс:[0-9\-][0-9\-]*" | sed 's/: Баланс:/:/g' > /var/log/asterisk/balance
cat /var/log/asterisk/ussd.txt.tmp | grep -o -R "dongle[0-9]*:[0-9]*: Баланс [0-9\-][0-9\-]*" | sed 's/: Баланс /:/g' > /var/log/asterisk/balance

list=`cat /var/log/asterisk/balance`

for bal in $list
do
dongle=`echo "$bal" | grep -o -R "dongle[0-9]*"`
imsi=`echo "$bal" | grep -o -R ":[0-9]*:" | sed 's/://g'`
balance=`echo "$bal;" | grep -o -R ":[0-9\-]*;" | sed 's/://g' | sed 's/;//g'`
echo "$dongle>$imsi>$balance"
echo "$balance" > /var/simbox/sim/statistics/$imsi.balance
date +%s > /var/simbox/sim/statistics/$imsi.get_balance_response
done


cat /var/log/asterisk/ussd.txt.tmp | grep -o -R "dongle[0-9]*:[0-9]*: Ваш баланс [0-9\-][0-9\-]*" | sed 's/: Ваш баланс /:/g' > /var/log/asterisk/balance

list=`cat /var/log/asterisk/balance`

for bal in $list
do
dongle=`echo "$bal" | grep -o -R "dongle[0-9]*"`
imsi=`echo "$bal" | grep -o -R ":[0-9]*:" | sed 's/://g'`
balance=`echo "$bal;" | grep -o -R ":[0-9\-]*;" | sed 's/://g' | sed 's/;//g'`
echo "$dongle>$imsi>$balance"
echo "$balance" > /var/simbox/sim/statistics/$imsi.balance
date +%s > /var/simbox/sim/statistics/$imsi.get_balance_response
done


cat /var/log/asterisk/ussd.txt.tmp | grep -o -R "dongle[0-9]*:[0-9]*: Vash balans [0-9\-][0-9\-]*" | sed 's/: Vash balans /:/g' > /var/log/asterisk/balance

list=`cat /var/log/asterisk/balance`

for bal in $list
do
dongle=`echo "$bal" | grep -o -R "dongle[0-9]*"`
imsi=`echo "$bal" | grep -o -R ":[0-9]*:" | sed 's/://g'`
balance=`echo "$bal;" | grep -o -R ":[0-9\-]*;" | sed 's/://g' | sed 's/;//g'`
echo "$dongle>$imsi>$balance"
echo "$balance" > /var/simbox/sim/statistics/$imsi.balance
date +%s > /var/simbox/sim/statistics/$imsi.get_balance_response
done


