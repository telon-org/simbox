#!/bin/sh


DONGLE=$1
NUMBER=$2


TEMP=`mktemp /tmp/call_XXXXXXXXXXXX`.call

cat <<EOF > $TEMP
Channel: Local/$NUMBER@makecall4
Extension: 100
Context: wait60
Priority: 1
Set: dongle=$DONGLE
Set: numberb=$NUMBER
Set: numbera=
Set: qos=NOS
Set: spec=LOC
Set: vip=NO
Set: IMB2=$IMB2
EOF

#chown asterisk:asterisk $TEMP
mv $TEMP /var/spool/asterisk/outgoing/
echo "[$DONGLE] queued for call $NUMBER"
