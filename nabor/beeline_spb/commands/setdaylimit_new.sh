#!/bin/sh

. /usr/simbox/config.sh

list=`cat $FILE_IMSILIST`

for imsi in $list
do


group=`cat $PATH_SVISTOK_SIM_SETTINGS/$imsi.group`

if [ "$group" -eq 5 ] ; then
echo "$imsi $operator"

echo "4000" > /var/svistok/sim/limits/$imsi.limit.1
echo "9000" > /var/svistok/sim/limits/$imsi.limit.2
echo "9000" > /var/svistok/sim/limits/$imsi.limit.3

#cp /var/svistok/sim/limits/$imsi.limit_soft.1 /var/svistok/sim/limits/$imsi.limit.1
#cp /var/svistok/sim/limits/$imsi.limit_soft.2 /var/svistok/sim/limits/$imsi.limit.2
#cp /var/svistok/sim/limits/$imsi.limit_soft.3 /var/svistok/sim/limits/$imsi.limit.3
#cp /var/svistok/sim/limits/$imsi.limit_soft.4 /var/svistok/sim/limits/$imsi.limit.4
#cp /var/svistok/sim/limits/$imsi.limit_soft.5 /var/svistok/sim/limits/$imsi.limit.5
fi

if [ "$group" -eq 11 ] ; then
echo "$imsi $operator"
echo "3000" > /var/svistok/sim/limits/$imsi.limit.1
fi

done

