#!/usr/bin/php
<?
//$text="Услуга подключена на 3 дня; с вашего счета спишется плата за услуг";
$text="Услуга предоставляется абонентам со стажем более 3 мес. Стаж: 1";
//Услуга предоставляется абонентам, чьи траты на связь

if(preg_match("/Услуга подключена на 3 дня; с вашего счета спишется плата за услуг/",$text,$res))
{
print_r($res);

$op_t="до";
$op_d=time()+(86400*3);

echo "$dongle>$op_t>$op_d";

save_op($imsi, $op_t,$op_d);
upload_op($imsi,$op_t,$op_d);
}


if(preg_match("/Услуга предоставляется абонентам, чьи траты на связь/",$text,$res))
{
print_r($res);

$op_t="<50";
$op_d=time();

echo "$dongle>$op_t>$op_d";

save_op($imsi, $op_t,$op_d);
upload_op($imsi,$op_t,$op_d);
}


if(preg_match("/Услуга предоставляется абонентам со стажем более 3 мес. Стаж: (\d*)/",$text,$res))
{
print_r($res);

$st=$res[1];
$op_t="после";
$op_d=time()+((90-$st)*86400);

echo "$dongle>$st>$op_t>$op_d";

save_op($imsi, $op_t,$op_d);
upload_op($imsi,$op_t,$op_d);
}




?>