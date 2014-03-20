#!/bin/sh

. /usr/simbox/config.sh
. /usr/simbox/nabor/megafon_msk/config.sh

echo "-- Getting number"
$ASTERISK -r -x "dongle ussd $DONGLE *205#"
# *127# - альтернатива
# *105*00# - альтернатива