#!/bin/sh


MIN_IN_ACD=180
MAX_OUT_IN_ANS=10   #otnoshenie ishodashih k vhodashim - количество
MAX_OUT_IN_DUR=4    #otnoshenie ishodashih k vhodashim - длительность
MIN_IATT=5    # IATT до этого - предыдущие параметры не учитываются, входящий не пускаем
MAX_IATT=15   # IATT до этого - предыдущие параметры не учитываются, входящий ПУСКАЕМ

#DIFFSECFIRST=60
#DIFFSECNEXT=3600

. /usr/simbox/config.sh



imsilist=`cat $FILE_IMSILIST`

for imsi in $imsilist
do
#status=`cat $PATH_SVISTOK_SIM_SETTINGS/$imsi.group`
#balance=`cat $PATH_SIMBOX_SIM_SETTINGS/$imsi.balance`
#echo "$PATH_SVISTOK_SIM/$imsi.dongle"
#dongle=`cat $PATH_SVISTOK_SIM_STATE/$imsi.dongle`
#echo $dongle
#number=`cat $PATH_SIMBOX_SIM_SETTINGS/$imsi.number`

#state=`cat /var/log/asterisk/sim/$imsi.state`

iatt=`cat $PATH_SVISTOK_SIM_STATISTICS/$imsi.stat_iatt`
in_answered=`cat $PATH_SVISTOK_SIM_STATISTICS/$imsi.stat_in_answered`
in_duration=`cat $PATH_SVISTOK_SIM_STATISTICS/$imsi.stat_in_duration`

out_answered=`cat $PATH_SVISTOK_SIM_STATISTICS/$imsi.stat_calls_answered`
out_duration=`cat $PATH_SVISTOK_SIM_STATISTICS/$imsi.stat_calls_duration`

status=`echo "$status-1+1" | bc`
balance=`echo "$balance-1+1" | bc`
number=`echo "$number-1+1" | bc`

iatt=`echo "$iatt-1+1" | bc`
in_answered=`echo "$in_answered-1+1" | bc`
in_duration=`echo "$in_duration-1+1" | bc`
out_answered=`echo "$out_answered-1+1" | bc`
out_duration=`echo "$out_duration-1+1" | bc`

#echo " - $dongle:$imsi ($iatt) $in_duration/$in_answered=$in_acd $out_duration/$out_answered  $out_in_duration/$out_in_answered"

if [ $in_answered -gt "0" ] ; then
in_acd=`echo "$in_duration/$in_answered" | bc`
else
in_acd="0"
fi


if [ $in_answered -gt "0" ] ; then
out_in_answered=`echo "$out_answered/$in_answered" | bc`
else
out_in_answered="999"
fi

if [ $in_duration -gt "0" ] ; then
out_in_duration=`echo "$out_duration/$in_duration" | bc`
else
out_in_duration="999"
fi



#if [ "130" -gt "$status" ] ; then
#if [ "$status" -gt "100" ] ; then

echo " - $dongle:imsi ($iatt) $in_duration/$in_answered=$in_acd $out_duration/$out_answered  $out_in_duration/$out_in_answered"

needin=0

if [ $iatt -gt $MIN_IATT ] ; then
if [ $MAX_IATT -gt $iatt ] ; then

 if [ $MIN_IN_ACD -gt $in_acd ] ; then
   echo " -- Low in_acd"
   needin=1
 fi

 if [ $out_in_answered -gt $MAX_OUT_IN_ANS ] ; then
   echo " -- Low out_in_answered"
   needin=1
 fi

 if [ $out_in_duration -gt $MAX_OUT_IN_DUR ] ; then
   echo " -- Low out_in_duration"
   needin=1
 fi


else
echo " -- Highh IATT"
needin=1
fi

else
echo " -- Low IATT"
fi

echo " -> needin=$needin"


if [ $needin -eq "1" ] ; then
echo " NEEDIN -->"
echo "1" > $PATH_SIMBOX_SIM_STATE/$imsi.need_in
fi





#fi
#fi

done