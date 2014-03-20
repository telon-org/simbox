#!/bin/sh

mv /var/log/asterisk/ussd.txt /var/log/asterisk/ussd.txt.tmp
mv /var/log/asterisk/sms.txt /var/log/asterisk/sms.txt.tmp


/usr/simbox/nabor/beeline_spb/parse/all.sh
/usr/simbox/nabor/megafon_spb/parse/all.sh
/usr/simbox/nabor/megafon_msk/parse/all.sh
/usr/simbox/nabor/mts_spb/parse/all.sh
/usr/simbox/nabor/tele2_spb/parse/all.sh
/usr/simbox/nabor/kievstar/parse/all.sh
/usr/simbox/nabor/velcom/parse/all.sh
/usr/simbox/nabor/life/parse/all.sh

#/usr/src/ast/scripts/parse/parsebalance.sh
#/usr/src/ast/scripts/parse/parseinit.sh
#/usr/src/ast/scripts/parse/parseoptions.sh
#/usr/src/ast/scripts/parse/parsenumber.sh
#/usr/src/ast/scripts/parse/parseblocked.sh
#/usr/src/ast/scripts/parse/parseraspred.sh
#/usr/src/ast/operators/mts_spb/parse/all.sh


cat /var/log/asterisk/ussd.txt.tmp >> /var/log/asterisk/ussd.txt.full
rm /var/log/asterisk/ussd.txt.tmp

cat /var/log/asterisk/sms.txt.tmp >> /var/log/asterisk/sms.txt.full
rm /var/log/asterisk/sms.txt.tmp

/usr/simbox/system/balance_diff.php