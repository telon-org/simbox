#!/bin/sh



. /usr/simbox/config.sh



imsilist=`cat $FILE_IMSILIST`

for imsi in $imsilist
do
satt=`cat $PATH_SVISTOK_SIM_STATISTICS/$imsi.stat_satt`
satt_min=`cat /var/simbox/sim/settings/$imsi.satt_min`


satt=`echo "$satt-1+1" | bc`
satt_min=`echo "$satt_min-1+1" | bc`

echo "$imsi $satt ? $satt_min"

#if [ $satt -gt $satt_min ] ; then
echo "need sms $imsi $satt>$satt_min"

dongle=`cat /var/svistok/sim/state/$imsi.dongle`

group=`cat $PATH_SVISTOK_SIM_SETTINGS/$imsi.group`
if [ $group -eq 210 ] ; then
#echo "1" > $PATH_SIMBOX_SIM_STATE/$imsi.need_sms
echo $imsi
/usr/simbox/ai/sms/sendsms_imsi.php "$imsi"
sleep 3

#exit
fi


#fi
done