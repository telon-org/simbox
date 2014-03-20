#!/bin/sh

. /usr/simbox/config.sh
. /usr/simbox/nabor/mts_spb/config.sh

echo "-- Getting number"
/usr/simbox/system/send.sh "ussd" "LOC" "$DONGLE" "*111*0887#" ""
