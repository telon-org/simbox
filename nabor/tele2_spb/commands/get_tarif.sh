#!/bin/sh

. /usr/simbox/config.sh
. /usr/simbox/nabor/tele2_spb/config.sh

echo "-- Getting tarif"
/usr/simbox/system/send.sh "ussd" "LOC" "$DONGLE" "*108#" ""
#$ASTERISK -r -x "dongle ussd $DONGLE *108#"