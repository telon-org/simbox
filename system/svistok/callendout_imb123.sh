#!/bin/sh


NUMBERA=`echo $1`
NUMBERB=`echo $2`
DUR=`echo $3`
NAPR=`echo $4`
DIALSTATUS=`echo $5`

NUMBERAe=$(echo "$NUMBERA" | sed -e 's/%/%25/g' -e 's/ /%20/g' -e 's/!/%21/g' -e 's/"/%22/g' -e 's/#/%23/g' -e 's/\$/%24/g' -e 's/\&/%26/g' -e 's/'\''/%27/g' -e 's/(/%28/g' -e 's/)/%29/g' -e 's/\*/%2a/g' -e 's/+/%2b/g' -e 's/,/%2c/g' -e 's/-/%2d/g' -e 's/\./%2e/g' -e 's/\//%2f/g' -e 's/:/%3a/g' -e 's/;/%3b/g' -e 's//%3e/g' -e 's/?/%3f/g' -e 's/@/%40/g' -e 's/\[/%5b/g' -e 's/\\/%5c/g' -e 's/\]/%5d/g' -e 's/\^/%5e/g' -e 's/_/%5f/g' -e 's/`/%60/g' -e 's/{/%7b/g' -e 's/|/%7c/g' -e 's/}/%7d/g' -e 's/~/%7e/g')
NUMBERBe=$(echo "$NUMBERB" | sed -e 's/%/%25/g' -e 's/ /%20/g' -e 's/!/%21/g' -e 's/"/%22/g' -e 's/#/%23/g' -e 's/\$/%24/g' -e 's/\&/%26/g' -e 's/'\''/%27/g' -e 's/(/%28/g' -e 's/)/%29/g' -e 's/\*/%2a/g' -e 's/+/%2b/g' -e 's/,/%2c/g' -e 's/-/%2d/g' -e 's/\./%2e/g' -e 's/\//%2f/g' -e 's/:/%3a/g' -e 's/;/%3b/g' -e 's//%3e/g' -e 's/?/%3f/g' -e 's/@/%40/g' -e 's/\[/%5b/g' -e 's/\\/%5c/g' -e 's/\]/%5d/g' -e 's/\^/%5e/g' -e 's/_/%5f/g' -e 's/`/%60/g' -e 's/{/%7b/g' -e 's/|/%7c/g' -e 's/}/%7d/g' -e 's/~/%7e/g')

END_PARTY="2"

. /etc/asterisk/own/iax_me.conf


#we=1
#other=2
#network=3

DIALSTATUS="NULLCALL"



URL="http://simserver:8122/svistok/callendout_imb123.php?numberb=$NUMBERBe&numbera=$NUMBERAe&numbermy=123&serial=123&dongle=123&gateway=$IAXME&duration=$DUR&billsec=0&dialstatus=$DIALSTATUS&imei=123&imsi=123&lac=&cell=&end_status=0&cc_cause=0&end_party=$END_PARTY"
echo $URL


IMSI=`curl "$URL"`
echo $IMSI

d=`date +"%Y-%m-%d %H:%M:%S"`
echo "$d !! PROZVON FOUND $NUMBERA -> $NUMBERB CHECK=$DUR NAPREAVLENIE=$NAPR" >> /var/svistok/sim/log/$DONGLEIMSI.calls
echo "1" > /var/simbox/sim/settings/$DONGLEIMSI.$NAPR.palevo

