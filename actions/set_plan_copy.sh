#!/bin/sh

. /usr/simbox/config.sh
. /usr/simbox/system/get_args.sh


echo "-- GET PLAN"
PLAN=`cat $PATH_SIMBOX_SIM_SETTINGS/$IMSI.plan`
echo "-- COPY PLAN=$PLAN"


cp $PATH_SIMBOX_PLAN/$PLAN.limit_max.1 $PATH_SVISTOK_SIM_LIMITS/$IMSI.limit_max.1
cp $PATH_SIMBOX_PLAN/$PLAN.limit_max.2 $PATH_SVISTOK_SIM_LIMITS/$IMSI.limit_max.2
cp $PATH_SIMBOX_PLAN/$PLAN.limit_max.3 $PATH_SVISTOK_SIM_LIMITS/$IMSI.limit_max.3
cp $PATH_SIMBOX_PLAN/$PLAN.limit_max.4 $PATH_SVISTOK_SIM_LIMITS/$IMSI.limit_max.4
cp $PATH_SIMBOX_PLAN/$PLAN.limit_max.5 $PATH_SVISTOK_SIM_LIMITS/$IMSI.limit_max.5

cp $PATH_SIMBOX_PLAN/$PLAN.limit_max.1 $PATH_SVISTOK_SIM_LIMITS/$IMSI.limit_soft.1
cp $PATH_SIMBOX_PLAN/$PLAN.limit_max.2 $PATH_SVISTOK_SIM_LIMITS/$IMSI.limit_soft.2
cp $PATH_SIMBOX_PLAN/$PLAN.limit_max.3 $PATH_SVISTOK_SIM_LIMITS/$IMSI.limit_soft.3
cp $PATH_SIMBOX_PLAN/$PLAN.limit_max.4 $PATH_SVISTOK_SIM_LIMITS/$IMSI.limit_soft.4
cp $PATH_SIMBOX_PLAN/$PLAN.limit_max.5 $PATH_SVISTOK_SIM_LIMITS/$IMSI.limit_soft.5

cp $PATH_SIMBOX_PLAN/$PLAN.limit_hard.1 $PATH_SVISTOK_SIM_LIMITS/$IMSI.limit_hard.1
cp $PATH_SIMBOX_PLAN/$PLAN.limit_hard.2 $PATH_SVISTOK_SIM_LIMITS/$IMSI.limit_hard.2
cp $PATH_SIMBOX_PLAN/$PLAN.limit_hard.3 $PATH_SVISTOK_SIM_LIMITS/$IMSI.limit_hard.3
cp $PATH_SIMBOX_PLAN/$PLAN.limit_hard.4 $PATH_SVISTOK_SIM_LIMITS/$IMSI.limit_hard.4

cp $PATH_SIMBOX_PLAN/$PLAN.alg.1 $PATH_SVISTOK_SIM_SETTINGS/$IMSI.alg.1
cp $PATH_SIMBOX_PLAN/$PLAN.alg.2 $PATH_SVISTOK_SIM_SETTINGS/$IMSI.alg.2
cp $PATH_SIMBOX_PLAN/$PLAN.alg.3 $PATH_SVISTOK_SIM_SETTINGS/$IMSI.alg.3
cp $PATH_SIMBOX_PLAN/$PLAN.alg.4 $PATH_SVISTOK_SIM_SETTINGS/$IMSI.alg.4

cp $PATH_SIMBOX_PLAN/$PLAN.nodiff.1 $PATH_SVISTOK_SIM_SETTINGS/$IMSI.nodiff.1
cp $PATH_SIMBOX_PLAN/$PLAN.nodiff.2 $PATH_SVISTOK_SIM_SETTINGS/$IMSI.nodiff.2
cp $PATH_SIMBOX_PLAN/$PLAN.nodiff.3 $PATH_SVISTOK_SIM_SETTINGS/$IMSI.nodiff.3
cp $PATH_SIMBOX_PLAN/$PLAN.nodiff.4 $PATH_SVISTOK_SIM_SETTINGS/$IMSI.nodiff.4


cp $PATH_SIMBOX_PLAN/$PLAN.time_work_wake $PATH_SVISTOK_SIM_SETTINGS/$IMSI.time_work_wake
cp $PATH_SIMBOX_PLAN/$PLAN.time_work_sleep $PATH_SVISTOK_SIM_SETTINGS/$IMSI.time_work_sleep

cp $PATH_SIMBOX_PLAN/$PLAN.time_holiday_wake $PATH_SVISTOK_SIM_SETTINGS/$IMSI.time_holiday_wake
cp $PATH_SIMBOX_PLAN/$PLAN.time_holiday_sleep $PATH_SVISTOK_SIM_SETTINGS/$IMSI.time_holiday_sleep


cp $PATH_SIMBOX_PLAN/$PLAN.capnew $PATH_SVISTOK_SIM_SETTINGS/$IMSI.capnew
cp $PATH_SIMBOX_PLAN/$PLAN.capfail $PATH_SVISTOK_SIM_SETTINGS/$IMSI.capfail
cp $PATH_SIMBOX_PLAN/$PLAN.capok $PATH_SVISTOK_SIM_SETTINGS/$IMSI.capok

cp $PATH_SIMBOX_PLAN/$PLAN.priority $PATH_SVISTOK_SIM_SETTINGS/$IMSI.priority
cp $PATH_SIMBOX_PLAN/$PLAN.pro $PATH_SVISTOK_SIM_SETTINGS/$IMSI.pro
echo "cp $PATH_SIMBOX_PLAN/$PLAN.pro $PATH_SVISTOK_SIM_SETTINGS/$IMSI.pro"


cp $PATH_SIMBOX_PLAN/$PLAN.diff_min $PATH_SVISTOK_SIM_SETTINGS/$IMSI.diff_min
cp $PATH_SIMBOX_PLAN/$PLAN.diff_min_out $PATH_SVISTOK_SIM_SETTINGS/$IMSI.diff_min_out
cp $PATH_SIMBOX_PLAN/$PLAN.diff_min_vip $PATH_SVISTOK_SIM_SETTINGS/$IMSI.diff_min_vip
cp $PATH_SIMBOX_PLAN/$PLAN.diff_min_goo $PATH_SVISTOK_SIM_SETTINGS/$IMSI.diff_min_goo
cp $PATH_SIMBOX_PLAN/$PLAN.diff_min_nor $PATH_SVISTOK_SIM_SETTINGS/$IMSI.diff_min_nor
cp $PATH_SIMBOX_PLAN/$PLAN.diff_min_sout $PATH_SVISTOK_SIM_SETTINGS/$IMSI.diff_min_sout
cp $PATH_SIMBOX_PLAN/$PLAN.diff_min_imode $PATH_SVISTOK_SIM_SETTINGS/$IMSI.diff_min_imode


cp $PATH_SIMBOX_PLAN/$PLAN.can_in $PATH_SVISTOK_SIM_SETTINGS/$IMSI.can_in
cp $PATH_SIMBOX_PLAN/$PLAN.can_out $PATH_SVISTOK_SIM_SETTINGS/$IMSI.can_out
cp $PATH_SIMBOX_PLAN/$PLAN.can_sout $PATH_SVISTOK_SIM_SETTINGS/$IMSI.can_sout


cp $PATH_SIMBOX_PLAN/$PLAN.igoo $PATH_SVISTOK_SIM_SETTINGS/$IMSI.igoo
cp $PATH_SIMBOX_PLAN/$PLAN.inor $PATH_SVISTOK_SIM_SETTINGS/$IMSI.inor
cp $PATH_SIMBOX_PLAN/$PLAN.ibad $PATH_SVISTOK_SIM_SETTINGS/$IMSI.ibad
cp $PATH_SIMBOX_PLAN/$PLAN.ine0 $PATH_SVISTOK_SIM_SETTINGS/$IMSI.ine0
cp $PATH_SIMBOX_PLAN/$PLAN.inec $PATH_SVISTOK_SIM_SETTINGS/$IMSI.inec
cp $PATH_SIMBOX_PLAN/$PLAN.inem $PATH_SVISTOK_SIM_SETTINGS/$IMSI.inem
cp $PATH_SIMBOX_PLAN/$PLAN.inew $PATH_SVISTOK_SIM_SETTINGS/$IMSI.inew


cp $PATH_SIMBOX_PLAN/$PLAN.inos $PATH_SVISTOK_SIM_SETTINGS/$IMSI.inos
cp $PATH_SIMBOX_PLAN/$PLAN.iblo $PATH_SVISTOK_SIM_SETTINGS/$IMSI.iblo
cp $PATH_SIMBOX_PLAN/$PLAN.irob $PATH_SVISTOK_SIM_SETTINGS/$IMSI.irob
cp $PATH_SIMBOX_PLAN/$PLAN.ivip $PATH_SVISTOK_SIM_SETTINGS/$IMSI.ivip
cp $PATH_SIMBOX_PLAN/$PLAN.notvip $PATH_SVISTOK_SIM_SETTINGS/$IMSI.notvip

cp $PATH_SIMBOX_PLAN/$PLAN.imn $PATH_SVISTOK_SIM_SETTINGS/$IMSI.imn
cp $PATH_SIMBOX_PLAN/$PLAN.ima $PATH_SVISTOK_SIM_SETTINGS/$IMSI.ima
cp $PATH_SIMBOX_PLAN/$PLAN.imb $PATH_SVISTOK_SIM_SETTINGS/$IMSI.imb
cp $PATH_SIMBOX_PLAN/$PLAN.imc $PATH_SVISTOK_SIM_SETTINGS/$IMSI.imc
cp $PATH_SIMBOX_PLAN/$PLAN.imd $PATH_SVISTOK_SIM_SETTINGS/$IMSI.imd
cp $PATH_SIMBOX_PLAN/$PLAN.ime $PATH_SVISTOK_SIM_SETTINGS/$IMSI.ime

cp $PATH_SIMBOX_PLAN/$PLAN.forwarding $PATH_SVISTOK_SIM_SETTINGS/$IMSI.forwarding
cp $PATH_SIMBOX_PLAN/$PLAN.outin $PATH_SVISTOK_SIM_SETTINGS/$IMSI.outin
cp $PATH_SIMBOX_PLAN/$PLAN.in_wait $PATH_SVISTOK_SIM_SETTINGS/$IMSI.in_wait
cp $PATH_SIMBOX_PLAN/$PLAN.in_sound $PATH_SVISTOK_SIM_SETTINGS/$IMSI.in_sound

cp $PATH_SIMBOX_PLAN/$PLAN.i_mode $PATH_SVISTOK_SIM_SETTINGS/$IMSI.i_mode




cp $PATH_SIMBOX_PLAN/$PLAN.iatt_soft     $PATH_SIMBOX_SIM_SETTINGS/$IMSI.iatt_soft
cp $PATH_SIMBOX_PLAN/$PLAN.iatt_min     $PATH_SIMBOX_SIM_SETTINGS/$IMSI.iatt_min
cp $PATH_SIMBOX_PLAN/$PLAN.iatt_max     $PATH_SIMBOX_SIM_SETTINGS/$IMSI.iatt_max
cp $PATH_SIMBOX_PLAN/$PLAN.out_in_ans   $PATH_SIMBOX_SIM_SETTINGS/$IMSI.out_in_ans
cp $PATH_SIMBOX_PLAN/$PLAN.out_in_dur   $PATH_SIMBOX_SIM_SETTINGS/$IMSI.out_in_dur
cp $PATH_SIMBOX_PLAN/$PLAN.in_acd_min   $PATH_SIMBOX_SIM_SETTINGS/$IMSI.in_acd_min
cp $PATH_SIMBOX_PLAN/$PLAN.in_acd_max   $PATH_SIMBOX_SIM_SETTINGS/$IMSI.in_acd_max
cp $PATH_SIMBOX_PLAN/$PLAN.out_acd_min  $PATH_SIMBOX_SIM_SETTINGS/$IMSI.out_acd_min
cp $PATH_SIMBOX_PLAN/$PLAN.out_acd_max  $PATH_SIMBOX_SIM_SETTINGS/$IMSI.out_acd_max

cp $PATH_SIMBOX_PLAN/$PLAN.satt_soft        $PATH_SIMBOX_SIM_SETTINGS/$IMSI.satt_soft
cp $PATH_SIMBOX_PLAN/$PLAN.satt_soft_day    $PATH_SIMBOX_SIM_SETTINGS/$IMSI.satt_soft_day
cp $PATH_SIMBOX_PLAN/$PLAN.satt_soft_total  $PATH_SIMBOX_SIM_SETTINGS/$IMSI.satt_soft_total


cp $PATH_SIMBOX_PLAN/$PLAN.satt_hard        $PATH_SIMBOX_SIM_SETTINGS/$IMSI.satt_hard
cp $PATH_SIMBOX_PLAN/$PLAN.satt_hard_day    $PATH_SIMBOX_SIM_SETTINGS/$IMSI.satt_hard_day
cp $PATH_SIMBOX_PLAN/$PLAN.satt_hard_total  $PATH_SIMBOX_SIM_SETTINGS/$IMSI.satt_hard_total


cp $PATH_SIMBOX_PLAN/$PLAN.smsout_soft        $PATH_SIMBOX_SIM_SETTINGS/$IMSI.smsout_soft
cp $PATH_SIMBOX_PLAN/$PLAN.smsout_hard        $PATH_SIMBOX_SIM_SETTINGS/$IMSI.smsout_hard

cp $PATH_SIMBOX_PLAN/$PLAN.may_limit        $PATH_SIMBOX_SIM_SETTINGS/$IMSI.may_limit
cp $PATH_SIMBOX_PLAN/$PLAN.mon_limit        $PATH_SIMBOX_SIM_SETTINGS/$IMSI.mon_limit
cp $PATH_SIMBOX_PLAN/$PLAN.msm_limit        $PATH_SIMBOX_SIM_SETTINGS/$IMSI.msm_limit

cp $PATH_SIMBOX_PLAN/$PLAN.nospam        $PATH_SIMBOX_SIM_SETTINGS/$IMSI.nospam