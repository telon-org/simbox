#!/bin/sh

. /usr/simbox/config.sh

list=`cat $FILE_IMSILIST`

for imsi in $list
do


group=`cat $PATH_SVISTOK_SIM_SETTINGS/$imsi.group`

if [ "$group" -eq 209 ] ; then
echo "$imsi $operator"

#cp /var/svistok/sim/limits/$imsi.limit_soft.1 /var/svistok/sim/limits/$imsi.limit.1
#cp /var/svistok/sim/limits/$imsi.limit_soft.2 /var/svistok/sim/limits/$imsi.limit.2
#cp /var/svistok/sim/limits/$imsi.limit_soft.3 /var/svistok/sim/limits/$imsi.limit.3
#cp /var/svistok/sim/limits/$imsi.limit_soft.4 /var/svistok/sim/limits/$imsi.limit.4
#cp /var/svistok/sim/limits/$imsi.limit_soft.5 /var/svistok/sim/limits/$imsi.limit.5
fi

done

