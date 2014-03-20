#!/bin/sh

. /usr/simbox/config.sh
. /usr/simbox/system/get_args.sh
. /usr/simbox/system/get_args_plan_nabor.sh

$rnd1=$3
$rnd2=$4
$rnd2=$5

/usr/simbox/actions/activate_sim.sh $1 $2
/usr/simbox/system/start_delay.sh $rnd1 "/usr/simbox/actions/get_balance.sh $1 $2"
/usr/simbox/system/start_delay.sh $rnd2 "/usr/simbox/actions/get_number.sh $1 $2"
#/usr/simbox/system/start_delay.sh $rnd3 "/usr/simbox/actions/activate_work.sh $1 $2"

