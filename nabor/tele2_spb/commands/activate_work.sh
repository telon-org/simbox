#!/bin/sh

. /usr/simbox/config.sh
. /usr/simbox/nabor/tele2_spb/config.sh

echo "-- Activate work new"
/usr/simbox/system/send.sh "ussd" "LOC" "$DONGLE" "*116*51#" ""
