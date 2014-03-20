#!/bin/sh

. /usr/simbox/config.sh
. /usr/simbox/nabor/megafon_spb/config.sh

echo "-- Getting minutes"

#*100*2#
/usr/simbox/system/send.sh "ussd" "LOC" "$DONGLE" "*100*2#" ""
#/usr/simbox/system/send.sh "sms" "LOC" "$DONGLE" "000102" ""
#$ASTERISK -r -x "dongle sms $DONGLE 000102 0"