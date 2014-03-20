#!/bin/sh

DONGLE=$1
IMSI=$2
OPERATOR="mts_spb"

. /usr/src/ast/config/config.sh

echo "Init tariff for $DONGLE:$IMSI $OPERATOR"


$ASTERISK -r -x "dongle ussd $DONGLE *111*777#"
sleep 20
$ASTERISK -r -x "dongle ussd $DONGLE 2"
#sleep 60
#Restartanut svistok