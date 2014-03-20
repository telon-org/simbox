#!/bin/sh

iccid=`echo $1`
imsi=`echo $2`
ki=`echo $3`

url="http://simserver:8122/readers/upload_new_ki.php?iccid=$iccid&imsi=$imsi&ki=$ki"
echo $url

/usr/bin/curl "$URL"
