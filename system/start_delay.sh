#!/bin/sh

DELAY=$1
CMD=$2

sleep $1

CMD=`echo $CMD`
echo $CMD
$CMD

