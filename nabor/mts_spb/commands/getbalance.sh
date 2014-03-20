#!/bin/sh

DONGLE=$1
IMSI=$2
OPERATOR="mts_spb"

. /usr/src/ast/config/config.sh

echo "Getting number for $DONGLE:$IMSI $OPERATOR"

$ASTERISK -r -x "dongle ussd $DONGLE *100#"