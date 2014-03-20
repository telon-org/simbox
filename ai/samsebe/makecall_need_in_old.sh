#!/bin/sh

. /usr/simbox/config.sh


imsilist=`cat $FILE_IMSILIST`

for imsi in $imsilist
do

group=`cat $PATH_SVISTOK_SIM_SETTINGS/$imsi.group`
need_in=`cat $PATH_SIMBOX_SIM_STATE/$imsi.need_in`
number=`cat $PATH_SIMBOX_SIM_SETTINGS/$imsi.number`
busy=`cat $PATH_SVISTOK_SIM_STATE/$imsi.busy`

str_state=`cat $PATH_SVISTOK_SIM_STATE/$imsi.str_state`


if [[ $str_state == Free ]] ; then
echo $str_state
fi

need_in=`echo $need_in-1+1 | bc`
busy=`echo $busy-1+1 | bc`

if [ $group -gt "99" ] ; then
if [ "200" -gt $group ] ; then
if [ $need_in -eq "1" ] ; then
if [ $busy -ne "1" ] ; then
if [ $number -gt "0" ] ; then
if [ "$str_state" == "Free" ] ; then

echo /usr/simbox/system/makecallsebe.sh "nodongle" "$number" "$imsi"
/usr/simbox/system/makecallsebe.sh "nodongle" "$number" "$imsi"
sleep 10


fi
fi
if [ "-1" -gt $number ] ; then
echo WARNING !!!!! CANNOT CALL !!! NO NUMBER!!!
fi
fi
fi
fi
fi

done