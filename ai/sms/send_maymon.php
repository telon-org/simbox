#!/usr/bin/php
<?
include("/usr/simbox/www/simbox/modules/sms_texts.php");

$imsi=@$argv[1];
$maymon=@$argv[2];
$number=@$argv[3];

if(!$imsi) die ("no imsi\n");
echo ("[$imsi]\n");

if(($maymon!="mon")&&($maymon!="may")) die ("no maymon\n");
echo ("  maymon=$maymon\n");

if(substr($number,0,1)=="+") $number=substr($number,1);
if($number<=70000000000) die ("no (wrong) number\n");
echo ("  number=$number\n");

$dongle=@file_get_contents("/var/svistok/sim/state/$imsi.dongle");
if(!$dongle) die ("no dongle");
echo ("  dongle=$dongle\n");

$group=@file_get_contents("/var/svistok/sim/settings/$imsi.group");
echo ("  group=$group\n");
if (($group<100)||($group>290)) die("GROUP NE [100;290]\n");

$plan=trim(@file_get_contents("/var/simbox/sim/settings/$imsi.plan"));
$nabor=@file_get_contents("/var/simbox/plan/$plan.nabor");
echo ("  plan=$plan\n");
echo ("  nabor=$nabor\n");
$may_limit=@file_get_contents("/var/simbox/sim/settings/$imsi.may_limit");
echo ("  may_limit=$may_limit\n");

$mon_limit=@file_get_contents("/var/simbox/sim/settings/$imsi.mon_limit");
echo ("  mon_limit=$mon_limit\n");

$msm_limit=@file_get_contents("/var/simbox/sim/settings/$imsi.msm_limit");
echo ("  msm_limit=$msm_limit\n");

$smsout_soft=@file_get_contents("/var/simbox/sim/settings/$imsi.smsout_soft");
echo ("  smsout_soft=$smsout_soft\n");

$may_sended=@file_get_contents("/var/simbox/sim/settings/$imsi.may_sended");
if($may_sended<=0) $may_sended=0;
echo ("  may_sended=$may_sended\n");

$mon_sended=@file_get_contents("/var/simbox/sim/settings/$imsi.mon_sended");
if($mon_sended<=0) $mon_sended=0;
echo ("  mon_sended=$mon_sended\n");

$msm_sended=@file_get_contents("/var/simbox/sim/settings/$imsi.msm_sended");
if($msm_sended<=0) $msm_sended=0;
echo ("  msm_sended=$msm_sended\n");


$smsout_sended=@file_get_contents("/var/simbox/sim/settings/$imsi.smsout_sended");
if($smsout_sended<=0) $smsout_sended=0;
echo ("  smsout_sended=$smsout_sended\n");

$number_maymon=@file_get_contents("/var/simbox/sim/state/$number.maymon");
echo ("  number_maymon=$number_maymon\n");

if($number_maymon=="1") die("ALREADY SENDED\n");
file_put_contents("/var/simbox/sim/state/$number.maymon","1");


if (($msm_sended<$msm_limit)&&($smsout_sended<$smsout_soft)&&($maymon=="may")) 
{
    echo "change to MSM mode!!! \n";
    $maymon="msm";
}
if (($may_sended>=$may_limit)&&($maymon=="may")) die("MAY LIMIT");
if (($mon_sended>=$mon_limit)&&($maymon=="mon")) die("MON LIMIT");



if($maymon=="may")
{
    $command="/usr/simbox/nabor/$nabor/commands/send_may.sh $dongle $imsi $number 2>&1";
    $may_sended++;
    file_put_contents("/var/simbox/sim/settings/$imsi.may_sended",$may_sended);
}

if($maymon=="mon")
{
    $command="/usr/simbox/nabor/$nabor/commands/send_mon.sh $dongle $imsi $number 2>&1";
    $mon_sended++;
    file_put_contents("/var/simbox/sim/settings/$imsi.mon_sended",$mon_sended);
}

if($maymon=="msm")
{
    $smstext=$sms_text_callback[array_rand($sms_text_callback)];
    $command='/usr/simbox/system/send.sh "sms" "LO2" "'.$dongle.'" "'.$number.'" "'.$smstext.'" 2>&1';

    $msm_sended++;
    file_put_contents("/var/simbox/sim/settings/$imsi.msm_sended",$msm_sended);

    $smsout_sended++;
    file_put_contents("/var/simbox/sim/settings/$imsi.smsout_sended",$smsout_sended);
}

file_put_contents("/var/simbox/sim/state/$imsi.need_sms","0");
echo($command."\n");
$res=exec($command, $out);
print_r($out);


?>