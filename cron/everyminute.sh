#!/bin/sh

renice 19 -p $$
ionice -c3 -p $$

/usr/simbox/cron/checknewday.sh &
/usr/simbox/system/checkasterisk.sh &
/usr/simbox/ai/watchdog/watchdog.sh &
/usr/simbox/system/parseussdsms.sh > /tmp/parseussdsms.log &


#/usr/src/ast/scripts/stat/checkacd.sh
#/usr/src/ast/scripts/stat/makestat.sh