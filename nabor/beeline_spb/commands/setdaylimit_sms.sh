#!/bin/sh

. /usr/simbox/config.sh

#sleep 60

list=`cat $FILE_IMSILIST`



#/usr/simbox/nabor/beeline_spb/commands/setdaylimit_2.sh

for imsi in $list
do

group=`cat $PATH_SVISTOK_SIM_SETTINGS/$imsi.group`

echo "0" > /var/simbox/sim/settings/$imsi.smsout_sended
echo "0" > /var/simbox/sim/settings/$imsi.may_sended
echo "0" > /var/simbox/sim/settings/$imsi.mon_sended
echo "0" > /var/simbox/sim/settings/$imsi.msm_sended

done

