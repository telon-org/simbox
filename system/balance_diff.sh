#!/bin/sh

imsi=$1


balance=`cat /var/simbox/sim/statistics/$imsi.balance`
bal_last=`cat /var/simbox/sim/statistics/$imsi.bal_last`

bal_diff=`echo "($balance-1+1)-($bal_last-1+1)" | bc`

if [ $bal_diff -gt "0" ] ; then
bal_plus=`cat /var/simbox/sim/statistics/$imsi.bal_plus`
#echo "$bal_plus-1+1+$bal_diff"
bal_plus=`echo "$bal_plus-1+1+$bal_diff" | bc`
#exit
echo "$bal_plus" > /var/simbox/sim/statistics/$imsi.bal_plus
fi

if [ "0" -gt $bal_diff ] ; then
bal_minus=`cat /var/simbox/sim/statistics/$imsi.bal_minus`
#echo "$bal_minus-1+1-($bal_diff)" | bc
bal_minus=`echo "$bal_minus-1+1-($bal_diff)" | bc`
#exit
echo "$bal_minus" > /var/simbox/sim/statistics/$imsi.bal_minus
fi

cp /var/simbox/sim/statistics/$imsi.balance /var/simbox/sim/statistics/$imsi.bal_last

