#!/bin/sh

. /usr/simbox/config.sh
. /usr/simbox/nabor/megafon_msk/config.sh

echo "-- Getting balance"

$ASTERISK -r -x "dongle ussd $DONGLE *100#"