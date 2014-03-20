#!/bin/sh


echo "ustarelo"

exit

. /usr/simbox/config.sh

DONGLE=$1
IMSI=$2
PARAM=$3

echo "-- Set plan"

echo "$PARAM" > $DIR_SIM_SETTINGS_SIMBOX/$IMSI.plan

cp $DIR_PLAN/$PARAM.ibad $DIR_SIM_SETTINGS_SVISTOK/$IMSI.ibad
cp $DIR_PLAN/$PARAM.igoo $DIR_SIM_SETTINGS_SVISTOK/$IMSI.igoo
cp $DIR_PLAN/$PARAM.inew $DIR_SIM_SETTINGS_SVISTOK/$IMSI.ibew
cp $DIR_PLAN/$PARAM.inor $DIR_SIM_SETTINGS_SVISTOK/$IMSI.inor
cp $DIR_PLAN/$PARAM.inos $DIR_SIM_SETTINGS_SVISTOK/$IMSI.inos

cp $DIR_PLAN/$PARAM.limit_max.1 $DIR_SIM_SETTINGS_SIMBOX/$IMSI.limit_max.1
cp $DIR_PLAN/$PARAM.limit_max.2 $DIR_SIM_SETTINGS_SIMBOX/$IMSI.limit_max.2

cp $DIR_PLAN/$PARAM.iatt_min     $DIR_SIM_SETTINGS_SIMBOX/$IMSI.iatt_min
cp $DIR_PLAN/$PARAM.iatt_max     $DIR_SIM_SETTINGS_SIMBOX/$IMSI.iatt_max
cp $DIR_PLAN/$PARAM.out_in_ans   $DIR_SIM_SETTINGS_SIMBOX/$IMSI.out_in_ans
cp $DIR_PLAN/$PARAM.out_in_dur   $DIR_SIM_SETTINGS_SIMBOX/$IMSI.out_in_dur
cp $DIR_PLAN/$PARAM.in_acd_min   $DIR_SIM_SETTINGS_SIMBOX/$IMSI.in_acd_min
cp $DIR_PLAN/$PARAM.in_acd_max   $DIR_SIM_SETTINGS_SIMBOX/$IMSI.in_acd_max
cp $DIR_PLAN/$PARAM.out_acd_min  $DIR_SIM_SETTINGS_SIMBOX/$IMSI.out_acd_min
cp $DIR_PLAN/$PARAM.out_acd_max  $DIR_SIM_SETTINGS_SIMBOX/$IMSI.out_acd_max

cp $DIR_PLAN/$PARAM.satt_min     $DIR_SIM_SETTINGS_SIMBOX/$IMSI.satt_min
cp $DIR_PLAN/$PARAM.satt_max     $DIR_SIM_SETTINGS_SIMBOX/$IMSI.satt_max

echo "cp $DIR_PLAN/$PARAM.satt_min     $DIR_SIM_SETTINGS_SIMBOX/$IMSI.satt_min"