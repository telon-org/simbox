#!/usr/bin/php
<?
//$text="Ваш тарифный план: СПБ_Просто_нов.М(ф), дата подключения 2012-10-03.";
//$text="тарифный план \"Всё включено XXL\"";

if(preg_match("/Ваш тарифный план: ([^,]*)/",$text,$res))
{
print_r($res);
$tarif=$res[1];

echo "$dongle>$imsi>$tarif";
file_put_contents("/var/simbox/sim/settings/$imsi.tarif",$tarif);
upload_tarif($imsi, $tarif);
}



if(preg_match('/тарифный план "([^"]*)"/',$text,$res))
{
print_r($res);
$tarif=$res[1];

echo "$dongle>$imsi>$tarif";
file_put_contents("/var/simbox/sim/settings/$imsi.tarif",$tarif);
upload_tarif($imsi, $tarif);
}


if(preg_match('/(Контракт не зарегистрирован)/',$text,$res))
{
print_r($res);
$tarif=$res[1];

echo "$dongle>$imsi>$tarif";
file_put_contents("/var/simbox/sim/settings/$imsi.tarif",$tarif);
upload_tarif($imsi, $tarif);
}


?>