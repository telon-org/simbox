#!/bin/sh

. /usr/simbox/config.sh
. /usr/simbox/nabor/life/config.sh

echo "-- Activating work"

/usr/simbox/system/send.sh "ussd" "LOC" "$DONGLE" "*110*1*3*1#" ""
#$ASTERISK -r -x "dongle ussd $DONGLE *110*1*3*1#"
