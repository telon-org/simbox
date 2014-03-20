#!/bin/sh

renice 19 -p $$
ionice -c3 -p $$

#SMS 0 patch!!!
/usr/bin/find /var/simbox/sim/settings/*.smsout_sended -exec rm -v {} \; &

/usr/simbox/nabor/tele2_spb/commands/disable209.php


/usr/simbox/nabor/beeline_spb/commands/setdaylimit.sh
/usr/simbox/nabor/tele2_spb/commands/setlimit_newday.php
/usr/simbox/nabor/megafon_spb/commands/setdaylimit_set.sh


/usr/simbox/system/clearlogs.sh

#/usr/simbox/system/balanceyesterday.sh &

/usr/bin/find /var/simbox/sim/settings/ -mmin +432000 -exec rm -v {} \;
/usr/bin/find /var/svistok/sim/state/ -mmin +432000 -exec rm -v {} \;
/usr/bin/find /var/svistok/sim/settings/ -mmin +432000 -exec rm -v {} \;
/usr/bin/find /var/svistok/sim/statistics/ -mmin +432000 -exec rm -v {} \;
/usr/bin/find /var/svistok/sim/ -mmin +432000 -exec rm -v {} \;



#chmod -R 0777 /var/simbox/
#chmod -R 0777 /var/svistok/
