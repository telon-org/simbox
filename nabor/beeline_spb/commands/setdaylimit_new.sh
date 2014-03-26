#!/bin/sh

. /usr/simbox/config.sh

list=`cat $FILE_IMSILIST`

for imsi in $list
do


group=`cat $PATH_SVISTOK_SIM_SETTINGS/$imsi.group`

if [ "$group" -eq 5 ] ; then
echo "$imsi $operator"

echo "5400" > /var/svistok/sim/limits/$imsi.limit.1
echo "9000" > /var/svistok/sim/limits/$imsi.limit.2
echo "9000" > /var/svistok/sim/limits/$imsi.limit.3
fi

if [ "$group" -eq 6 ] ; then
echo "$imsi $operator"

echo "5000" > /var/svistok/sim/limits/$imsi.limit.1
echo "9000" > /var/svistok/sim/limits/$imsi.limit.2
echo "9000" > /var/svistok/sim/limits/$imsi.limit.3
fi

if [ "$group" -eq 11 ] ; then
echo "$imsi $operator"
echo "3000" > /var/svistok/sim/limits/$imsi.limit.1
fi

done

