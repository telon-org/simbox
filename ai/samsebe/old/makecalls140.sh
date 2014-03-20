#!/bin/sh


imsilist=`cat /var/log/asterisk/imsi.list`

for imsi in $imsilist
do
status=`cat /var/log/asterisk/sim/$imsi.status`
balance=`cat /var/log/asterisk/sim/$imsi.balance`
dongle=`cat /var/log/asterisk/sim/$imsi.dongle`
number=`cat /var/log/asterisk/sim/$imsi.number`
state=`cat /var/log/asterisk/sim/$imsi.busy`

status=`echo "$status-1+1" | bc`
balance=`echo "$balance-1+1" | bc`
number=`echo "$number-1+1" | bc`
state=`echo "$state-1+1" | bc`



if [ "$number" -gt "0" ] ; then
#number=`echo "$number+10000000000" | bc`

if [ "$balance" -gt "-1" ] ; then
#if [ "$state" -ne "1" ] ; then
#проверить state

if [ "$status" -eq "141" ] ; then
echo "$dongle status=$status balance=$balance  number=$number state=$state Trebuetsya vhodashiy!"
/usr/src/ast/ai/samsebe/makecallsebe.sh 121 $number
sleep 10
fi


if [ "$status" -eq "142" ] ; then
echo "$dongle status=$status balance=$balance  number=$number state=$state Trebuetsya vhodashiy!"
/usr/src/ast/ai/samsebe/makecallsebe.sh 152 $number
sleep 10
fi

if [ "$status" -eq "143" ] ; then
echo "$dongle status=$status balance=$balance  number=$number state=$state Trebuetsya vhodashiy!"
/usr/src/ast/ai/samsebe/makecallsebe.sh 153 $number
sleep 10
fi


#fi
fi
fi

done