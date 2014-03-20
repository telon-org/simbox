#!/bin/sh

. /usr/simbox/config.sh
. /usr/simbox/nabor/velcom/config.sh

echo "-- Getting tarif"
$ASTERISK -r -x "dongle ussd $DONGLE *141*3*4#"