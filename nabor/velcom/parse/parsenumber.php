#!/usr/bin/php
<?
echo ("VVVVVVVVVVVVV\n");
echo($text."\n");
//$text="Ваш номер velcom: +375 44 7408502";

if(preg_match("/Ваш номер velcom: \+([0-9]*\s[0-9]*\s[0-9]*)/",$text,$res))
{
print_r($res);
$number=$res[1];
$number=str_replace(" ","",$number);

echo "$dongle>$imsi>$number";
file_put_contents("/var/simbox/sim/settings/$imsi.number",$number);
upload_number($imsi, $number);
}


?>