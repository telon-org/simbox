#!/bin/sh

. /usr/simbox/config.sh
. /usr/simbox/system/get_args.sh
. /usr/simbox/system/get_args_plan_nabor.sh

#if [ $NABOR -ne "" ] ; then 
CMD="$PATH_SIMBOX_NABOR/$NABOR/commands/get_options.sh $DONGLE $IMSI"
echo $CMD
$CMD
#fi