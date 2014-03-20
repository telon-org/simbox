#!/bin/sh

. /usr/simbox/config.sh
. /usr/simbox/nabor/kievstar/config.sh

echo "-- Activating sim"

$MAKECALL $DONGLE 466
. /usr/simbox/nabor/kievstar/commands/activate_sim_fork.sh &