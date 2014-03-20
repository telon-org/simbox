#!/bin/sh

USB=$1
DEVICE=$2
TMP=/tmp/$DEVICE.unlock.tmp
echo USB=$USB
echo DEVICE=$DEVICE
echo TMP=$TMP

cat $USB > $TMP &
echo "AT+CGSN\r\n" >> $USB

sleep 2
IMEI=`cat tmp/$USB | grep -o -R "[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]"`

UNLOCK=`/usr/simbox/system/nck.php $IMEI`
echo "$USB IMEI:$IMEI UNLOCK:$UNLOCK"

echo "AT^CARDLOCK=\"$UNLOCK\"\r\n"  >> $USB