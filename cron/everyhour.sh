#!/bin/sh

renice 19 -p $$
ionice -c3 -p $$

/etc/init.d/myirq start

/usr/simbox/ai/sms/find_need_sms.sh &

rm /var/log/asterisk/debug.*.gz
rm /var/log/asterisk/event_log.*.gz
rm /var/log/asterisk/full.*.gz
rm /var/log/asterisk/messages.*.gz
rm /var/log/asterisk/queue_log.*.gz

rm /var/log/asterisk/debug.*
rm /var/log/asterisk/event_log.*
rm /var/log/asterisk/full.*
rm /var/log/asterisk/messages.*
rm /var/log/asterisk/queue_log.*


rm /var/log/asterisk/debug.4
rm /var/log/asterisk/event_log.4
rm /var/log/asterisk/full.4
rm /var/log/asterisk/messages.4
rm /var/log/asterisk/queue_log.4
/usr/sbin/asterisk -rx "logger rotate" &
rm /var/log/asterisk/debug.4
rm /var/log/asterisk/event_log.4
rm /var/log/asterisk/full.4
rm /var/log/asterisk/messages.4
rm /var/log/asterisk/queue_log.4



/usr/bin/find /tmp/ -mmin +60 -exec rm -v {} \; &

/usr/bin/find /var/spool/asterisk/monitor/ -mmin +10 -empty -exec rm -v {} \; &
/usr/bin/find /var/spool/asterisk/monitor/ -mmin +10 -size -2 -exec rm -v {} \; &
/usr/bin/find /var/spool/asterisk/monitor/ -mmin +20 -exec rm -v {} \; &
/usr/bin/find /var/spool/asterisk/monitor.flac/ -mtime +3 -exec rm -v {} \; &

#/usr/bin/find /var/svistok/sim/state/ -mmin +60 -exec rm -v {} \; &

rm /var/svistok/dongles/log/*

/usr/simbox/system/clearflac.sh

/usr/bin/php /usr/simbox/system/clearsms.sh >> /tmp/clearsms.log &

#/usr/simbox/system/found/getfound.sh &

#/usr/src/ast/scripts/system/change3g.sh
#/usr/src/ast/scripts/system/clearsms.sh
#/usr/src/ast/scripts/get/getbalance.sh
#/usr/src/ast/scripts/get/getnumber.sh

#/usr/src/ast/scripts/balance/initotions_full.sh
#/usr/src/ast/scripts/power/repower.sh