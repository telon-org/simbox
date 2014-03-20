#!/usr/bin/php
<?
$dongle=$argv[1]; // "dongle02";

$imei="111111111111111";
$url="http://simserver:8122/sim/get_new_imei.php";
$res=file_get_contents($url);
echo $res."<br>\n";
list($status,$imei)=explode("|",$res);
if($status=="IMEIOK") 
{
    $cmd='/usr/sbin/asterisk -rx "dongle changeimei '.$dongle.' '.$imei.'"';
    echo $cmd;
    system($cmd);
} else
{
    echo("status=$status NO ACTION");
}


?>