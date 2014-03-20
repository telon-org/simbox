#!/usr/bin/php
<?
//$text="Ваш номер 9657654973.";

if(preg_match("/Номер Вашего мобильного телефона \+([0-9]+)/",$text,$res))
{
print_r($res);
$number=$res[1];
if (substr($number,0,1)==9) $number="7$number";

echo "$dongle>$imsi>$number";
file_put_contents("/var/simbox/sim/settings/$imsi.number",$number);
upload_number($imsi, $number);
}


?>