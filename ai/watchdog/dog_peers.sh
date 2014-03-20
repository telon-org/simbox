#!/bin/sh

echo 100 > /tmp/dog_peers.lock
/usr/sbin/asterisk -rx "sip show peers" > /tmp/dog_peers.res
echo 99 > /tmp/dog_peers.lock
#rm /tmp/dog_peers.lock