#!/usr/bin/php
<?
//$text="Ваш номер временно заблокирован";


if(preg_match("/Ваш номер временно заблокирован/",$text,$res))
{
print_r($res);

echo "$dongle>$imsi>blocked";
    $group=file_get_contents("/var/simbox/sim/settings/$imsi.group");
    if(($group>=100)&&($group<=190))
    {
	system ('/usr/sbin/asterisk -rx "dongle setgroupimsi '.$imsi.' 335"');
    }
}


?>