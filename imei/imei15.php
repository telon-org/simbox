<?

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

function generate_imei($imeib)
{
    $c=14-strlen($imeib);
    $a=pow(10,($c-1));
    $b=pow(10,($c))-1;
    //echo("$a $b");
    $imeim=rand($a,$b);
    $imeie=get15($imeib.$imeim);
    //echo("$imeib|$imeim|$imeie\n");
    echo("$imeib$imeim$imeie\n");
}

//generate_imei("35518505");
for($i=0;$i<30;$i++)
{
generate_imei("86861600006");
}
//86861600

?>