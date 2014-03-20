#!/bin/sh

dongles=`cat /var/svistok/lists/dongles.list`

#dongle="dongle311"

for dongle in $dongles
do

/usr/sbin/asterisk -r -x "dongle cmd $dongle AT+CPMS=\"SM\",\"SM\",\"SM\""
/usr/sbin/asterisk -r -x "dongle cmd $dongle AT+CMGD=1,4"
done

sleep 5

for dongle in $dongles
do

/usr/sbin/asterisk -r -x "dongle cmd $dongle AT+CPMS=\"ME\",\"ME\",\"ME\""
/usr/sbin/asterisk -r -x "dongle cmd $dongle AT+CMGD=1,4"

done

sleep 5

for dongle in $dongles
do

/usr/sbin/asterisk -r -x "dongle cmd $dongle AT+CPMS=\"SM\",\"SM\",\"SM\""
sleep 1
/usr/sbin/asterisk -r -x "dongle cmd $dongle AT+CMGD=1,4"
sleep 1
/usr/sbin/asterisk -r -x "dongle cmd $dongle AT+CPMS=\"ME\",\"ME\",\"ME\""
sleep 1
/usr/sbin/asterisk -r -x "dongle cmd $dongle AT+CMGD=1,4"
sleep 1

done