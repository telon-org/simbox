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
    if (preg_match("/([0-9]*) Device ([0-9]*)/",$line,$r))
    {
        print_r($r);
	$b=$r[1];
	$d=$r[2];
	for($port=1;$port<=4;$port++)
	{

        echo "OFF";
	exec("$hubctrl -b $b -d $d -P $port -p 0",$o);
	print_r($o);
	sleep(5);

	echo "ON";
	exec("$hubctrl -b $b -d $d -P $port -p 1",$o);
	print_r($o);
	sleep(60);
	}

    }
}

?>