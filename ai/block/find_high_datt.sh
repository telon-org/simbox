#!/bin/sh

. /usr/simbox/config.sh


maxdatt=10
maxdatt1=20
maxdatt2=20

maxdatt_day=15
maxdatt_night=30


imsilist=`cat $FILE_IMSILIST`


for imsi in $imsilist
do

datt=`cat $PATH_SVISTOK_SIM_STATISTICS/$imsi.stat_datt`
datt=`echo "$datt-1+1" | bc`


if [ "$datt" -gt "$maxdatt1" ] ; then
    echo "$imsi high_datt"
    echo 1 > $PATH_SIMBOX_SIM_STATE/$imsi.high_datt

fi
done


