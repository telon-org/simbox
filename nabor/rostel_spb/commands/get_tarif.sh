#!/bin/sh

. /usr/simbox/config.sh
. /usr/simbox/nabor/rostel_spb/config.sh

echo "-- Getting tarif"
/usr/simbox/system/send.sh "ussd" "LOC" "$DONGLE" "*100*42#" ""