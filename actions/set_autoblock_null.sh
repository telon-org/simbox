#!/bin/sh

. /usr/simbox/config.sh
. /usr/simbox/system/get_args.sh
#. /usr/simbox/system/get_args_plan_nabor.sh
#if [ $NABOR -ne "" ] ; then 
CMD="rm $PATH_SIMBOX_SIM_STATE/$IMSI.high_datt"
echo $CMD
$CMD
CMD="rm $PATH_SIMBOX_SIM_STATE/$IMSI.low_acdl"
echo $CMD
$CMD

CMD="rm $PATH_SVISTOK_SIM_STATISTICS/$IMSI.stat_datt"
echo $CMD
$CMD
CMD="rm $PATH_SVISTOK_SIM_STATISTICS/$IMSI.stat_acdl"
echo $CMD
$CMD

#fi