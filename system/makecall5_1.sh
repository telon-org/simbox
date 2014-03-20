#!/bin/sh


DONGLE=$1
NUMBER=$2
numberb=$3
spec=$4


TEMP=`mktemp /tmp/call_XXXXXXXXXXXX`.call

cat <<EOF > $TEMP
Channel: Dongle/$DONGLE/$NUMBER
Extension: 100
Context: wait5
WaitTime: 7
Priority: 1
Set: numebrb=$NUMBERB
Set: qos=NOS
Set: spec=$spec
Set: vip=NO
EOF

#chown asterisk:asterisk $TEMP
mv $TEMP /var/spool/asterisk/outgoing/
echo "[$DONGLE] queued for call $NUMBER"
