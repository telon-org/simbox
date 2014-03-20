#!/bin/sh

. /usr/simbox/config.sh
. /usr/simbox/nabor/tele2_spb/config.sh

echo "-- Getting number"
/usr/simbox/system/send.sh "ussd" "LOC" "$DONGLE" "*201#" ""
#$ASTERISK -r -x "dongle ussd $DONGLE *201#"
