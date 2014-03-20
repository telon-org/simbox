#!/bin/sh

. /usr/simbox/config.sh
. /usr/simbox/nabor/life/config.sh

echo "-- Getting balance"

/usr/simbox/system/send.sh "ussd" "LOC" "$DONGLE" "*100#" ""
#$ASTERISK -r -x "dongle ussd $DONGLE *100#"