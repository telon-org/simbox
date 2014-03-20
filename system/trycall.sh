#!/bin/sh

IMSI=$1
NUMBERA=$2
NUMBERB=$3

curl "http://simserver:8122/trycall.php?numbera=$NUMBERA&numberb=$NUMBERB&imsi=$IMSI"
