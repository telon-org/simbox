#!/bin/sh

PLAN=`cat $PATH_SIMBOX_SIM_SETTINGS/$IMSI.plan`
echo "-- PLAN=$PLAN"
NABOR=`cat $PATH_SIMBOX_PLAN/$PLAN.nabor`
echo "-- NABOR=$NABOR"
