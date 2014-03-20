#!/bin/sh

. /usr/simbox/config.sh
. /usr/simbox/nabor/tele2_spb/config.sh

echo "-- Getting dover"

/usr/simbox/system/send.sh "ussd" "LOC" "$DONGLE" "*122*1#" ""
#$ASTERISK -r -x "dongle ussd $DONGLE *105#"