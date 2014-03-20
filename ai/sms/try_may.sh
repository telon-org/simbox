#!/bin/sh

imsi=$1
number=$2


need_sms=`cat /var/simbox/sim/state/$imsi.need_sms`

echo "try_may imsi=$imsi number=$number need_sms=$need_sms"

if [ $need_sms -eq 1 ] ; then
/usr/simbox/system/sleep_rand.php 4 10
echo "/usr/simbox/ai/sms/send_maymon.php $imsi may $number"
/usr/simbox/ai/sms/send_maymon.php $imsi may $number
fi
