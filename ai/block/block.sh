#!/bin/sh

. /usr/simbox/config.sh


maxdatt=10
maxdatt1=8
maxdatt2=20



imsilist=`cat $FILE_IMSILIST`


for imsi in $imsilist
do
high_datt=`cat $PATH_SIMBOX_SIM_STATE/$imsi.high_datt`
low_acdl=`cat $PATH_SIMBOX_SIM_STATE/$imsi.low_acdl`
group=`cat $PATH_SVISTOK_SIM_SETTINGS/$imsi.group`

group=`echo $group-1+1 | bc`
high_datt=`echo $high_datt-1+1 | bc`
low_acdl=`echo $low_acdl-1+1 | bc`

echo $group $low_acdl $high_datt


if [ $group -gt "99" ] ; then
if [ "290" -gt $group ] ; then


if [ $group -ne "222" ] ; then
if [ $high_datt -gt "0" ] ; then
echo "!!!"
$ASTERISK -r -x "dongle setgroupimsi $imsi 333"
#echo $CMD
#$CMD
date +"%Y-%m-%d %H:%M:%S" > $PATH_SIMBOX_SIM_STATE/$imsi.date_blocked
fi
fi

if [ $low_acdl -gt "0" ] ; then
echo "!!!"
#CMD='
$ASTERISK -r -x "dongle setgroupimsi $imsi 334"
#echo $CMD
#$CMD
date +"%Y-%m-%d %H:%M:%S" > $PATH_SIMBOX_SIM_STATE/$imsi.date_blocked
fi

fi
fi

if [ "295" -eq $group ] ; then
if [ $high_datt -gt "0" ] ; then
echo "!!!"
$ASTERISK -r -x "dongle setgroupimsi $imsi 333"
#echo $CMD
#$CMD
date +"%Y-%m-%d %H:%M:%S" > $PATH_SIMBOX_SIM_STATE/$imsi.date_blocked
fi
fi

done


