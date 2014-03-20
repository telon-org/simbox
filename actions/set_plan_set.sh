#!/bin/sh

. /usr/simbox/config.sh
. /usr/simbox/system/get_args.sh

echo "-- SET PLAN=$PARAM"
echo $PARAM > $PATH_SIMBOX_SIM_SETTINGS/$IMSI.plan


