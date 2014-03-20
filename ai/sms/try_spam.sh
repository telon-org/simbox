#!/bin/sh

imsi=$1

nospam=`cat /var/simbox/sim/settings/$imsi.nospam`

echo "try_spam imsi=$imsi"

if [ $nospam -eq 2 ] ; then
/usr/simbox/system/sleep_rand.php 2 4
echo "/usr/simbox/ai/sms/sendsms_spam_2.php $imsi"
/usr/simbox/ai/sms/sendsms_spam_2.php $imsi 
fi
