#!/bin/sh

. /usr/simbox/config.sh
. /usr/simbox/nabor/velcom/config.sh

echo "-- Getting number"
/usr/simbox/system/send.sh "ussd" "LOC" "$DONGLE" "*147#" ""
#$ASTERISK -r -x "dongle ussd $DONGLE *147#"
