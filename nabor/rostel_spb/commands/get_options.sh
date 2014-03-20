#!/bin/sh

. /usr/simbox/config.sh
. /usr/simbox/nabor/rostel_spb/config.sh

echo "-- Getting options"

/usr/simbox/system/send.sh "ussd" "LOC" "$DONGLE" "*109*100*1#" ""
