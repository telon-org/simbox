#!/bin/sh

renice 19 -p $$
ionice -c3 -p $$

IMSI=`echo $1`
NUMBERB=`echo $2`
NUMBERMY=`echo $3`

NUMBERBe=$(echo "$NUMBERB" | sed -e 's/%/%25/g' -e 's/ /%20/g' -e 's/!/%21/g' -e 's/"/%22/g' -e 's/#/%23/g' -e 's/\$/%24/g' -e 's/\&/%26/g' -e 's/'\''/%27/g' -e 's/(/%28/g' -e 's/)/%29/g' -e 's/\*/%2a/g' -e 's/+/%2b/g' -e 's/,/%2c/g' -e 's/-/%2d/g' -e 's/\./%2e/g' -e 's/\//%2f/g' -e 's/:/%3a/g' -e 's/;/%3b/g' -e 's//%3e/g' -e 's/?/%3f/g' -e 's/@/%40/g' -e 's/\[/%5b/g' -e 's/\\/%5c/g' -e 's/\]/%5d/g' -e 's/\^/%5e/g' -e 's/_/%5f/g' -e 's/`/%60/g' -e 's/{/%7b/g' -e 's/|/%7c/g' -e 's/}/%7d/g' -e 's/~/%7e/g')
NUMBERMYe=$(echo "$NUMBERMY" | sed -e 's/%/%25/g' -e 's/ /%20/g' -e 's/!/%21/g' -e 's/"/%22/g' -e 's/#/%23/g' -e 's/\$/%24/g' -e 's/\&/%26/g' -e 's/'\''/%27/g' -e 's/(/%28/g' -e 's/)/%29/g' -e 's/\*/%2a/g' -e 's/+/%2b/g' -e 's/,/%2c/g' -e 's/-/%2d/g' -e 's/\./%2e/g' -e 's/\//%2f/g' -e 's/:/%3a/g' -e 's/;/%3b/g' -e 's//%3e/g' -e 's/?/%3f/g' -e 's/@/%40/g' -e 's/\[/%5b/g' -e 's/\\/%5c/g' -e 's/\]/%5d/g' -e 's/\^/%5e/g' -e 's/_/%5f/g' -e 's/`/%60/g' -e 's/{/%7b/g' -e 's/|/%7c/g' -e 's/}/%7d/g' -e 's/~/%7e/g')


DONGLES=`echo $4`
DONGLENAME=`echo $5`
IAXME=`echo $6`
TOTALSEC=`echo $7`
BILLSEC=`echo $8`
DONGLEIMEI=`echo $9`
DONGLEIMSI=`echo $10`
LAC=`echo $11`
CELL=`echo $12`
END_STATUS=`echo $13`
CC_CAUSE=`echo $14`
END_PARTY="-1"
uid=`echo $15`
qos=`cat /var/svistok/sim/state/$DONGLEIMSI.qos`
spec=`cat /var/svistok/sim/state/$DONGLEIMSI.spec`
NUMBERA=`cat /var/svistok/sim/state/$DONGLEIMSI.numbera`

. /etc/asterisk/own/iax_me.conf

#we=1
#other=2
#network=3
#exit


DIALSTATUS="UNKNOWN"

# 16 = Normall Call Clearing
if [ $CC_CAUSE -eq 16 ] ; then
    if [ $END_STATUS -eq 29 ] ; then
	END_PARTY="1"
	if [ $BILLSEC -gt 0 ] ; then
	    DIALSTATUS="ANSWER"
	else
	    DIALSTATUS="NOANSWER"
	fi
    fi
    if [ $END_STATUS -eq 104 ] ; then
	END_PARTY="2"
	if [ $BILLSEC -gt 0 ] ; then
	    DIALSTATUS="ANSWER"
	else
	    DIALSTATUS="NOANSWER"
	fi
    fi
fi

# 31 = Normal Unspecified
if [ $CC_CAUSE -eq 31 ] ; then
    if [ $END_STATUS -eq 104 ] ; then
	END_PARTY="3"
	if [ $BILLSEC -gt 0 ] ; then
	    DIALSTATUS="ANSWER"
	else
	    DIALSTATUS="NOANSWER"
	fi
    fi
fi


# 17 = User Busy
if [ $CC_CAUSE -eq 17 ] ; then
    END_PARTY="2"
    DIALSTATUS="BUSY"
fi

# 177 = no resources
if [ $CC_CAUSE -eq 177 ] ; then
if [ $END_STATUS -eq 100 ] ; then
DIALSTATUS="FAILED" 
fi
fi



#echo /var/svistok/sim/log/$DONGLEIMSI.calls

d=`date +"%Y-%m-%d %H:%M:%S"`
echo "$d << $NUMBERMY <- $NUMBERB  $DIALSTATUS($END_STATUS,$CC_CAUSE,$END_PARTY) duration=$TOTALSEC billsec=$BILLSEC" >> /var/svistok/sim/log/$DONGLEIMSI.calls

echo "I|$uid|$d|$vip|$spec|$qos|||$NUMBERA|$NUMBERB|$DIALSTATUS|$END_STATUS|$CC_CAUSE|$END_PARTY|$TOTALSEC|$pdds|$pdd|$BILLSEC" >> /var/svistok/sim/log/$DONGLEIMSI.calls2


URL="http://simserver:8122/svistok/callendin.php?numberb=$NUMBERBe&numbermy=$NUMBERMYe&serial=$DONGLES&dongle=$DONGLENAME&gateway=$IAXME&durationsec=$TOTALSEC&billsec=$BILLSEC&dialstatus=$DIALSTATUS&imei=$DONGLEIMEI&imsi=$DONGLEIMSI&lac=$LAC&cell=$CELL&end_status=$END_STATUS&cc_cause=$CC_CAUSE&end_party=$END_PARTY"

echo "/usr/simbox/ai/recog/dorecog_in.php $uid $DONGLEIMSI >> /tmp/rasp_in.log"
(/usr/simbox/ai/recog/dorecog_in.php $uid $DONGLEIMSI >> /tmp/rasp_in.log) &

curl "$URL"
echo $URL

/usr/simbox/ai/sms/try_mon.sh $qos $IMSI $NUMBERB >> /tmp/try_mon.log &



