#!/bin/sh

. /usr/src/ast/config/config.sh

list=`ls /var/log/asterisk/sim/ | grep ".operator" | sed 's/.operator//g'`

for imsi in $list
do


status=`cat /var/log/asterisk/sim/$imsi.status`
operator=`cat /var/log/asterisk/sim/$imsi.operator`
operatorc=`cat /var/log/asterisk/sim/$imsi.operator | grep --count "Bee"`
status=`echo $status-1+1 | bc`


if [ "1" -gt $status ] ; then
if [ "$operatorc" -gt 0 ] ; then
echo "$imsi $operator"
echo "9000" > /var/log/asterisk/sim/$imsi.limit.1
echo "0" > /var/log/asterisk/sim/$imsi.limit.2
#echo "9000" > /var/log/asterisk/sim/$imsi.limit.2
fi
fi

done

