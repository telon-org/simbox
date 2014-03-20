#!/bin/sh

. /usr/simbox/config.sh

list=`cat $FILE_IMSILIST`

for imsi in $list
do


#operator=`cat /var/log/asterisk/sim/$imsi.operator`
#operatorc=`cat /var/log/asterisk/sim/$imsi.operator | grep --count "Bee"`

#if [ "$operatorc" -gt 0 ] ; then
echo "$imsi $operator"
echo "0" > /var/svistok/sim/limits/$imsi.limit.1
echo "0" > /var/svistok/sim/limits/$imsi.limit.2
#fi

done

