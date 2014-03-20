#!/usr/bin/php
<?

$list=file("/var/svistok/lists/imsi.list");

foreach($list as $k=>$imsi)
{
$imsi=trim($imsi);
$plan=trim(@file_get_contents("/var/simbox/sim/settings/$imsi.plan"));
$nabor=trim(@file_get_contents("/var/simbox/plan/$plan.nabor"));

echo("$imsi\n");

if ("$nabor"=="tele2_spb")
    echo("-> set\n");
    file_put_contents("/var/simbox/sim/settings/$imsi.smsout_sended",0);
    file_put_contents("/var/simbox/sim/settings/$imsi.may_sended",0);
    file_put_contents("/var/simbox/sim/settings/$imsi.mon_sended",0);
    file_put_contents("/var/simbox/sim/settings/$imsi.msm_sended",0);
}
?>