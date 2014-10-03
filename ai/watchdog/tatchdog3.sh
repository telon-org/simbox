#!/bin/bash

asterisk -rx 'core show version' &> /dev/null
errcode=$?

if [[ "$errcode" != "0" ]] ;then
/etc/init.d/asterisk stop
sleep 3
/etc/init.d/asterisk start
fi