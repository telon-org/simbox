#!/bin/sh


DATE=`/bin/date '+%d%m%Y'`
LASTDATE=`cat /var/simbox/lastdate`



if [ $DATE -ne $LASTDATE ] ; then
echo "new date"
/usr/simbox/cron/everynewday.sh
fi

echo "$DATE" > /var/simbox/lastdate

