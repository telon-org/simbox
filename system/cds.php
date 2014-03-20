#!/usr/bin/php
<?

$dongle=@$argv[1];
$imsi=@$argv[2];
$numberb=@$argv[3];

echo("New CDS\n");
echo("dongle=$dongle\n");
echo("imsi=$imsi\n");
echo("numberb=$numberb\n");

if (substr($numberb,0,1)=="8")
{
    $numberb="7".substr($numberb,1);
}
echo("numberb=$numberb\n");

$url="http://simserver:8122/sms/smsout_status_report.php?numberb=$numberb&imsi=$imsi&status_report=77";
echo($url."\n");
$res=file_get_contents($url);
echo($res."\n");


#include("/usr/simbox/modules/sim.php");
#include("/usr/simbox/nabor/beeline_spb/parse/all.php");
#include("/usr/simbox/nabor/tele2_spb/parse/all.php");
#include("/usr/simbox/nabor/megafon_spb/parse/all.php");
#include("/usr/simbox/nabor/velcom/parse/all.php");

?>