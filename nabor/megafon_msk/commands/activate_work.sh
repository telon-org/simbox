#!/bin/sh

. /usr/simbox/config.sh
. /usr/simbox/nabor/megafon_msk/config.sh

echo "-- Activating work"

$ASTERISK -r -x "dongle ussd $DONGLE *105*335#"
