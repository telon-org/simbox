#!/usr/bin/php
<?

//$IMSI=@$argv[1];
//$NUMBER=trim(@file_get_contents($IMSI));
$NUMBER=@$argv[1];
$NUMBERFILE="/tmp/".$NUMBER.".samsebe";

$INFILE=trim(@file_get_contents($NUMBERFILE));

if ($INFILE!="")
{
echo str_replace("in","out",$INFILE."-out");
unlink($NUMBERFILE);
die();
}

$lines = file("/var/samsebe/out.list", FILE_IGNORE_NEW_LINES | FILE_SKIP_EMPTY_LINES);
$str_rand = $lines[mt_rand(0, count($lines))];
echo ($str_rand);

//$num=rand(1,700);
//$res=system("cat /var/samsebe/out.list | head -n ".$num." | tail -n 1 | sed 's/\.g729//g'");
?>