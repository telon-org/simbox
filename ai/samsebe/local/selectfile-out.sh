#!/bin/bash

NUMBER=$1.samsebe

ut=`date +%s`
r=$RANDOM
num=`echo "($ut+$r)%700" | bc`
res=`cat /var/samsebe/in.list | head -n $num | tail -n 1 | sed 's/\.g729//g' | sed 's/\-in//g'`
echo "$res" > /tmp/$NUMBER
echo -n "$res-in"
