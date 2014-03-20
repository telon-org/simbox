#!/bin/sh

. /usr/simbox/config.sh
. /usr/simbox/nabor/kievstar/config.sh

echo "-- Activating work"

$ASTERISK -r -x "dongle ussd $DONGLE *100*77#"
