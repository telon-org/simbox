#!/bin/sh


DONGLE=$1
NUMBER=$2
numberb=$3
qos=$4
pro=$5
naprstr=$6
IMB2=$7
spec=MAG


TEMP=`mktemp /tmp/call_XXXXXXXXXXXX`.call

cat <<EOF > $TEMP
Channel: Local/$NUMBER@makecallmag
Extension: 111
Context: wait1
Priority: 1
Set: dongle=$DONGLE
Set: numberb=$numberb
Set: numbera=
Set: qos=$qos
Set: spec=MAG
Set: pro=$pro
Set: naprstr=$naprstr
Set: IMB2=$IMB2
EOF


#chown asterisk:asterisk $TEMP
cp $TEMP /tmp/$NUMBER.tpmcall
mv $TEMP /var/spool/asterisk/outgoing/
echo "[$DONGLE] queued for call $NUMBER"
echo "pro=$pro IMB2=$IMB2"
echo "qos=$qos naprstr=$naprstr"
