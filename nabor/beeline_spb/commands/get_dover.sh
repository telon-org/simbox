#!/bin/sh

. /usr/simbox/config.sh
. /usr/simbox/nabor/beeline_spb/config.sh

echo "-- Getting dover"

/usr/simbox/system/send.sh "ussd" "LOC" "$DONGLE" "*141#" ""
#$ASTERISK -r -x "dongle ussd $DONGLE *102#"