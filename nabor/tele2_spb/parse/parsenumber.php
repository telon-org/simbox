#!/usr/bin/php
<?
//$text="Ваш федеральный номер - +13";

if(preg_match("/Ваш федеральный номер \- \+([0-9\ \-\(\)]*)/",$text,$res))
{
print_r($res);
$number=$res[1];

echo "$dongle>$imsi>$number";
file_put_contents("/var/simbox/sim/settings/$imsi.number",$number);
upload_number($imsi, $number);
}


if(preg_match("/Vash federal'ny'j nomer \- \+([0-9]*)/",$text,$res))
{
print_r($res);
$number=$res[1];

echo "$dongle>$imsi>$number";
file_put_contents("/var/simbox/sim/settings/$imsi.number",$number);
upload_number($imsi, $number);
}


?>