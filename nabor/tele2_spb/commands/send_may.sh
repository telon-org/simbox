#!/bin/sh

. /usr/simbox/config.sh
. /usr/simbox/nabor/tele2_spb/config.sh

#usage send_may dongle123 noimsi 79265555555

#PARAM=$3
echo "-- Sending MAY"

PARAM=`echo "$PARAM+10000000000" | bc`
#/usr/simbox/system/send.sh "ussd" "LO2" "$DONGLE" "*118*$PARAM#" ""
