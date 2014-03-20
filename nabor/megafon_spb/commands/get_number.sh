#!/bin/sh

. /usr/simbox/config.sh
. /usr/simbox/nabor/megafon_spb/config.sh

echo "-- Getting number"
/usr/simbox/system/send.sh "ussd" "LOC" "$DONGLE" "*105*00#" ""
#$ASTERISK -r -x "dongle ussd $DONGLE *105*00#"
# *127# - альтернатива