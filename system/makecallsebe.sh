#!/bin/sh


DONGLE=$1
NUMBER=$2   #TO
IMSI=$3     #TO

#echo -n "1" > /tmp/$IMSI.sout

TEMP=`mktemp /tmp/call_XXXXXXXXXXXX`.call


cat <<EOF > $TEMP
Channel: Local/$NUMBER#SOU$IMSI@maingateway 
Extension: $NUMBER
Context: samsebe-out
Priority: 1
EOF

mv $TEMP /var/spool/asterisk/outgoing/












#Channel: Local/$NUMBER@maingateway
#Extension: $number
#Context: callsebe

#Dongle/L0>=$DONGLE/$NUMBER
