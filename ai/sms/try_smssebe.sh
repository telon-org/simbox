#!/bin/sh
exit

imsi=$1

need_sms=`cat /var/simbox/sim/state/$imsi.need_sms`
echo "try_smssebe imsi=$imsi need_sms=$need_sms"

if [ $need_sms -eq 1 ] ; then
/usr/simbox/system/sleep_rand.php 14 9
echo "/usr/simbox/ai/sms/send_smssebe.php $imsi"
/usr/simbox/ai/sms/send_smssebe.php $imsi
fi
