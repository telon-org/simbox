#!/usr/bin/php
<?
function get_new_imei()
{
    $imei=0;
    $url="http://simserver:8122/sim/get_new_imei.php";
    $res=file_get_contents($url);
    echo $res."<br>\n";
    list($status,$imei)=explode("|",$res);
    if($status=="IMEIOK") 
    {
	echo("IMEIOK=$imei")
    } else
    {
	echo("status=$status NO ACTION");
    }
    return $imei;
}

function change_imei($dongle,$imei)
{
    $cmd='/usr/sbin/asterisk -rx "dongle changeimei '.$dongle.' '.$imei.'"';
    echo $cmd;
    system($cmd);
}

function check_imei($dongle, $imei)
{
    return TRUE;
}

?>