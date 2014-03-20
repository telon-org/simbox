#!/usr/bin/php
<?
//die();

$imsi=@$argv[1];
if(!$imsi) die ("no imsi\n");
echo ("[$imsi]\n");

$dongle=@file_get_contents("/var/svistok/sim/state/$imsi.dongle");
if(!$dongle) die ("no dongle");
echo ("  dongle=$dongle\n");

$group=@file_get_contents("/var/svistok/sim/settings/$imsi.group");
echo ("  group=$group\n");

$smsout_soft=@file_get_contents("/var/simbox/sim/settings/$imsi.smsout_soft");
echo ("  smsout_soft=$smsout_soft\n");

$smsout_hard=@file_get_contents("/var/simbox/sim/settings/$imsi.smsout_hard");
echo ("  smsout_hard=$smsout_hard\n");

$smsout_sended=@file_get_contents("/var/simbox/sim/settings/$imsi.smsout_sended");
if($smsout_sended<=0) $smsout_sended=0;
echo ("  smsout_sended=$smsout_sended\n");



if ($smsout_sended>=$smsout_hard) die("LIMIT smsout_hard\n");


//$nospam=@file_get_contents("/var/simbox/sim/settings/$imsi.nospam");
//if($nospam!=2) die ("canspam!=2\n");


echo ("  Try SPAM SMS\n");
$cmd='curl -s "http://simserver:8122/sms/smsout_getnew.php?imsi='.$imsi.'&group='.$group.'&private=2"';
echo($cmd."\n");
$sms=system($cmd);
if(strlen($sms)<4) die("NULL RESPONSE\n");
@list($action,$smsoutid,$numberb,$text)=explode("|",$sms);
if($action=="NOTHING NEW") die("NOTHING NEW\n");
echo("=>$action\n  smsoutid:$smsoutid\n  to:$numberb\n  text:$text\n");


echo ("  Send sms\n");
$smsdone="/var/svistok/sim/state/$imsi.smsdone";
@unlink($smsdone);
$cmd='/usr/simbox/system/send.sh "sms" "LO2" "'.$dongle.'" "'.$numberb.'" "'.$text.'"';
echo($cmd."\n");
$res=system ($cmd);
echo ($res."\n");
$res2=file_get_contents($smsdone);

if($res2!=1)
{
    echo "cannot send! res2=$res2\n";
    //send_failed
    echo ("  Send FAILED\n");
    $cmd='curl -s "http://simserver:8122/sms/smsout_failed.php?smsoutid='.$smsoutid.'"';
    echo($cmd."\n");
    $res=system($cmd);
    echo $res."\n";

} else {
    $smsout_sended++;
    file_put_contents("/var/simbox/sim/settings/$imsi.smsout_sended",$smsout_sended);

    echo ("  Send response\n");
    $cmd='curl -s "http://simserver:8122/sms/smsout_sended.php?smsoutid='.$smsoutid.'&imsi='.$imsi.'"';
    echo($cmd."\n");
    $res=system($cmd);
    echo $res."\n";
}


?>