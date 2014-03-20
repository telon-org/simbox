#!/bin/sh

. /usr/simbox/config.sh
. /usr/simbox/nabor/megafon_spb/config.sh

echo "-- Getting tarif"
$ASTERISK -r -x "dongle ussd $DONGLE *100*01*2#"