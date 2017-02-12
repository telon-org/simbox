#!/bin/sh

renice 19 -p $$
ionice -c3 -p $$

#/usr/src/ast/scripts/system/checkdevices.sh &
#/usr/src/ast/script/system/clearsms.sh
#/usr/src/ast/scripts/stat/100.sh &

/usr/simbox/ai/ai.sh &

/usr/bin/php /usr/nanoproxy/nanoproxy.node.sim/www/nanoproxy/check.php > /tmp/nanoproxy_check.log & 