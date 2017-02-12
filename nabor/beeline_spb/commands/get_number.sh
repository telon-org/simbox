#!/bin/sh

. /usr/simbox/config.sh
. /usr/simbox/nabor/beeline_spb/config.sh

echo "-- Getting number"
/usr/simbox/system/send.sh "ussd" "LOC" "$DONGLE" "*110*10#" ""

#/usr/simbox/system/send.sh "ussd" "LOC" "$DONGLE" "*110*1*1*2#" ""
#$ASTERISK -r -x "dongle ussd $DONGLE *110*1*1*2#"