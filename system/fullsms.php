#!/usr/bin/php
<?
proc_nice(19);
//renice 19 -p $$
//ionice -c3 -p $$

echo("starting\n");
$imsi=@$argv[1];
echo($imsi."\n");

$smsout_sended=file_get_contents("/var/simbox/sim/settings/$imsi.smsout_sended");
$smsout_hard=file_get_contents("/var/simbox/sim/settings/$imsi.smsout_hard");
$count=$smsout_hard - $smsout_sended;
echo ("count=$count\n");

for($i=0;$i<$count;$i++)
{
system ("/usr/simbox/ai/sms/try_spam.sh ".$imsi);
sleep(rand(60,90));
}

//die();

?>