#!/usr/bin/php
<?
//$text="Баланс 150.00 руб";
//$text="Баланс:45,36р";

if(preg_match("/Баланс\:([-\d]+)/",$text,$res))
//if(preg_match("/(Баланс)[:]*\s([-\d]+\,[\d]+)/",$text,$res))
//if(preg_match("/((Баланс)|(Ваш\sбаланс)) ([\d]+.[\d]+)/",$text,$res))
{
print_r($res);
$balance=$res[1];

echo "$dongle>$imsi>$balance";

save_balance($imsi, $balance);
upload_balance($imsi,$balance);
}


?>