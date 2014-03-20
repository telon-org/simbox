#!/bin/sh

. /usr/simbox/config.sh
. /usr/simbox/nabor/velcom/config.sh

echo "-- Getting number [fork]"
sleep 20
$ASTERISK -r -x "dongle ussd $DONGLE 1"
sleep 20
$ASTERISK -r -x "dongle ussd $DONGLE 0"
sleep 20
$ASTERISK -r -x "dongle ussd $DONGLE 3"
sleep 20
$ASTERISK -r -x "dongle ussd $DONGLE 1"