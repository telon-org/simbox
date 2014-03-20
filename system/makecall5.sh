#!/bin/sh


DONGLE=$1
NUMBER=$2
numberb=$3
numbera=$4
spec=$5
vip=$6
IMB2=$7

TEMP=`mktemp /tmp/call_XXXXXXXXXXXX`.call

cat <<EOF > $TEMP
Channel: Local/$NUMBER@makecall4
Extension: 100
Context: wait5
WaitTime: 7
Priority: 1
Set: dongle=$DONGLE
Set: numberb=$numberb
Set: numbera=$numbera
Set: qos=NOS
Set: spec=$spec
Set: vip=$vip
Set: IMB2=$IMB2
EOF

#chown asterisk:asterisk $TEMP
mv $TEMP /var/spool/asterisk/outgoing/
echo "[$DONGLE] queued for call $NUMBER"
