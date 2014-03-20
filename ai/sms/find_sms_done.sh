#!/bin/sh

. /usr/simbox/config.sh

imsilist=`cat $FILE_IMSILIST`

for imsi in $imsilist
do
need_sms=`cat $PATH_SIMBOX_SIM_STATE/$imsi.need_sms`
sms_done=`cat $PATH_SVISTOK_SIM_STATE/$imsi.smsdone`

need_sms=`echo $need_sms-1+1 | bc`
sms_done=`echo $sms_done-1+1 | bc`


if [ $need_sms -gt "0" ] ; then
if [ $sms_done -gt "0" ] ; then
echo "sms_done $imsi"
rm $PATH_SIMBOX_SIM_STATE/$imsi.need_sms
rm $PATH_SVISTOK_SIM_STATE/$imsi.smsdone
fi
fi

done