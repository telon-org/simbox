#!/bin/sh
renice 19 -p $$
ionice -c3 -p $$

when=`echo $1`
vip=`echo $2`
spec=`echo $3`
qos=`echo $4`
NUMBERA=`echo $5`
NUMBERB=`echo $6`
naprstr=`echo $7`

NUMBERBe=$(echo "$NUMBERB" | sed -e 's/%/%25/g' -e 's/ /%20/g' -e 's/!/%21/g' -e 's/"/%22/g' -e 's/#/%23/g' -e 's/\$/%24/g' -e 's/\&/%26/g' -e 's/'\''/%27/g' -e 's/(/%28/g' -e 's/)/%29/g' -e 's/\*/%2a/g' -e 's/+/%2b/g' -e 's/,/%2c/g' -e's/-/%2d/g' -e 's/\./%2e/g' -e 's/\//%2f/g' -e 's/:/%3a/g' -e 's/;/%3b/g' -e 's//%3e/g' -e 's/?/%3f/g' -e 's/@/%40/g' -e 's/\[/%5b/g' -e 's/\\/%5c/g' -e 's/\]/%5d/g' -e 's/\^/%5e/g' -e 's/_/%5f/g' -e 's/`/%60/g' -e 's/{/%7b/g' -e 's/|/%7c/g' -e 's/}/%7d/g' -e 's/~/%7e/g')
NUMBERAe=$(echo "$NUMBERA" | sed -e 's/%/%25/g' -e 's/ /%20/g' -e 's/!/%21/g' -e 's/"/%22/g' -e 's/#/%23/g' -e 's/\$/%24/g' -e 's/\&/%26/g' -e 's/'\''/%27/g' -e 's/(/%28/g' -e 's/)/%29/g' -e 's/\*/%2a/g' -e 's/+/%2b/g' -e 's/,/%2c/g' -e's/-/%2d/g' -e 's/\./%2e/g' -e 's/\//%2f/g' -e 's/:/%3a/g' -e 's/;/%3b/g' -e 's//%3e/g' -e 's/?/%3f/g' -e 's/@/%40/g' -e 's/\[/%5b/g' -e 's/\\/%5c/g' -e 's/\]/%5d/g' -e 's/\^/%5e/g' -e 's/_/%5f/g' -e 's/`/%60/g' -e 's/{/%7b/g' -e 's/|/%7c/g' -e 's/}/%7d/g' -e 's/~/%7e/g')


d=`date +"%Y-%m-%d %H:%M:%S"`

echo "$d|$vip|$spec|$qos|$naprstr|$NUMBERA|$NUMBERB" >> /var/svistok/sim/log/req.full
echo "$d|$vip|$spec|$qos|$naprstr|$NUMBERA|$NUMBERB" >> /var/svistok/sim/log/req.$naprstr
#echo "$d|$vip|$spec|$qos|$naprstr|$NUMBERA|$NUMBERB" >> /var/svistok/sim/log/req.100
#echo "$d|$vip|$spec|$qos|$naprstr|$NUMBERA|$NUMBERB" >> /var/svistok/sim/log/req.300

#tail -n 100 /var/svistok/sim/log/req.100 > /var/svistok/sim/log/req.101
#mv /var/svistok/sim/log/req.101 /var/svistok/sim/log/req.100

#tail -n 300 /var/svistok/sim/log/req.300 > /var/svistok/sim/log/req.301
#mv /var/svistok/sim/log/req.301 /var/svistok/sim/log/req.300
