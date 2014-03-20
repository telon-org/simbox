#!/bin/sh

. /usr/simbox/config.sh

#sleep 60

list=`cat $FILE_IMSILIST`

for imsi in $list
do

group=`cat $PATH_SVISTOK_SIM_SETTINGS/$imsi.group`

#operator=`cat /var/log/asterisk/sim/$imsi.operator`
#operatorc=`cat /var/log/asterisk/sim/$imsi.operator | grep --count "Bee"`

#if [ "$operatorc" -gt 0 ] ; then
echo "$imsi $operator"
echo "9000" > /var/svistok/sim/limits/$imsi.limit.1
echo "9000" > /var/svistok/sim/limits/$imsi.limit.2
date +%s > /var/svistok/sim/limits/$imsi.limit_date
#fi

if [ "$group" -eq 102 ] ; then
echo "$imsi $operator"
echo "0" > /var/simbox/sim/settings/$imsi.smsout_sended
echo "0" > /var/simbox/sim/settings/$imsi.may_sended
echo "0" > /var/simbox/sim/settings/$imsi.mon_sended
echo "0" > /var/simbox/sim/settings/$imsi.msm_sended
fi

done

/usr/simbox/nabor/beeline_spb/commands/setdaylimit_2.sh