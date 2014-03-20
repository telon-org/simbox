#!/bin/sh

renice 19 -p $$
ionice -c3 -p $$

/usr/simbox/ai/block/find_high_datt.sh
/usr/simbox/ai/block/find_low_acdl.sh
/usr/simbox/ai/block/block.sh

/usr/simbox/ai/samsebe/find_in_done.sh
/usr/simbox/ai/samsebe/find_need_in.sh


/usr/simbox/ai/sms/find_sms_done.sh
/usr/simbox/ai/sms/find_need_sms.sh


/usr/simbox/ai/samsebe/makecall_need_in.sh &
sleep 20
/usr/simbox/ai/samsebe/makecall_need_in.sh &
sleep 20
/usr/simbox/ai/samsebe/makecall_need_in.sh &
sleep 20
/usr/simbox/ai/samsebe/makecall_need_in.sh &
sleep 20