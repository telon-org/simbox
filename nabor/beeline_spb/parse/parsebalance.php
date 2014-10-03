#!/usr/bin/php
<?
//$text="Баланс 150.00 руб";


if(preg_match("/((Баланс)|(Ваш\sбаланс)|(Balans)|(Vash\sbalans))[:]*\s([-\d]+.[\d]+)/",$text,$res))
{
print_r($res);
$balance=$res[6];

echo "$dongle>$imsi>$balance";

save_balance($imsi, $balance);
upload_balance($imsi,$balance);
}

if(preg_match("/((Баланс)|(Ваш\sбаланс)|(Balans)|(Vash\sbalans))([-\d]+.[\d]+)/",$text,$res))
{
print_r($res);
$balance=$res[6];

echo "$dongle>$imsi>$balance";

save_balance($imsi, $balance);
upload_balance($imsi,$balance);
}

if(preg_match("/([-\d]+.[\d]+)\sр/",$text,$res))
{
print_r($res);
$balance=$res[6];

echo "$dongle>$imsi>$balance";

save_balance($imsi, $balance);
upload_balance($imsi,$balance);
}


?>