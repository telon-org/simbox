#!/bin/sh

exit

MIN_IN_ACD=180
MAX_OUT_IN_ANS= 14   #otnoshenie ishodashih k vhodashim - количество
MAX_OUT_IN_DUR= 5    #otnoshenie ishodashih k vhodashim - длительность
MIN_IATT= 6    # IATT до этого - предыдущие параметры не учитываются, входящий не пускаем
MAX_IATT= 20   # IATT до этого - предыдущие параметры не учитываются, входящий ПУСКАЕМ

#DIFFSECFIRST=60
#DIFFSECNEXT=3600

. /usr/src/ast/config/config.sh

imsilist=`cat /var/log/asterisk/imsi.list`

for imsi in $imsilist
do
status= `cat /var/log/asterisk/sim/$imsi.status`
balance=`cat /var/log/asterisk/sim/$imsi.balance`
dongle= `cat /var/log/asterisk/sim/$imsi.dongle`
number= `cat /var/log/asterisk/sim/$imsi.number`

state=  `cat /var/log/asterisk/sim/$imsi.state`

iatt=        `cat /var/log/asterisk/sim/$imsi.iatt`
in_answered= `cat /var/log/asterisk/sim/$imsi.stat_in_answered`
in_duration= `cat /var/log/asterisk/sim/$imsi.stat_in_duration`

out_answered=`cat /var/log/asterisk/sim/$imsi.stat_calls_answered`
out_duration=`cat /var/log/asterisk/sim/$imsi.stat_calls_duration`

status= `echo "$status-1+1" | bc`
balance=`echo "$balance-1+1" | bc`
number= `echo "$number-1+1" | bc`

iatt=         `echo "$iatt-1+1" | bc`
in_answered = `echo "$in_answered-1+1" | bc`
in_duration = `echo "$in_duration-1+1" | bc`
out_answered =`echo "$out_answered-1+1" | bc`
out_duration =`echo "$out_duration-1+1" | bc`

in_acd = `echo "$in_duration/$in_answered" | bc`



if [ "110" -gt "$status" ] ; then
if [ "$status" -gt "100" ] ; then

echo "$dongle:imsi ($iatt) $in_duration/$in_answered=$in_acd $out_duration/$out_answered"

echo $secondstotal
if [ "$lastinc" -eq "0" ] ; then
if [ "$secondstotal" -gt "$DIFFSECFIRST" ] ; then

if [ "$status" -eq "102" ] ; then
echo "$dongle $imsi $status $lastinc $secondstotal"
echo "$secondstotal" > /var/log/asterisk/sim/$imsi.lastinc
rm /var/log/asterisk/sim/$imsi.indone
$ASTERISK -r -x "dongle setgroupimsi $imsi 142"
#exit 0
fi

#if [ "$status" -eq "103" ] ; then
#echo "$dongle $imsi $status $lastinc $secondstotal"
#echo "$secondstotal" > /var/log/asterisk/sim/$imsi.lastinc
#rm /var/log/asterisk/sim/$imsi.indone
#$ASTERISK -r -x "dongle setgroupimsi $imsi 143"
#exit 0
#fi


#fi
#fi

#if [ "$lastinc" -gt "0" ] ; then
#if [ "$secondstotal" -gt "$needinc" ] ; then

if [ "$status" -eq "102" ] ; then
echo "$dongle $imsi $status $lastinc $secondstotal"
echo "$secondstotal" > /var/log/asterisk/sim/$imsi.lastinc
rm /var/log/asterisk/sim/$imsi.indone
$ASTERISK -r -x "dongle setgroupimsi $imsi 142"
#exit 0
fi

if [ "$status" -eq "103" ] ; then
echo "$dongle $imsi $status $lastinc $secondstotal"
echo "$secondstotal" > /var/log/asterisk/sim/$imsi.lastinc
rm /var/log/asterisk/sim/$imsi.indone
$ASTERISK -r -x "dongle setgroupimsi $imsi 143"
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