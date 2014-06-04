#!/usr/bin/php
<?
//$imsi="250392780260529";
$group=trim(file_get_contents("/var/svistok/sim/settings/$imsi.group"));




if (($group==232))
{
    $balance=trim(file_get_contents("/var/simbox/sim/statistics/$imsi.balance"));
    if($balance=="") $balance=100;
    //print_r($res);
    echo "$imsi>$balance";

    if($balance<4) 
    {
    
    system ('/usr/sbin/asterisk -rx "dongle setgroupimsi '.$imsi.' 335"');
    }
}




?>