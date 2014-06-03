#!/bin/sh

imsi=$1
number=$2


group=`cat /var/svistok/sim/settings/$imsi.group`
dongle=`cat /var/svistok/sim/state/$imsi.dongle`

echo "try_may imsi=$imsi number=$number group=$group"

if [ $group -eq 232 ] ; then
/usr/simbox/system/sleep_rand.php 4 10
/usr/simbox/actions/get_balance.sh $dongle $imsi
fi
