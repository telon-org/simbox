#!/bin/sh

. /usr/simbox/config.sh
. /usr/simbox/nabor/megafon_spb/config.sh

echo "-- Activating work"

/usr/simbox/system/makecalldtmf.sh $DONGLE 0206 wwww1wwwwww1wwww