#!/bin/sh

. /usr/simbox/config.sh
. /usr/simbox/nabor/megafon_spb/config.sh

echo "-- Activating sim"

/usr/simbox/system/send.sh "ussd" "LOC" "$DONGLE" "*162#" ""
#$ASTERISK -r -x "dongle ussd $DONGLE *162#"