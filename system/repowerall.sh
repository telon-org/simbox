#!/bin/sh

#    sleep 30

hubctrl="/usr/simbox/bin/hub-ctrl"


hubs=`lsusb | grep DUB-H7 | grep -o -R "[0-9]* Device [0-9]*" | sed 's/ Device /:/g'`
hubs2=`lsusb | grep 1a40:0101 | grep -o -R "[0-9]* Device [0-9]*" | sed 's/ Device /:/g'`
hubs3=`lsusb | grep Terminus | grep -o -R "[0-9]* Device [0-9]*" | sed 's/ Device /:/g'`

hubs="$hubs $hubs2 $hubs3"

for hub in $hubs
do
    echo "HUB=$hub"

    ports=`lsusb -v -s $hub | grep -o -R "Port [0-9]: " | grep -o -R "[0-9]:" | sed 's/://g'`
for port in $ports
do
    echo "HUB=$hub PORT=$port"
    b=`echo "$hub" | grep -o -R "[0-9]*:" | sed 's/://g'`
    d=`echo "$hub" | grep -o -R ":[0-9]*" | sed 's/://g'`


    #Выключаем
    echo "OFF"
    $hubctrl -b $b -d $d -P $port -p 0
    sleep 2

    #Включаем
    echo "ON"
    $hubctrl -b $b -d $d -P $port -p 1
    sleep 2

#exit
done
done


echo "DONE"