#!/bin/sh

. /usr/simbox/config.sh
. /usr/simbox/system/get_args.sh
. /usr/simbox/system/get_args_plan_nabor.sh

#if [ $NABOR -ne "" ] ; then 
#CMD="$PATH_SIMBOX_NABOR/$NABOR/commands/activate_sim.sh $DONGLE $IMSI"
#echo $CMD
#$CMD
#fi

$ASTERISK -rx "dongle changeimei $DONGLE 222222222222222"