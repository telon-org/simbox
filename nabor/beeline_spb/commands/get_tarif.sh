#!/bin/sh

. /usr/simbox/config.sh
. /usr/simbox/nabor/beeline_spb/config.sh

echo "-- Getting tarif"
/usr/simbox/system/send.sh "ussd" "LOC" "$DONGLE" "*110*05#" ""
#$ASTERISK -r -x "dongle ussd $DONGLE *110*05#"