<?
/* RAND */

while(1)
{
$file=file("check.rand");
foreach ($file as $line)
{
    echo ("line = $line\n");
    $line=trim($line);
    $lft=substr($line,0,10);
    $m=rand(1000,9999);
    $line=$lft.$m;
    $g15=get15($line);
    $imei=$line.$g15;


    echo ("Checking $imei = ");
    $res=checkbase($imei);
    echo($res."\n");
    if($res==2) {file_put_contents("bad.rand.txt", $imei."\n", FILE_APPEND | LOCK_EX); }
    if($res==5) {file_put_contents("good.rand.txt", $imei."\n", FILE_APPEND | LOCK_EX); }
    if($res==0) {echo("\n\nWARNING!!!! res=0\n\n"); sleep(10);}
//    sleep(2);
}
}
/*

$file=file("check.txt");
foreach ($file as $line)
{
    $line=trim($line);

$ok=1;
while($ok>-5)
{

    if(strlen($line)==15)
    {
	$imei=$line;
    } else if(strlen($line)==14)
    {
        $g15=get15($line);
        $imei=$line.$g15;
    } else die(" wrong len $line ".strlen($line)."\n");


    echo ("Checking $imei = ");
    $res=checkbase($imei);
    echo($res."\n");
    if($res==2) {file_put_contents("bad.txt", $imei."\n", FILE_APPEND | LOCK_EX); $ok=$ok-1;}
    if($res==5) {file_put_contents("good.txt", $imei."\n", FILE_APPEND | LOCK_EX); $ok=1;}
    if($res==0) {echo("\n\nWARNING!!!! res=0\n\n"); sleep(10); $ok=-5;}
    sleep(2);
    if($ok==1)
    {
	echo ("try next +1 ...\n");
	$g10=substr($imei,0,10);
	$g5=substr($imei,10,4);
	$gn=$g5+1;
	$line=$g10.$gn;
    }

    if($ok==0)
    {
	echo ("try next +9 ...\n");
	$g10=substr($imei,0,10);
	$g5=substr($imei,10,4);
	$gn=$g5+9;
	$line=$g10.$gn;
    }

    if($ok==-1)
    {
	echo ("try next +90 ...\n");
	$g10=substr($imei,0,10);
	$g5=substr($imei,10,4);
	$gn=$g5+90;
	$line=$g10.$gn;
    }

    if($ok==-2)
    {
	echo ("try next +900 ...\n");
	$g10=substr($imei,0,10);
	$g5=substr($imei,10,4);
	$gn=$g5+900;
	$line=$g10.$gn;
    }

    if($ok==-3)
    {
	echo ("try next +9000 ...\n");
	$g10=substr($imei,0,10);
	$g5=substr($imei,10,4);
	$gn=$g5+9000;
	$line=$g10.$gn;
    }


    if($ok==-4)
    {
	echo ("try next +90000 ...\n");
	$g10=substr($imei,0,10);
	$g5=substr($imei,10,4);
	$gn=$g5+90000;
	$line=$g10.$gn;
    }
    
    if(strlen($line)<14) $ok=-5;

}

}
*/


function get15($imei_14)
{
//echo($imei_14."\n");
//1
$ch="";
$s=0;
for($i=1;$i<=14;$i++)
{
$c=$imei_14[$i-1];
if (($i % 2)==0)
{
$c=$c*2;
if ($c>=10) $c=(int)($c/10)+($c%10);
//$ch=$ch+$c;
} else
{
//$nch=$nch+$c;
}
//echo("$i $c\n");
$s=$s+$c;
}
//echo("s=".$s."\n");
/*$x=$s;

    $x=((round($x/10))*10)-$x;
    if($x==10) $x=0;
*/
$x=10-($s%10);

if ($x==10) $x=0;
return $x;
}

function checkbase($imei)
{
	    $post="q=".$imei;

            $output = "POST http://gtk.gov.by/ru/consult/imei HTTP/1.1\r\n"
              ."Host: gtk.gov.by\r\n"
              ."Content-type: application/x-www-form-urlencoded\r\n"
              ."Content-length: " . strlen ($post) . "\r\n"
              ."Connection: Close\r\n\r\n"
              .$post;

            $fp = fsockopen ('gtk.gov.by', 80);
            fwrite ($fp, $output);
	    $contents = stream_get_contents($fp);
            fclose ($fp);

	//echo($contents);
	if (strstr($contents,"Телефон зарегистрирован")) return 5;
	if (strstr($contents,"Запись не найдена")) return 2;
	return 0;
}


?>