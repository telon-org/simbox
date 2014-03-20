#!/usr/bin/php
<?
//die();

//$text="Ваш федеральный номер +7 (900) 228-49-80";
//$text="Ваш федеральный номер +7 (900) 228-49-80";

$text2=str_replace(array(" ","(",")","-"),"",$text);
//die($text2);

if(preg_match("/Вашфедеральныйномер\+([0-9]*)/",$text2,$res))
{
print_r($res);
$number=$res[1];

echo "$dongle>$imsi>$number";
file_put_contents("/var/simbox/sim/settings/$imsi.number",$number);
upload_number($imsi, $number);
}


if(preg_match("/Ваш федеральный номер \- \+([0-9]*)/",$text,$res))
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