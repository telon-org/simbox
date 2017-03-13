#!/usr/bin/php
<?
//$text="Ваш федеральный номер  +7900";
//$text="Ваш федеральный номер +7 (900) 649-52-71";

if(preg_match("/Ваш федеральный номер [\- \+]*([0-9\ \-\(\)]*)/",$text,$res))
{
print_r($res);
$number=$res[1];
$number = preg_replace('![^0-9]+!', '', $number);

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