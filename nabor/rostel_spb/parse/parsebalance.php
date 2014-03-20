#!/usr/bin/php
<?
//$text="OCTATOK 50.00 p.";
//$text="OCTATOK MEHEE 10p";
//$text="OCTATOK munyc 10.24 p.";
//
//$text=".OCTATOK munyc 3 p.";

if(preg_match("/OCTATOK( munyc)*\s([\d]+.[\d]+)/",$text,$res))
{
print_r($res);
$balance=(int)$res[2];
if($res[1]==" munyc")
{
$balance=-$balance;
}

echo "$dongle>$imsi>$balance";
save_balance($imsi,$balance);
upload_balance($imsi,$balance);
}

if(preg_match("/OCTATOK( munyc)*\s([\d]+)\sp/",$text,$res))
{
print_r($res);
$balance=(int)$res[2];
if($res[1]==" munyc")
{
$balance=-$balance;
}

echo "$dongle>$imsi>$balance";
save_balance($imsi,$balance);
upload_balance($imsi,$balance);
}


if(preg_match("/OCTATOK MEHEE 10p/",$text,$res))
{
    $group=file_get_contents("/var/simbox/sim/settings/$imsi.group");
    if($group=="210")
    {
	system ('/usr/sbin/asterisk -rx "dongle setgroupimsi '.$imsi.' 109"');
    }
}

?>