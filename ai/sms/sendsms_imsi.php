#!/usr/bin/php
<?
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

$nospam=@file_get_contents("/var/simbox/sim/settings/$imsi.nospam");
echo ("  nospam=$nospam\n");


$trypri=0;
$trypub=0;
$tryspam=0;

$tosend=0;

//if ($smsout_sended<$smsout_hard) $trypri=1;
//if ($smsout_sended<$smsout_soft) $trypub=1;
if (($smsout_sended<$smsout_hard)&&($nospam=="2")) $tryspam=2;

echo( "  trypri=$trypri\n");
echo( "  trypub=$trypub\n");
echo( "  tryspam=$tryspam\n");

if ($trypri==1)
{
echo ("  Try private SMS\n");
$cmd='curl -s "http://simserver:8122/sms/smsout_getnew.php?imsi='.$imsi.'&group='.$group.'&private=1"';
echo($cmd."\n");
$sms=system($cmd);
@list($action,$smsoutid,$numberb,$text)=explode("|",$sms);
if($action!="NOTHING NEW")
    {
    $tosend=1;
    echo("=>$action\n  smsoutid:$smsoutid\n  to:$numberb\n  text:$text\n");
    }
}

if(($trypub==1)&&($tosend==0))
{
    echo ("  Get new SMS\n");
    $cmd='curl -s "http://simserver:8122/sms/smsout_getnew.php?imsi='.$imsi.'&group='.$group.'&private=0"';
    echo($cmd."\n");
    $sms=system($cmd);
    @list($action,$smsoutid,$numberb,$text)=explode("|",$sms);
    if($action=="NOTHING NEW") die($action."\n"); else $tosend=1;

}

if(($tryspam==2)&&($tosend==0))
{
    echo ("  Get SPAM SMS\n");
    $cmd='curl -s "http://simserver:8122/sms/smsout_getnew.php?imsi='.$imsi.'&group='.$group.'&private=2"';
    echo($cmd."\n");
    $sms=system($cmd);
    @list($action,$smsoutid,$numberb,$text)=explode("|",$sms);
    if($action=="NOTHING NEW") die($action."\n"); else $tosend=1;

}


if($tosend==1)
{
echo ("  Send sms\n");
$cmd='/usr/simbox/system/send.sh "sms" "FOR" "'.$dongle.'" "+'.$numberb.'" "'.$text.'"';
//$cmd='/usr/sbin/asterisk -rx "dongle sms '.$dongle.' '.$numberb.' '.$text.'"';
echo($cmd."\n");
$res=system ($cmd);
echo ($res."\n");

$smsout_sended++;
file_put_contents("/var/simbox/sim/settings/$imsi.smsout_sended",$smsout_sended);

echo ("  Send response\n");
$cmd='curl -s "http://simserver:8122/sms/smsout_sended.php?smsoutid='.$smsoutid.'&imsi='.$imsi.'"';
echo($cmd."\n");
$res=system($cmd);
echo $res."\n";
}



?>