#!/bin/sh

. /usr/simbox/config.sh
. /usr/simbox/nabor/tele2_spb/config.sh

echo "-- Entering pin"


# AT+CPIN="0000";+CLCK="SC",0,"0000";+CFUN=1,1
# AT+CPIN=\"0000\";+CLCK=\"SC\",0,\"0000\";+CFUN=1,1

atcommand='AT+CPIN=\\"0000\\";+CLCK=\\"SC\\",0,\\"0000\\";+CFUN=1,1'
command="/usr/sbin/asterisk -rx 'dongle cmd $DONGLE $atcommand'"
echo $command
r=`$command`
echo $r

