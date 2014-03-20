#!/bin/sh

. /usr/simbox/config.sh
. /usr/simbox/nabor/beeline_spb/config.sh

echo "-- Activating sim"

/usr/simbox/system/send.sh "ussd" "LOC" "$DONGLE" "*101*1111#" ""
#$ASTERISK -r -x "dongle ussd $DONGLE *101*1111#"