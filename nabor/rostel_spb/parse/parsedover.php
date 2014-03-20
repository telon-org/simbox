#!/usr/bin/php
<?
//$text="Услуга подключена на 3 дня; с вашего счета спишется плата за услуг";
//Услуга предоставляется абонентам со стажем более 3 мес. Стаж: 1
//Услуга предоставляется абонентам, чьи траты на связь
//Услуга предоставляется при балансе от -30.00 до 60.00

if(preg_match("/Начислен обещанный платёж/",$text,$res))
{
print_r($res);

$op_t="до";
$op_d=time()+(86400*3);

echo "$dongle>$op_t>$op_d";

save_op($imsi, $op_t,$op_d);
upload_op($imsi,$op_t,$op_d);
}


if(preg_match("/Nachislen obeshhanny'j platyozh/",$text,$res))
{
print_r($res);

$op_t="до";
$op_d=time()+(86400*3);

echo "$dongle>$op_t>$op_d";

save_op($imsi, $op_t,$op_d);
upload_op($imsi,$op_t,$op_d);
}



if(preg_match("/Баланс не соответствует параметрам услуги/",$text,$res))
{
print_r($res);

$op_t_old=file_get_contents_def2($path_simbox_sim_statistics.$imsi.'.op_t',"");

if($op_t_old=="")
{
$op_t="баланс";
$op_d=time();

echo "$dongle>$op_t>$op_d";

save_op($imsi, $op_t,$op_d);
upload_op($imsi,$op_t,$op_d);
}
/*
 else {
$op_t="до";
$op_d=time()+(86400*3);

echo "$dongle>$op_t>$op_d";

save_op($imsi, $op_t,$op_d);
upload_op($imsi,$op_t,$op_d);
}
*/


}




if(preg_match("/Обещанный платеж недоступен/",$text,$res))
{
print_r($res);

//$op_t_old=file_get_contents_def2($path_simbox_sim_statistics.$imsi.'.op_t',"");
//if($op_t_old=="")
//{
$op_t="недоступен";
$op_d=time();

echo "$dongle>$op_t>$op_d";

save_op($imsi, $op_t,$op_d);
upload_op($imsi,$op_t,$op_d);
//}
}



/*
if(preg_match("/Услуга предоставляется абонентам, чьи траты на связь/",$text,$res))
{
print_r($res);

$op_t="<50";
$op_d=time();

echo "$dongle>$op_t>$op_d";

save_op($imsi, $op_t,$op_d);
upload_op($imsi,$op_t,$op_d);
}


if(preg_match("/Услуга предоставляется только незаблокированным абонентам/",$text,$res))
{
print_r($res);

$op_t="блок";
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
$op_d=(floor(time()/86400)*86400)+((90-$st)*86400);

echo "$dongle>$st>$op_t>$op_d";

save_op($imsi, $op_t,$op_d);
upload_op($imsi,$op_t,$op_d);
}


*/

?>