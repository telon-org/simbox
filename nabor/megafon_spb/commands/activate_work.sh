#!/bin/sh

. /usr/simbox/config.sh
. /usr/simbox/nabor/megafon_spb/config.sh

echo "-- Activating work"

/usr/simbox/system/send.sh "ussd" "LOC" "$DONGLE" "*105*0082#" ""
sleep 7
/usr/simbox/system/send.sh "ussd" "LOC" "$DONGLE" "1" ""
#$ASTERISK -r -x "dongle ussd $DONGLE *162#"