#!/bin/sh

USB=$1
DEVICE=$2
MODEL=$3

./fupdate3.sh $USB $DEVICE $MODEL &
sleep 21