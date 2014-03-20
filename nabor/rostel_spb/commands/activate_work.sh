#!/bin/sh

. /usr/simbox/config.sh
. /usr/simbox/nabor/rostel_spb/config.sh

echo "-- Activate Work"

/usr/simbox/system/send.sh "ussd" "LOC" "$DONGLE" "*106*27*1#" ""
