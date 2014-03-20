#!/bin/sh

. /usr/simbox/config.sh

minacdl=25

imsilist=`cat $FILE_IMSILIST`


for imsi in $imsilist
do

acdl=`cat $PATH_SVISTOK_SIM_STATISTICS/$imsi.stat_acdl`
acdl=`echo "($acdl-1+1)/1000" | bc`


if [ "$acdl" -gt "0" ] ; then
if [ "$minacdl" -gt "$acdl" ] ; then
    echo "$imsi low_acdl"
    echo 1 > $PATH_SIMBOX_SIM_STATE/$imsi.low_acdl
fi
fi

done


