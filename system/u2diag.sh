#!/bin/sh

USB=$1

echo AT^U2DIAG=0 >> $USB
echo AT+CFUN=1,1 >> $USB

echo "AT^U2DIAG=0 >> $USB"
echo "AT+CFUN=1,1 >> $USB"