#!/bin/sh

. /usr/simbox/config.sh
. /usr/simbox/system/get_args.sh
#. /usr/simbox/system/get_args_plan_nabor.sh



$ASTERISK -rx "dongle cmd $DONGLE AT+CFUN=1,1"
#sleep 60
#$ASTERISK -rx "dongle cmd $DONGLE AT^NDISDUP=1,1"


#if [ $NABOR -ne "" ] ; then 
#cmd="$ASTERISK -rx dongle cmd $DONGLE $3"
#echo $cmd
#res=`$cmd`
#cho $res
