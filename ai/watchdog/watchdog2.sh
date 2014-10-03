#!/bin/sh

#!/bin/bash -x
 
DIR=/tmp/watchdog
 
# Create dir if it doesn't exist
if [ ! -d $DIR ]; then
  mkdir $DIR
fi
 
cd $DIR
 
# Save current registration times
/usr/sbin/asterisk -rx "sip show registry" | grep "Registered" | cut -b 92- > current
 
# If last exists, compare current to last
if [ -f last ]; then
  cmp current last
 
# If they match, restart Asterisk
  if [ $? == 0 ]; then
    /etc/init.d/asterisk restart
  fi
fi
 
rm -f last
mv current last


TONES_DIR=/etc/asterisk/watchdog/tones
INTERVAL=5
amixer set 'Master' '100%'
amixer -- set 'PCM' '-4.50dB'

run_watchdog()
{
while (true)
do
  if [ -f /var/run/asterisk.pid ]; then
    ASTERISK_PID=$(cat /var/run/asterisk.pid)
    RUNNING=$(ps auxw|egrep '^[^ ]+ +'$ASTERISK_PID' '|grep -c asterisk)
    if [ $RUNNING = "1" ]; then
        for tone in ${TONES_DIR}/*.raw
        do
          aplay -q -f cd $tone
          sleep 0.5
        done
    fi
  fi
  sleep $INTERVAL
done
}