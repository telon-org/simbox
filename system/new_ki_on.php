#!/usr/bin/php
<?

$dongle=@$argv[1];
$owner=@$argv[2];

$url="http://simserver:8122/sim/get_new_ki.php?gateway=test&dongle=$dongle&owner=$owner";
$res=file_get_contents($url);
list($status,$dat_imsi,$dat_iccid,$dat_ki,$dat_smsp)=explode("|",$res);

if($status=="KIOK")
{
 $cmd='/usr/simbox/system/set_ki_on.php 9 "'.$dongle.'" "'.$dat_ki.'" "'.$dat_imsi.'" "'.$dat_iccid.'" "'.$dat_smsp.'"';
 $res=system($cmd);
 echo($res);
} else echo($status);

?>