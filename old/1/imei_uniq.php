<?
/*
$full=file("good.txt");
$uniq=array_unique($full);
sort($uniq);


file_put_contents("good.uniq",$uniq);
*/

$uniq=file("good.uniq");

foreach($uniq as $line)
{
$line=trim($line);
$line=$line." ".rand(100000,999999);
file_put_contents("good.rand", $line."\n", FILE_APPEND | LOCK_EX);
}



?>