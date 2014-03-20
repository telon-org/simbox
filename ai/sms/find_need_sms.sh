#!/bin/sh



. /usr/simbox/config.sh



imsilist=`cat $FILE_IMSILIST`

for imsi in $imsilist
do
satt=`cat $PATH_SVISTOK_SIM_STATISTICS/$imsi.stat_satt`
satt_soft=`cat /var/simbox/sim/settings/$imsi.satt_soft`


satt=`echo "$satt-1+1" | bc`
satt_soft=`echo "$satt_soft-1+1" | bc`

echo "$imsi $satt ? $satt_soft"

if [ $satt -gt $satt_soft ] ; then
echo "need sms $imsi $satt>$satt_soft"
dongle=`cat /var/svistok/sim/state/$imsi.dongle`

echo "1" > $PATH_SIMBOX_SIM_STATE/$imsi.need_sms

#sms=`curl http://simserver:8122/sms/getsmsout.php`
#echo "/usr/simbox/ai/sms/sendsms.php \"$dongle\" \"$sms\""
#/usr/simbox/ai/sms/sendsms.php "$dongle" "$sms"

#exit

fi
done