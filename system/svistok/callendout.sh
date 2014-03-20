#!/bin/sh

renice 19 -p $$
ionice -c3 -p $$

IMSI=`echo $1`
NUMBERA=`echo $2`
NUMBERB=`echo $3`
NUMBERMY=`echo $4`

NUMBERAe=$(echo "$NUMBERA" | sed -e 's/%/%25/g' -e 's/ /%20/g' -e 's/!/%21/g' -e 's/"/%22/g' -e 's/#/%23/g' -e 's/\$/%24/g' -e 's/\&/%26/g' -e 's/'\''/%27/g' -e 's/(/%28/g' -e 's/)/%29/g' -e 's/\*/%2a/g' -e 's/+/%2b/g' -e 's/,/%2c/g' -e 's/-/%2d/g' -e 's/\./%2e/g' -e 's/\//%2f/g' -e 's/:/%3a/g' -e 's/;/%3b/g' -e 's//%3e/g' -e 's/?/%3f/g' -e 's/@/%40/g' -e 's/\[/%5b/g' -e 's/\\/%5c/g' -e 's/\]/%5d/g' -e 's/\^/%5e/g' -e 's/_/%5f/g' -e 's/`/%60/g' -e 's/{/%7b/g' -e 's/|/%7c/g' -e 's/}/%7d/g' -e 's/~/%7e/g')
NUMBERBe=$(echo "$NUMBERB" | sed -e 's/%/%25/g' -e 's/ /%20/g' -e 's/!/%21/g' -e 's/"/%22/g' -e 's/#/%23/g' -e 's/\$/%24/g' -e 's/\&/%26/g' -e 's/'\''/%27/g' -e 's/(/%28/g' -e 's/)/%29/g' -e 's/\*/%2a/g' -e 's/+/%2b/g' -e 's/,/%2c/g' -e 's/-/%2d/g' -e 's/\./%2e/g' -e 's/\//%2f/g' -e 's/:/%3a/g' -e 's/;/%3b/g' -e 's//%3e/g' -e 's/?/%3f/g' -e 's/@/%40/g' -e 's/\[/%5b/g' -e 's/\\/%5c/g' -e 's/\]/%5d/g' -e 's/\^/%5e/g' -e 's/_/%5f/g' -e 's/`/%60/g' -e 's/{/%7b/g' -e 's/|/%7c/g' -e 's/}/%7d/g' -e 's/~/%7e/g')
NUMBERMYe=$(echo "$NUMBERMY" | sed -e 's/%/%25/g' -e 's/ /%20/g' -e 's/!/%21/g' -e 's/"/%22/g' -e 's/#/%23/g' -e 's/\$/%24/g' -e 's/\&/%26/g' -e 's/'\''/%27/g' -e 's/(/%28/g' -e 's/)/%29/g' -e 's/\*/%2a/g' -e 's/+/%2b/g' -e 's/,/%2c/g' -e 's/-/%2d/g' -e 's/\./%2e/g' -e 's/\//%2f/g' -e 's/:/%3a/g' -e 's/;/%3b/g' -e 's//%3e/g' -e 's/?/%3f/g' -e 's/@/%40/g' -e 's/\[/%5b/g' -e 's/\\/%5c/g' -e 's/\]/%5d/g' -e 's/\^/%5e/g' -e 's/_/%5f/g' -e 's/`/%60/g' -e 's/{/%7b/g' -e 's/|/%7c/g' -e 's/}/%7d/g' -e 's/~/%7e/g')


DONGLES=`echo $5`
DONGLENAME=`echo $6`
IAXME=`echo $7`

TEPOCH=`echo $8`

ANSWERED=`echo $9`
TOTALSEC=`echo $10`
BILLSEC=`echo $11`

FASSEC=`echo $12`
PDDCSEC=`echo $13`

DONGLEIMEI=`echo $14`
DONGLEIMSI=`echo $15`
LAC=`echo $16`
CELL=`echo $17`
END_STATUS=`echo $18`
CC_CAUSE=`echo $19`
spec=`echo $20`
qos=`echo $21`
vip=`echo $22`
pdd=`echo $23`
pdds=`echo $24`
naprstr=`echo $25`
im=`echo $26`
uid=`echo $27`
pro=`echo $28`
cap=`echo $29`

fas=`echo $30`
epdd=`echo $31`
fpdd=`echo $32`
hem=`echo $33`
hoa=`echo $34`

em_type=`echo $35`

END_PARTY="-1"

. /etc/asterisk/own/iax_me.conf

renice -n +20

#we=1
#other=2
#network=3

DIALSTATUS="UNKNOWN"

    if [ $END_STATUS -eq 21 ] ; then
	END_PARTY="-1"
	DIALSTATUS="FAILED"
    fi

if [ $CC_CAUSE -eq 19 ] ; then
    if [ $END_STATUS -eq 104 ] ; then
	END_PARTY="3"
	DIALSTATUS="NOANSWER"
    fi
fi

if [ $CC_CAUSE -eq 1 ] ; then
    if [ $END_STATUS -eq 104 ] ; then
	END_PARTY="3"
	DIALSTATUS="NOANSWER"
    fi
fi

if [ $CC_CAUSE -eq 28 ] ; then
    if [ $END_STATUS -eq 104 ] ; then
	END_PARTY="3"
	DIALSTATUS="NOANSWER"
    fi
fi



# 0,29 = Normall Call Clearing??
if [ $CC_CAUSE -eq 0 ] ; then
    if [ $END_STATUS -eq 29 ] ; then
	END_PARTY="1"
#	if [ $BILLSEC -gt 0 ] ; then
	if [ $ANSWERED -gt 0 ] ; then
	    DIALSTATUS="ANSWER"
	    if [ $BILLSEC -eq 0 ] ; then
		BILLSEC=1
	    fi
	else
	    DIALSTATUS="NOANSWER"
	fi
    fi
fi

# 0,100 = Normall Call Clearing??
if [ $CC_CAUSE -eq 0 ] ; then
    if [ $END_STATUS -eq 100 ] ; then
	END_PARTY="1"
#	if [ $BILLSEC -gt 0 ] ; then
	if [ $ANSWERED -gt 0 ] ; then
	    DIALSTATUS="ANSWER"
	    if [ $BILLSEC -eq 0 ] ; then
		BILLSEC=1
	    fi
	else
	    DIALSTATUS="NOANSWER"
	fi
    fi
fi


# 16 = Normall Call Clearing
if [ $CC_CAUSE -eq 16 ] ; then
    if [ $END_STATUS -eq 29 ] ; then
	END_PARTY="1"
#	if [ $BILLSEC -gt 0 ] ; then
	if [ $ANSWERED -gt 0 ] ; then
	    DIALSTATUS="ANSWER"
	    if [ $BILLSEC -eq 0 ] ; then
		BILLSEC=1
	    fi
	else
	    DIALSTATUS="NOANSWER"
	fi
    fi
    if [ $END_STATUS -eq 104 ] ; then
	END_PARTY="2"
#	if [ $BILLSEC -gt 0 ] ; then
	if [ $ANSWERED -gt 0 ] ; then
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
#	if [ $BILLSEC -gt 0 ] ; then
	if [ $ANSWERED -gt 0 ] ; then
	    DIALSTATUS="ANSWER"
	    if [ $BILLSEC -eq 0 ] ; then
		BILLSEC=1
	    fi
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


# 19 = User_alerintg_no_answer
if [ $CC_CAUSE -eq 19 ] ; then
if [ $END_STATUS -eq 104 ] ; then
DIALSTATUS="NOANSWER_USERALERTING"
fi
fi




URL="http://simserver:8122/svistok/callendout.php?numberb=$NUMBERBe&numbera=$NUMBERAe&numbermy=$NUMBERMYe&serial=$DONGLES&dongle=$DONGLENAME&gateway=$IAXME&duration=$TOTALSEC&billsec=$BILLSEC&dialstatus=$DIALSTATUS&imei=$DONGLEIMEI&imsi=$DONGLEIMSI&lac=$LAC&cell=$CELL&end_status=$END_STATUS&cc_cause=$CC_CAUSE&end_party=$END_PARTY&spec=$spec&vip=$vip&pdd=$pdd&pddc=$pdds&uid=$uid&pro=$pro&fas=$fas&epdd=$epdd&fpdd=$fpdd&hem=$hem&hoa=$hoa&epoch=$TEPOCH&fassec=$FASSEC&pddcsec=$PDDCSEC&em_type=$em_type"
echo $URL

d=`date +"%Y-%m-%d %H:%M:%S"`
echo "U$uid|$d >> |$pro|$im|$vip|$spec|$qos| $NUMBERA -> $NUMBERB $DIALSTATUS($END_STATUS,$CC_CAUSE,$END_PARTY) duration=$TOTALSEC connect=$pdds pdd=$pdd billsec=$BILLSEC" >> /var/svistok/sim/log/$DONGLEIMSI.calls

echo "O|$uid|$d|$vip|$spec|$qos|$naprstr|$im|$NUMBERA|$NUMBERB|$DIALSTATUS|$END_STATUS|$CC_CAUSE|$END_PARTY|$TOTALSEC|$PDDCSEC|$pdd|$BILLSEC|$pro|$cap|$fas|$epdd|$fpdd|$hem|$hoa|$TEPOCH|$FASSEC|$em_type|" >> /var/svistok/sim/log/$DONGLEIMSI.calls2
echo "O|$uid|$d|$vip|$spec|$qos|$naprstr|$im|$NUMBERA|$NUMBERB|$DIALSTATUS|$END_STATUS|$CC_CAUSE|$END_PARTY|$TOTALSEC|$PDDCSEC|$pdd|$BILLSEC|$pro|$cap|$fas|$epdd|$fpdd|$hem|$hoa|$TEPOCH|$FASSEC|$em_type|" >> /var/svistok/sim/log/calls.full
echo "O|$uid|$d|$vip|$spec|$qos|$naprstr|$im|$NUMBERA|$NUMBERB|$DIALSTATUS|$END_STATUS|$CC_CAUSE|$END_PARTY|$TOTALSEC|$PDDCSEC|$pdd|$BILLSEC|$pro|$cap|$fas|$epdd|$fpdd|$hem|$hoa|$TEPOCH|$FASSEC|$em_type|" >> /var/svistok/sim/log/calls.$naprstr

#echo "$DONGLEIMSI" > /var/svistok/sim/state/$uid.imsi

echo "/usr/simbox/ai/recog/dorecog.php $uid $DIALSTATUS $DONGLEIMSI $NUMBERB $BILLSEC >> /tmp/rasp_out.log"
(/usr/simbox/ai/recog/dorecog.php $uid $DIALSTATUS $DONGLEIMSI $NUMBERB $BILLSEC >> /tmp/rasp_out.log) &

/usr/bin/curl "$URL"

echo "test mm"
echo $BILLSEC
echo $TOTALSEC
echo $im


echo 333
#esli ne dozvonilsa, zvonil dolgo i imsib, to
if [ $BILLSEC -eq 0 ] ; then
echo "bill 0"
#if [ $TOTALSEC -gt 20 ] ; then
if [ $TOTALSEC -gt 10 ] ; then
echo "total > 30"
#if [ "$im" == "B" ] ; then
#echo "im = b"
/usr/simbox/system/sleep_rand.php 3 5
/usr/simbox/ai/sms/try_may.sh $DONGLEIMSI $NUMBERB >> /tmp/try_may.log &
#fi
#if [ "$im" == "C" ] ; then
#echo "im = c"
#/usr/simbox/ai/sms/try_may.sh $DONGLEIMSI $NUMBERB >> /tmp/try_may.log &
#fi

#if [ "$im" == "N" ] ; then
#echo "im = N"
#/usr/simbox/ai/sms/try_may.sh $DONGLEIMSI $DIALSTATUS $NUMBERB >> /tmp/try_may_n.log &
#fi

fi
fi

/usr/simbox/ai/sms/try_smssebe.sh $DONGLEIMSI >> /tmp/try_smssebe.log &
/usr/simbox/ai/sms/try_spam.sh $DONGLEIMSI >> /tmp/try_spam.log &
