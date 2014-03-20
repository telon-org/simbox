#!/bin/sh

. /usr/simbox/config.sh
. /usr/simbox/nabor/tele2_spb/config.sh

echo "-- Getting minutes"

/usr/simbox/system/send.sh "ussd" "LOC" "$DONGLE" "*116*17#" ""
#$ASTERISK -r -x "dongle ussd $DONGLE *116*17#"