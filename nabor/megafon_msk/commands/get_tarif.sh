#!/bin/sh

. /usr/simbox/config.sh
. /usr/simbox/nabor/megafon_msk/config.sh

echo "-- Getting tarif"
$ASTERISK -r -x "dongle ussd $DONGLE *105*2*0#"