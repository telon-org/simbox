#!/bin/sh

. /usr/simbox/config.sh

imsilist=`cat $FILE_IMSILIST`

for imsi in $imsilist
do
need_in=`cat $PATH_SIMBOX_SIM_STATE/$imsi.need_in`
in_done=`cat $PATH_SVISTOK_SIM_STATE/$imsi.indone`

need_in=`echo $need_in-1+1 | bc`
in_done=`echo $in_done-1+1 | bc`


if [ $need_in -gt "0" ] ; then
if [ $in_done -gt "0" ] ; then
echo "in_done $imsi"
rm $PATH_SIMBOX_SIM_STATE/$imsi.need_in
rm $PATH_SVISTOK_SIM_STATE/$imsi.indone
fi
fi

done