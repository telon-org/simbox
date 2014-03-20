#!/bin/sh

. /usr/simbox/config.sh
. /usr/simbox/nabor/megafon_spb/config.sh

echo "-- Getting dover"

/usr/simbox/system/send.sh "ussd" "LOC" "$DONGLE" "*106#" ""
sleep 15
/usr/simbox/system/send.sh "ussd" "LOC" "$DONGLE" "100" ""
sleep 30
/usr/simbox/system/send.sh "sms" "LOC" "$DONGLE" "0006" "100"
