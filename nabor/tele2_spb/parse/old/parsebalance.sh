#!/bin/sh


#cat /var/log/asterisk/ussd2 | grep -o -R "dongle[0-9]*:[0-9]*: Баланс:[0-9\-][0-9\-]*"

#cat /var/log/asterisk/ussd2 | grep -o -R "dongle[0-9]*:[0-9]*: Баланс [0-9\-][0-9\-]*" | sed 's/: Баланс /:/g' > /var/log/asterisk/balance
#cat /var/log/asterisk/ussd.txt.tmp | grep -o -R "dongle[0-9]*:[0-9]*: Баланс:[0-9\-][0-9\-]*" | sed 's/: Баланс:/:/g' > /var/log/asterisk/balance


cat /var/log/asterisk/ussd.txt.tmp | grep -o -R "dongle[0-9]*:[0-9]*: OCTATOK [0-9\-][0-9\-]*" | sed 's/: OCTATOK /:/g' > /var/log/asterisk/balance

list=`cat /var/log/asterisk/balance`

for bal in $list
do
dongle=`echo "$bal" | grep -o -R "dongle[0-9]*"`
imsi=`echo "$bal" | grep -o -R ":[0-9]*:" | sed 's/://g'`
balance=`echo "$bal;" | grep -o -R ":[0-9\-]*;" | sed 's/://g' | sed 's/;//g'`
echo "$dongle>$imsi>$balance"
echo "$balance" > /var/simbox/sim/statistics/$imsi.balance
date +%s > /var/simbox/sim/statistics/$imsi.get_balance_response
/usr/simbox/stat/upload_balance.sh "$imsi" "$balance" > /tmp/upload_balance.log &
/usr/simbox/system/balance_diff.sh "$imsi" &
done


cat /var/log/asterisk/ussd.txt.tmp | grep -o -R "dongle[0-9]*:[0-9]*: OCTATOK munyc [0-9\-][0-9\-]*" | sed 's/: OCTATOK munyc /:/g' > /var/log/asterisk/balance

list=`cat /var/log/asterisk/balance`

for bal in $list
do
dongle=`echo "$bal" | grep -o -R "dongle[0-9]*"`
imsi=`echo "$bal" | grep -o -R ":[0-9]*:" | sed 's/://g'`
balance=`echo "$bal;" | grep -o -R ":[0-9\-]*;" | sed 's/://g' | sed 's/;//g'`
echo "$dongle>$imsi>-$balance"
echo "-$balance" > /var/simbox/sim/statistics/$imsi.balance
date +%s > /var/simbox/statistics/$imsi.get_balance_response
/usr/simbox/stat/upload_balance.sh "$imsi" "-$balance" > /tmp/upload_balance.log &
/usr/simbox/system/balance_diff.sh "$imsi" &
done

