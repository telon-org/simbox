#!/bin/sh

exit

DIFFSECFIRST=120
DIFFSECNEXT=4000

. /usr/src/ast/config/config.sh

imsilist=`cat /var/log/asterisk/imsi.list`

for imsi in $imsilist
do
status=`cat /var/log/asterisk/sim/$imsi.status`
balance=`cat /var/log/asterisk/sim/$imsi.balance`
dongle=`cat /var/log/asterisk/sim/$imsi.dongle`
number=`cat /var/log/asterisk/sim/$imsi.number`
state=`cat /var/log/asterisk/sim/$imsi.state`

lastout=`cat /var/log/asterisk/sim/$imsi.lastout`
secondstotal=`cat /var/log/asterisk/sim/$imsi.stat_calls_duration`

status=`echo "$status-1+1" | bc`
balance=`echo "$balance-1+1" | bc`
number=`echo "$number-1+1" | bc`

lastout=`echo "$lastout-1+1" | bc`
needout=`echo "$lastout+$DIFFSECNEXT" | bc`


if [ "110" -gt "$status" ] ; then
if [ "$status" -gt "100" ] ; then

echo "$dongle $imsi $status $lastout $secondstotal <> $needout"

echo $secondstotal
if [ "$lastout" -eq "0" ] ; then
if [ "$secondstotal" -gt "$DIFFSECFIRST" ] ; then

if [ "$status" -eq "102" ] ; then
echo "$dongle $imsi $status $lastout $secondstotal"
echo "$secondstotal" > /var/log/asterisk/sim/$imsi.lastout
rm /var/log/asterisk/sim/$imsi.outdone
$ASTERISK -r -x "dongle setgroupimsi $imsi 152"
#exit 0
fi

if [ "$status" -eq "103" ] ; then
echo "$dongle $imsi $status $lastout $secondstotal"
echo "$secondstotal" > /var/log/asterisk/sim/$imsi.lastout
rm /var/log/asterisk/sim/$imsi.outdone
$ASTERISK -r -x "dongle setgroupimsi $imsi 153"
#exit 0
fi

fi
fi

if [ "$lastout" -gt "0" ] ; then
if [ "$secondstotal" -gt "$needout" ] ; then

if [ "$status" -eq "102" ] ; then
echo "$dongle $imsi $status $lastout $secondstotal"
echo "$secondstotal" > /var/log/asterisk/sim/$imsi.lastout
rm /var/log/asterisk/sim/$imsi.outdone
$ASTERISK -r -x "dongle setgroupimsi $imsi 152"
#exit 0
fi

if [ "$status" -eq "103" ] ; then
echo "$dongle $imsi $status $lastout $secondstotal"
echo "$secondstotal" > /var/log/asterisk/sim/$imsi.lastout
rm /var/log/asterisk/sim/$imsi.outdone
$ASTERISK -r -x "dongle setgroupimsi $imsi 153"
#exit 0
fi

fi
fi



#if [ "150" -gt "$status" ] ; then
#if [ "$number" -gt "0" ] ; then
#number=`echo "$number+10000000000" | bc`
#if [ "$balance" -gt "-1" ] ; then
##if [ "$state" -eq "Free" ] ; then
##проверить state
#DB#DB
#echo "$dongle status=$status balance=$balance  number=$number state=$state Trebuetsya vhodashiy!"
#DB#/usr/src/ast/ai/samsebe/makecallsebe.sh ttt $number
#sleep 1

#fi
#fi
#fi
#fi

fi
fi

done