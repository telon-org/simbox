#!/usr/bin/php
<?
//$text="Ваш тарифный план: СПБ_Просто_нов.М(ф), дата подключения 2012-10-03.";
//$text="тарифный план \"Всё включено XXL\"";

//$text="Ваш текущий тарифный план Вместе дешевле (Спб)";

//$text="Ваш текущий тарифный план Опять дешевле (Спб)";
//$text="Ваш новый тариф Опять дешевле (Спб). Справка о параметрах *107#";

if(preg_match("/((Ваш новый тариф)|(Ваш текущий тарифный план))\s*\n*([^.]*)/",$text,$res))
{
print_r($res);
$tarif=$res[4];

echo "$dongle>$imsi>$tarif";
file_put_contents("/var/simbox/sim/settings/$imsi.tarif",$tarif);
upload_tarif($imsi, $tarif);
}

if(preg_match("/((Тариф)|(tarif))\s*([^.]*)\s*((установлен)|(ustanovlen))/",$text,$res))
{
print_r($res);
$tarif=$res[4];

echo "$dongle>$imsi>$tarif";
file_put_contents("/var/simbox/sim/settings/$imsi.tarif",$tarif);
upload_tarif($imsi, $tarif);
}


if(preg_match("/((Vash novyi tarif)|(Vash tekushhij tarifny'j plan))\s*\n*([^.]*)/",$text,$res))
{
print_r($res);
$tarif=$res[4];

echo "$dongle>$imsi>$tarif";
file_put_contents("/var/simbox/sim/settings/$imsi.tarif",$tarif);
upload_tarif($imsi, $tarif);
}



?>