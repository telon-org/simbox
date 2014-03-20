#!/usr/bin/php
<?
//$text="Ваш баланс составляет минус 679 рублей.";
//$text="Vash balans sostavlyaet 38643 rublej.";

if(preg_match("/((Ваш баланс составляет)|(Vash balans sostavlyaet))\s((минус\s)|(minus)*)([\-\d]+)/",$text,$res))
{
print_r($res);
$balance=(int)$res[7];

if($res[4]=="минус ")
{
$balance=-$balance;
}


echo "$dongle>$imsi>$balance";
file_put_contents("/var/simbox/sim/statistics/$imsi.balance",$balance);
file_put_contents("/var/simbox/sim/statistics/$imsi.get_balance_response",time());

    if($balance<100)
    {
        $group=file_get_contents("/var/simbox/sim/settings/$imsi.group");
        if(($group>=120)&&($group<=150))
        {
	    system ('/usr/sbin/asterisk -rx "dongle setgroupimsi '.$imsi.' 335"');
	}
    }
upload_balance($imsi,$balance);
}


?>