#!/bin/sh
if [ `pidof asterisk` ]; then
        echo “Asterisk has a pid: I will do nothing.”
        exit
else
        echo “Asterisk not running!”
        /etc/init.d/asterisk start &
        exit 1
fi