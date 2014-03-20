#!/bin/sh

. /usr/simbox/config.sh
. /usr/simbox/nabor/tele2_spb/config.sh

echo "-- Getting options"

/usr/simbox/system/send.sh "ussd" "LOC" "$DONGLE" "*155*21#" ""
