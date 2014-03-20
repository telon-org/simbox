#!/bin/sh

. /usr/simbox/config.sh
. /usr/simbox/nabor/megafon_msk/config.sh

echo "-- Activating sim"

$ASTERISK -r -x "dongle ussd $DONGLE *926*1*1#"
#sleep 10
#$ASTERISK -r -x "dongle ussd $DONGLE 1"