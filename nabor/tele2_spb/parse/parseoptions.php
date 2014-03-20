#!/usr/bin/php
<?
//$text="Услуга SMS-свобода подключена ранее.";
//$text=", 100 SMS";

if(preg_match("/(SMS-свобода успешно подключена)|(SMS-свобода подключена)/",$text,$res))
{
//print_r($res);
//$minutes=(int)$res[1];
echo "$dongle>$imsi>$minutes";

echo("\n/var/simbox/sim/settings/$imsi.smsout_soft\n");
file_put_contents("/var/simbox/sim/settings/$imsi.limit.smsday_extra",200);
file_put_contents("/var/simbox/sim/settings/$imsi.smsout_soft",280);
file_put_contents("/var/simbox/sim/settings/$imsi.smsout_hard",290);
}




if(preg_match("/SMS до конца дня - ([\d]+)/",$text,$res))
{
//print_r($res);
$sms=(int)$res[1];

//file_put_contents("/var/simbox/sim/settings/$imsi.limit.smsout_extra_sended",200-$sms);
if($sms!=200)
    file_put_contents("/var/simbox/sim/settings/$imsi.smsout_sended",300-$sms);

}

?>