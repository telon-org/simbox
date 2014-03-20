#!/bin/sh

. /usr/simbox/config.sh
. /usr/simbox/nabor/velcom/config.sh

echo "-- Getting number"
$ASTERISK -r -x "dongle ussd $DONGLE *147#"
