#!/bin/sh

. /usr/simbox/config.sh
. /usr/simbox/nabor/kievstar/config.sh

echo "-- Getting balance"

$ASTERISK -r -x "dongle ussd $DONGLE *111#"