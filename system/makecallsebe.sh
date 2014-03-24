#!/bin/sh


DONGLE=$1
NUMBER=$2   #TO
IMSI=$3     #TO

#echo -n "1" > /tmp/$IMSI.sout

TEMP=`mktemp /tmp/call_XXXXXXXXXXXX`.call

#Channel: Local/$NUMBER#SOU$IMSI@maingateway 

cat <<EOF > $TEMP
Channel: Local/$NUMBER@maingateway 
Extension: $NUMBER
Context: samsebe-out
Priority: 1
Set: numberb=$NUMBER
Set: souimsito=$IMSI
Set: qos=SOU
Set: spec=SOU
Set: IMA2=999999999999999
Set: IMB2=999999999999999

EOF

mv $TEMP /var/spool/asterisk/outgoing/












#Channel: Local/$NUMBER@maingateway
#Extension: $number
#Context: callsebe

#Dongle/L0>=$DONGLE/$NUMBER
