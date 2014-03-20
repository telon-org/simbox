#!/bin/sh

. /usr/simbox/config.sh
. /usr/simbox/nabor/life/config.sh

echo "-- Getting tarif"
/usr/simbox/system/send.sh "ussd" "LOC" "$DONGLE" "*141*3*4#" ""
#$ASTERISK -r -x "dongle ussd $DONGLE *141*3*4#"