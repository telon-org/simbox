#!/bin/sh

. /usr/simbox/config.sh
. /usr/simbox/system/get_args.sh
. /usr/simbox/system/get_args_plan_nabor.sh

#if [ $NABOR -ne "" ] ; then 
CMD="$PATH_SIMBOX_NABOR/$NABOR/commands/get_balance.sh $DONGLE $IMSI"
echo $CMD
$CMD

date +%s > /var/simbox/sim/statistics/$IMSI.get_balance_request
#fi