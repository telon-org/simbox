#!/usr/bin/php
<?php


$hubctrl="/usr/simbox/bin/hub-ctrl";


$hub="001:001";
//grep -o -R "[0-9]* Device [0-9]*"
exec('lsusb | grep Terminus',$devices);
print_r($devices);

foreach($devices as $k=>$line)
{
    echo($line);
    $r=grep("[0-9]* Device [0-9]*");
}
#for port in $ports
#do
#    echo "HUB=$hub PORT=$port"
#    b=`echo "$hub" | grep -o -R "[0-9]*:" | sed 's/://g'`
#    d=`echo "$hub" | grep -o -R ":[0-9]*" | sed 's/://g'`
#
#
#    #Выключаем
#    echo "OFF"
#    echo "$hubctrl -b $b -d $d -P $port -p 0"
#    $hubctrl -b $b -d $d -P $port -p 0
#    sleep 10
#
#    #Включаем
#    echo "ON"
#    echo "$hubctrl -b $b -d $d -P $port -p 1"
#    $hubctrl -b $b -d $d -P $port -p 1
#    sleep 10
#done

#asterisk

?>