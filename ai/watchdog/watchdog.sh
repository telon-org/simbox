#!/bin/bash

sudo /usr/simbox/ai/watchdog/dog_peers.sh &
date
sleep 4
result=`cat /tmp/dog_peers.lock`
if [ "$result" == "99" ]
then
echo ASTERISK OK
fi

if [ "$result" == "100" ]
then
echo ASTERISK DOWN $result
sudo reboot
fi