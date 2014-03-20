#!/bin/sh

. /usr/simbox/config.sh
. /usr/simbox/nabor/beeline_spb/config.sh

#usage send_may dongle123 noimsi 79265555555

# PARAM=$3
echo "-- Sending MAY"


/usr/simbox/system/send.sh "ussd" "LO2" "$DONGLE" "*144*$PARAM#" ""
