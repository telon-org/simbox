#!/usr/bin/php
<?
$t1=@$argv[1];
$t2=@$argv[2];
if($t2<=0) $t2=10;
$t=rand($t1,$t1+$t2);
echo "sleep $t";
sleep($t);
?>