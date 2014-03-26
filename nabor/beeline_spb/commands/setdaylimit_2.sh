#!/bin/sh

. /usr/simbox/config.sh

#sleep 60

list=`ls /var/svistok/sim/limits/*.limit.1`

for imsi in $list
do
echo "$imsi"
echo "5400" > $imsi

#group=`cat $PATH_SVISTOK_SIM_SETTINGS/$imsi.group`
#if [ "$group" -eq 211 ] ; then
#echo "3000" > $imsi
#fi

done


#list=`ls /var/svistok/sim/limits/*.limit.2`
#for imsi in $list
#do
#echo "$imsi"
#echo "0" > $imsi
#done









