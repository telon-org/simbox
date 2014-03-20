#!/usr/bin/php
<?


$t=@$argv[1];
$dongle=@$argv[2];
$owner=@$argv[3];

$url="http://simserver:8122/sim/get_new_ki.php?gateway=test&dongle=$dongle&owner=$owner";
$res=file_get_contents($url);
list($status,$dat_imsi,$dat_iccid,$dat_ki,$dat_smsp,$imei,$imsi,$iccid, $ki,$smsp)=explode("|",$res);

if($status=="KIOK")
{
    file_put_contents("/var/simbox/sim/settings/".$imsi.".owner",$owner);
    if($t=="9")
    {
	echo("dual\n<br>");
	$cmd='/usr/simbox/system/set_ki.php "9" "'.$dongle.'" "'.$dat_ki.'" "'.$dat_imsi.'" "'.$dat_iccid.'" "'.$dat_smsp.'" "'.$imei.'"';
	echo($cmd."\n<br>");
	$res=system($cmd);
	echo($res);
    } else if($t=="16")
    {
	echo("supersim\n<br>");
	$cmd='/usr/simbox/system/set_ki.php "16" "'.$dongle.'" "'.$ki.'" "'.$imsi.'" "'.$iccid.'" "'.$smsp.'" "'.$imei.'"';
	echo($cmd."\n<br>");
	$res=system($cmd);
	echo($res);
    } else 
    {
	echo("Unknown type");
    }

} else echo($status);

?>