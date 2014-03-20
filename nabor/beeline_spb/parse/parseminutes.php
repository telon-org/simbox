#!/usr/bin/php
<?
//$text=": 171 мин/сутки на др.номера;26 мин";
//$text=", 100 SMS";


if(preg_match("/: ([\d]+) мин\/сутки на др\.номера\;([\d]+) мин/",$text,$res))
//if(preg_match("/: ([\d]+) мин\/сутки на др\.номера\;([\d]+.[\d]+) мин/",$text,$res))
{
print_r($res);
$minutes2=(int)$res[1]-20;
$minutes1=(int)$res[2]-20;
//$minutes=(int)$res[1];
echo "$dongle>$imsi>$minutes1>$minutes2";


$min1=$minutes1*60;
$min2=$minutes2*60;

echo "$dongle>$imsi>$min1>$min2";
file_put_contents("/var/svistok/sim/limits/$imsi.limit.1",$min1);
file_put_contents("/var/svistok/sim/limits/$imsi.limit.2",$min2);
}


?>