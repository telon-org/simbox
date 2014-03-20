#!/bin/sh

. /usr/simbox/config.sh

list=`cat $FILE_IMSILIST`

for imsi in $list
do


group=`cat $PATH_SVISTOK_SIM_SETTINGS/$imsi.group`

#if [ "$group" -eq 109 ] ; then
#echo "$imsi $operator"
#cp $PATH_SIMBOX_PLAN/$PLAN.may_limit        $PATH_SIMBOX_SIM_SETTINGS/$IMSI.may_limit
#cp $PATH_SIMBOX_PLAN/$PLAN.mon_limit        $PATH_SIMBOX_SIM_SETTINGS/$IMSI.mon_limit
#cp $PATH_SIMBOX_PLAN/$PLAN.msm_limit        $PATH_SIMBOX_SIM_SETTINGS/$IMSI.msm_limit
#fi

#if [ "$group" -eq 209 ] ; then
#echo "$imsi $operator"
#cp $PATH_SIMBOX_PLAN/$PLAN.may_limit        $PATH_SIMBOX_SIM_SETTINGS/$IMSI.may_limit
#cp $PATH_SIMBOX_PLAN/$PLAN.mon_limit        $PATH_SIMBOX_SIM_SETTINGS/$IMSI.mon_limit
#cp $PATH_SIMBOX_PLAN/$PLAN.msm_limit        $PATH_SIMBOX_SIM_SETTINGS/$IMSI.msm_limit
#fi

#if [ "$group" -eq 210 ] ; then
#echo "$imsi $operator"
#cp $PATH_SIMBOX_PLAN/$PLAN.may_limit        $PATH_SIMBOX_SIM_SETTINGS/$IMSI.may_limit
#cp $PATH_SIMBOX_PLAN/$PLAN.mon_limit        $PATH_SIMBOX_SIM_SETTINGS/$IMSI.mon_limit
#cp $PATH_SIMBOX_PLAN/$PLAN.msm_limit        $PATH_SIMBOX_SIM_SETTINGS/$IMSI.msm_limit
#fi


done


#cp /var/svistok/sim/limits/$imsi.limit_soft.1 /var/svistok/sim/limits/$imsi.limit.1
#cp /var/svistok/sim/limits/$imsi.limit_soft.2 /var/svistok/sim/limits/$imsi.limit.2
#cp /var/svistok/sim/limits/$imsi.limit_soft.3 /var/svistok/sim/limits/$imsi.limit.3
#cp /var/svistok/sim/limits/$imsi.limit_soft.4 /var/svistok/sim/limits/$imsi.limit.4
#cp /var/svistok/sim/limits/$imsi.limit_soft.5 /var/svistok/sim/limits/$imsi.limit.5
