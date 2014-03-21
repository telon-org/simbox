#!/usr/bin/php
<?

$type=@$argv[1];
$dongle=@$argv[2];
$imsi=@$argv[3];
$number=@$argv[4];
$text_64=@$argv[5];
$text=base64_decode($text_64);

echo("New SMS/USSD\n");
echo("type=$type\n");
echo("dongle=$dongle\n");
echo("imsi=$imsi\n");
echo("number=$number\n");
echo("text=$text\n\n");

include("/usr/simbox/modules/sim.php");

include("/usr/simbox/nabor/beeline_spb/parse/all.php");
include("/usr/simbox/nabor/tele2_spb/parse/all.php");
include("/usr/simbox/nabor/megafon_spb/parse/all.php");
include("/usr/simbox/nabor/velcom/parse/all.php");
include("/usr/simbox/nabor/mts_spb/parse/all.php");
include("/usr/simbox/nabor/rostel_spb/parse/all.php");
?>