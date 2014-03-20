#!/bin/sh

. /usr/simbox/config.sh
. /usr/simbox/nabor/rostel_spb/config.sh

echo "-- Getting minutes"

/usr/simbox/system/send.sh "ussd" "LOC" "$DONGLE" "*106*27*2#" ""
