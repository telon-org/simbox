#!/usr/bin/php
<?


function array_lapp($ll, &$res)
{
    //echo("array_lapp($ll, $res)");
    //print_r($res);
    for($i=0;$i<count($res);$i++)
    {
	$res[$i]=$ll.$res[$i];
    }
    //print_r($res);

}



function patterns($from, $to)
{
    $all_0="000000000000000";
    $all_9="999999999999999";
    $all_X="XXXXXXXXXXXXXXX";

    //echo("patt $from-$to\n");
    $res=array();


    if(strlen($from)!=strlen($to))
    {
	die("\n\nfrom=$from\nto=$to\nstrlen(from)!=strlen(to)\n");
    }

    if($from==$to)
    {
	$res[]=$from;
	return $res;
    }

    if(($from=="0")&&($to=="9")) 
    {
	$res[]="X";
	return $res;
    }

    if(strlen($from)==1)
    {
	$res[]="[$from-$to]";
	return $res;
    }

    if(($from=="")&&($to=="")) 
    {
	$res[]="";
	return $res;
    }


    for($i=0;$i<strlen($from);$i++)
    {
	if(substr($from,$i,1)!=substr($to,$i,1)) break;
    }

    $l=substr($from,0,$i);
    $r1=substr($from,$i);
    $r2=substr($to,$i);

    //echo("i=$i l=$l r1=$r1 r2=$r2\n");

    //echo(" >=".substr($r1,0,1)." ");
    $b1=substr($r1,0,1);
    $b2=substr($r2,0,1);

    $c1=substr($r1,1);
    $c2=substr($r2,1);

    if($c1!=substr($all_0,0,strlen($c1)))
    {
	$a1=patterns($c1,substr($all_9,0,strlen($c1)));
	array_lapp(substr($r1,0,1),$a1);
	$b1++;
    } else $a1=array();

    if($c2!=substr($all_9,0,strlen($c2)))
    {
	$a2=patterns(substr($all_0,0,strlen($c2)),$c2);
	array_lapp(substr($r2,0,1),$a2);
	$b2--;
    } else $a2=array();

    $rr="[".$b1."-".$b2."]";
    if(($b1=="0")&&($b2=="9")) $rr="X";

    $a3[]=$rr.substr($all_X,0,strlen($c1));



    $res=array_merge($a1,$a3,$a2);
    array_lapp($l,$res);
    return $res;
}

//$p=patterns("1000000","1009999");
//$p=patterns("0000","9999");
//$p=patterns("2947","2949");
//print_r($p);
//die();


$DOWNFILE=$argv[1]; 
//DOWNFILE='http://www.rossvyaz.ru/docs/num/DEF-9x.html';

//рабочая папка
$TMPDIR='./tmp/';
$RESDIR='./res/';
//файл, где сохраним csv формат кодов
$FILENAME='codes';

$OPER=$argv[2];
//$OPEARTOR="";
//echo("OPER=$OPER\n");

//какой регион будем выделять
$REGION=$argv[3];
//REGION='Новосибирская область';
//echo("REGION=$REGION\n");
//die();

$EXTEN=$argv[4];
//EXTEN="test";

$PRICE=$argv[5];

$LENGTH=10;


//die("\n\n$DOWNFILE\n\n");

$f = fopen($DOWNFILE, "r");
if(!$f) die("no file");
$f1 = fopen("$RESDIR/zones/extensions_$EXTEN.conf", "w");
$f2 = fopen("$RESDIR/price.csv", "a");
$f3 = fopen("$RESDIR/extensions_zones.conf", "a");
$f4 = fopen("$RESDIR/codes.csv", "a");

fputs($f3,"#include \"/etc/asterisk/extensions/zones/extensions_$EXTEN.conf\"\n");



//printf("$OPER $REGION\n");

while(!feof($f)) 
{
    $line=fgets($f);
    if ($line!="")
    {
	$line=rtrim($line);
	list($def,$from,$to,$total,$op,$reg)=explode(";",$line);
	fputs($f4,"list($def,$from,$to,$total,$op,$reg)\n");

	$u1=false;
	$u2=false;

	//echo("$op $reg");
	//echo("$reg $reg");

	if($OPER=="") $u1=true; else if ((strpos($op,$OPER)!=false)||($op==$OPER)) $u1=true;
	if($REGION=="") $u2=true; else if((strpos($reg,$REGION)!=false)||($reg==$REGION)) $u2=true;
	//$u1=true;

	//echo("($op,$OPER) ($reg,$REGION) $u1&&$u2 \n");


	if($u1&&$u2)
	{
	    //echo("($op,$OPER) ($reg,$REGION) $u1&&$u2 \n");

	    $ex=patterns($from, $to);
	
	    foreach($ex as $e)
	    {
	        fputs($f1,"exten => _7$def$e,1,Macro(makecall,$EXTEN,\${EXTEN})\n");
	        fputs($f2,"7$def$e;$EXTEN;$op;$reg;$PRICE\n");

	        //echo($e);
	    }
	}
    }
}
    fclose($f);
    fclose($f1);
    fclose($f2);
    fclose($f3);
    fclose($f4);



?>

