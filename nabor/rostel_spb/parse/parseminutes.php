#!/usr/bin/php
<?
//$text="Остаток: 300.00 минут";
//$text=", 100 SMS";
//$text="Остаток: 0.00 минут из 300 в месяц, 0 SMS из 100 в сутки";


if(preg_match("/Остаток:\s([\d]+.[\d]+) минут/",$text,$res))
{
print_r($res);
$minutes=(int)$res[1]; //+300
//$minutes=(int)$res[1];

echo "$dongle>$imsi>$minutes";


$balance=file_get_contents("/var/simbox/sim/statistics/$imsi.balance");
//limit_hard= `cat /var/svistok/sim/limits/$imsi.limit_hard.3`


$min1=$minutes*60;
$min2=$minutes*60+($balance*60);
$min3=$minutes*60+($balance*60)+600;
$min4=$minutes*60+($balance*60)+20000;
$min5=($minutes-5)*60/4*3;
$min6=($minutes-5)*60/4*1;


echo "$dongle>$imsi>$min1>$min2>$min5!";
file_put_contents("/var/svistok/sim/limits/$imsi.limit.3",$min5);
file_put_contents("/var/svistok/sim/limits/$imsi.limit.4",$min6);
}


if(preg_match("/,\s([\d]+)\sSMS из 100/",$text,$res))
{
print_r($res);
$sms=(int)$res[1];

echo "$dongle>$imsi>$sms";
file_put_contents("/var/svistok/sim/limits/$imsi.limit.smsday",$sms);

file_put_contents("/var/simbox/sim/settings/$imsi.smsout_sended",100-$sms);

}

if(preg_match("/,\s([\d]+)\sSMS iz 100/",$text,$res))
{
print_r($res);
$sms=(int)$res[1];

echo "$dongle>$imsi>$sms";
file_put_contents("/var/svistok/sim/limits/$imsi.limit.smsday",$sms);

file_put_contents("/var/simbox/sim/settings/$imsi.smsout_sended",100-$sms);

}




if(preg_match("/Ostatok:\s([\d]+.[\d]+) minut/",$text,$res))
{
print_r($res);
$minutes=(int)$res[1]; //+300;
//$minutes=(int)$res[1];


echo "$dongle>$imsi>$minutes";


$balance=file_get_contents("/var/simbox/sim/statistics/$imsi.balance");
//limit_hard= `cat /var/svistok/sim/limits/$imsi.limit_hard.3`


$min1=$minutes*60;
$min2=$minutes*60+($balance*60);
$min3=$minutes*60+($balance*60)+600;
$min4=$minutes*60+($balance*60)+20000;
$min5=($minutes-5)*60/4*3;
$min6=($minutes-5)*60/4*1;

echo "$dongle>$imsi>$min1>$min2";
file_put_contents("/var/svistok/sim/limits/$imsi.limit.3",$min5);
file_put_contents("/var/svistok/sim/limits/$imsi.limit.4",$min6);
}


if(preg_match("/,\s([\d]+)\sSMS/",$text,$res))
{
print_r($res);
$sms=(int)$res[1];

echo "$dongle>$imsi>$sms";

file_put_contents("/var/svistok/sim/limits/$imsi.limit.smsday",$sms);
}


?>