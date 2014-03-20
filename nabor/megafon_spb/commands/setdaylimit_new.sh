#!/bin/sh

. /usr/simbox/config.sh

list=`cat $FILE_IMSILIST`

for imsi in $list
do


group=`cat $PATH_SVISTOK_SIM_SETTINGS/$imsi.group`


if [ "$group" -eq 5 ] ; then
echo "$imsi $operator"

echo "4500" > /var/svistok/sim/limits/$imsi.limit.3
date +%s > /var/svistok/sim/limits/$imsi.limit_date

fi


done

