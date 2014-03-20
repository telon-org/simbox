#!/bin/sh


DONGLE=$1
NUMBER=$2

TEMP=`mktemp /tmp/call_XXXXXXXXXXXX`.call

#Channel: Local/$NUMBER@maingateway
#Extension: $number
#Context: callsebe

#Dongle/L0>=$DONGLE/$NUMBER

cat <<EOF > $TEMP
Channel: Local/$NUMBER@maingateway 
Extension: $NUMBER
Context: samsebeout-test
Priority: 1
EOF

#chown asterisk:asterisk $TEMP
mv $TEMP /var/spool/asterisk/outgoing/

