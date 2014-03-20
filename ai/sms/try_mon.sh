#!/bin/bash

qos=$1
imsi=$2
number=$3
#need_sms=`cat /var/simbox/sim/state/$imsi.need_sms`


echo "try_mon qos=$qos imsi=$imsi number=$number need_sms=$need_sms maymon=mon"

echo "DISABLED IN SOFT !!!"

#if [ "$qos" == "SLOW" ] ; then
#/usr/simbox/system/sleep_rand.php 20 30
#echo "/usr/simbox/ai/sms/send_maymon.php $imsi mon $number"
#/usr/simbox/ai/sms/send_maymon.php $imsi mon $number
#fi
