#!/bin/sh


#exit 0
#    sleep 30

#asterisk -rx "core stop now"
hubctrl="/usr/simbox/bin/hub-ctrl"


hub=001:001
    echo "HUB=$hub"

    ports=`lsusb -v -s $hub | grep -o -R "Port [0-9]: " | grep -o -R "[0-9]:" | sed 's/://g'`

for port in $ports
do
    echo "HUB=$hub PORT=$port"
    b=`echo "$hub" | grep -o -R "[0-9]*:" | sed 's/://g'`
    d=`echo "$hub" | grep -o -R ":[0-9]*" | sed 's/://g'`


    #Выключаем
    echo "OFF"
    echo "$hubctrl -b $b -d $d -P $port -p 0"
    $hubctrl -b $b -d $d -P $port -p 0
    sleep 10

    #Включаем
    echo "ON"
    echo "$hubctrl -b $b -d $d -P $port -p 1"
    $hubctrl -b $b -d $d -P $port -p 1
    sleep 10
done

#asterisk

echo "DONE2"