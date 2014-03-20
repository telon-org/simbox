#!/bin/sh

. /usr/simbox/config.sh
. /usr/simbox/nabor/velcom/config.sh

#usage send_may dongle123 noimsi 79265555555

# PARAM=$3
echo "-- Sending MAY"

#*131* номер абонента компании в формате 29(или 44/33/25)ХХХХХХХ# вызов

/usr/simbox/system/send.sh "ussd" "LO2" "$DONGLE" "*131*$PARAM#" ""
