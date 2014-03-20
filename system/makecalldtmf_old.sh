#!/bin/sh


DONGLE=$1
NUMBER=$2
NABOR=$3

TEMP=`mktemp /tmp/call_XXXXXXXXXXXX`.call

cat <<EOF > $TEMP
Channel: Dongle/$DONGLE/$NUMBER
Extension: $3
Context: calldtmf
Priority: 1
EOF

#chown asterisk:asterisk $TEMP
mv $TEMP /var/spool/asterisk/outgoing/
echo "[$DONGLE] queued for call $NUMBER"
