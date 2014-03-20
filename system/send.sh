#!/bin/bash

TYPE=$1  #sms, ussd, ussdend, may,///
SPEC=$2  #
DONGLE=$3
NUMBER=$4
TEXT=$5

DONGLEIMSI=`cat /var/svistok/dongles/state/$DONGLE.imsi`
NOW=`date +"%Y-%m-%d %H:%M:%S"`
TEXT64=`echo "$TEXT" | base64 --wrap=0`

echo "-- Sending $TYPE $SPEC $DONGLE $NUMBER $TEXT"

if [ "$TYPE" == "sms" ]
then
echo "SMS|O|$SPEC|$NOW|$DONGLE|$DONGLEIMSI|$NUMBER|$TEXT64" >> /var/svistok/sim/log/$DONGLEIMSI.smsussd2
/usr/sbin/asterisk -rx "dongle sms $DONGLE $NUMBER $TEXT"
fi

if [ "$TYPE" == "ussd" ]
then
echo "USSD|O|$SPEC|$NOW|$DONGLE|$DONGLEIMSI|$NUMBER|$TEXT64" >> /var/svistok/sim/log/$DONGLEIMSI.smsussd2
/usr/sbin/asterisk -rx "dongle ussd $DONGLE $NUMBER"
fi

if [ "$TYPE" == "ussdend" ]
then
#/usr/sbin/asterisk -rx "dongle ussd $DONGLE $NUMBER"
echo "not defined"
fi