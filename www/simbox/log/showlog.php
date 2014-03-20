<?
header('Content-Type: text/html; charset=utf-8');
?>

<div align="left">
<font size=3>



<?
if(@$_GET['calls']==1)
{
    $imsi=@$_GET['imsi'];
    $dongle=@file_get_contents("/var/svistok/sim/state/".$imsi.'.dongle');
    $filename="/var/svistok/sim/log/".$imsi.".calls2";

    echo("<b>Лог звонков $dongle </b><br /><br />");
    if(!file_exists($filename)) {
        echo("Нет записей.");
    } else {

?>



<table cellspacing=0 cellpadding=1>
<tr>
<td><font size=1>d</td>
<td><font size=1>io</td>
<td><font size=1>spec</td>
<td><font size=1>im</td>
<td><font size=1>vip</td>
<td><font size=1>qos</td>
<td><font size=1>NUM</td>
<td><font size=1>n</td>
<td><font size=1>DIALSTATUS</td>
<td><font size=1>T=</td>
<td><font size=1>C</td>
<td><font size=1>+D</td>
<td><font size=1>+B</td>
<td width=200><font size=1>rec</td>
<td><font size=1>uid</td>
</tr>
<?

	$logContent=file($filename);
	$logContent = array_reverse($logContent);
$cnt=0;
	foreach($logContent as $line)
	{
$cnt++;
if(($cnt>=15)&&(@$cut==1)) break;
$io="O";
// vremennaya zaglushka
if(substr($line,0,2)=="O|")
{
    $io="O";
    $line=substr($line,2);
}
if(substr($line,0,2)=="I|")
{
    $io="I";
    $line=substr($line,2);
}


		@list($uid,$d,$vip,$spec,$qos,$naprstr,$im,$NUMBERA,$NUMBERB,$DIALSTATUS,$END_STATUS,$CC_CAUSE,$END_PARTY,$TOTALSEC,$pdds,$pdd,$BILLSEC)=explode("|",$line);
		//@list($io,$uid,$d,$vip,$spec,$qos,$naprstr,$im,$NUMBERA,$NUMBERB,$DIALSTATUS,$END_STATUS,$CC_CAUSE,$END_PARTY,$TOTALSEC,$pdds,$pdd,$BILLSEC)=explode("|",$line);
			$txt_pre_in=@file_get_contents("/var/svistok/sim/log/$uid-pre-in.rasp");
			$txt_pre_out=@file_get_contents("/var/svistok/sim/log/$uid-pre-out.rasp");
			$txt_ans_in=@file_get_contents("/var/svistok/sim/log/$uid-ans-in.rasp");
			$txt_ans_out=@file_get_contents("/var/svistok/sim/log/$uid-ans-out.rasp");
if(@$cut==1)
{
$txt_pre_in=mb_substr($txt_pre_in,0,100);
$txt_pre_out=mb_substr($txt_pre_out,0,100);
$txt_ans_in=mb_substr($txt_ans_in,0,100);
$txt_ans_out=mb_substr($txt_ans_out,0,100);

}

//echo("$uid,$d,$vip<br>");

//echo("$uid,$d,$vip,$spec,$qos,$naprstr,$im,$NUMBERA,$NUMBERB,$DIALSTATUS,$END_STATUS,$CC_CAUSE,$END_PARTY,$TOTALSEC,$pdds,$pdd,$BILLSEC");
?>
<tr>
<td>
<font size=1>
<?
//echo($d);
@list($dat,$tim)=explode(" ",$d);
echo($tim);
echo("<br><font color='#cccccc'>");
echo($dat);

?>
</td>
<td>
<?
                            if($io=="I")  echo("<img src=imgs/state_in.png>");
                            if($io=="O")  echo("<img src=imgs/state_out.png>");
?>
</td>
<td>
<?=html_spec("$spec")?>
</td>
<td>
<?
            if($im=="A")  echo("<img src=imgs/ima.png>");
            if($im=="B")  echo("<img src=imgs/imb.png>");
            if($im=="C")  echo("<img src=imgs/imc.ico>");
            if($im=="D")  echo("<img src=imgs/imd.ico>");
            if($im=="E")  echo("<img src=imgs/ime.ico>");
?>
</td>
<td>
<?
                            if($vip=="VIP")  echo("<img src=imgs/ivip.png>");
?>
</td>
<td>
<?
		$qosstr=$qos;

                            if($qos=="NOS")  $qosstr="<img src=imgs/inos.png>";
                            if($qos=="GOO")  $qosstr="<img src=imgs/igoo.png>";
                            if($qos=="BAD")  $qosstr="<img src=imgs/ibad.png>";
                            if($qos=="NOR")  $qosstr="<img src=imgs/inor.png>";
                            if($qos=="NEW")  $qosstr="<img src=imgs/inew.png>";
                            if(($qos=="SOU")&&($io=="O")) $qosstr="<img src=imgs/state_sout_out.ico>";
                            if(($qos=="SOU")&&($io=="I")) $qosstr="<img src=imgs/state_sout_out.ico>";
                            if($qos=="ROB")  $qosstr="<img src=imgs/irob.png>";
                            if($qos=="BLO")  $qosstr="<img src=imgs/iblo.png>";

		echo($qosstr);
?>
</td>
<td><font size=1><?=$NUMBERB?><br>
<font color="#cccccc"><?=$NUMBERA?>
<br>
</td>
<td>
<?
				echo(html_napr($naprstr));
?>
</td>

<td>
<?
	$dialst="<img src=imgs/napravleine/hz.ico><font size=1>".substr($DIALSTATUS,0,4);
	if($DIALSTATUS=="ANSWER")   $dialst="<img src=imgs/state_active.png>";
	if($DIALSTATUS=="NOANSWER") $dialst="<img src=imgs/state_dial.png>";

	echo($dialst."<font size=1>($END_STATUS,$CC_CAUSE,$END_PARTY)");
?>
</td>
<td><?=$TOTALSEC?></td>
<td><?=$pdds?></td>
<td><?=$pdd?></td>
<td><?=$BILLSEC?></td>
<? if ($BILLSEC<=0) { ?>
<td><font size=1>
<a href="/monitor/<?=$uid?>-pre-in.flac">&gt;&gt;</a><?=$txt_pre_in?><br>
<a href="/monitor/<?=$uid?>-pre-out.flac">&lt;&lt;</a><?=$txt_pre_out?><br>
</td>
<? } else { ?>
<td><font size=1>
<a href="/monitor/<?=$uid?>-ans-out.flac">&gt;&gt;</a><?=$txt_ans_out?><br>
<a href="/monitor/<?=$uid?>-ans-in.flac">&lt;&lt;</a><?=$txt_ans_in?><br>
</td>
<? } ?>
<td><font size=1><?=$uid?></td>
</tr>


<?
/*
		$uid=0;
		if (substr($line,0,1)=="U")
		{
		    $up=strpos($line,"|");
		    $uid=substr($line,1,$up-1);
		    $line=substr($line,$up+1);
		    echo(123);
		}
        	echo($line);
		if($uid>0)
		{
			$txt_pre_in=@file_get_contents("/var/svistok/sim/log/$uid-pre-in.rasp");
			$txt_pre_out=@file_get_contents("/var/svistok/sim/log/$uid-pre-out.rasp");
			$txt_ans_in=@file_get_contents("/var/svistok/sim/log/$uid-ans-in.rasp");
			$txt_ans_out=@file_get_contents("/var/svistok/sim/log/$uid-ans-out.rasp");
			
			echo("<a href='/monitor/$uid-pre-in.flac'>pre-in</a>=<font size=1>$txt_pre_in</font> ");
			echo("<a href='/monitor/$uid-pre-out.flac'>pre-out</a>=<font size=1>$txt_pre_out</font> ");
			echo("<a href='/monitor/$uid-ans-in.flac'>ans-in</a>=<font size=1>$txt_ans_in</font> ");
			echo("<a href='/monitor/$uid-ans-out.flac'>ans-out</a>=<font size=1>$txt_ans_out</font> ");
		}
*/
	}

    echo("</table>");
    }



    die();
}



$imsi=@$_GET['imsi'];
$dongle=@file_get_contents("/var/svistok/sim/state/".$imsi.'.dongle');


$name="Лог USSD и SMS запросов ".$dongle;
$ex=".smsussd";
$filename="/var/svistok/sim/log/".$imsi.$ex;




if(@$_GET['mode']=="laccell")
{
$dongle=$_GET['dongle'];
$name="Лог LAC/CELL ".$dongle;
$filename="/var/svistok/dongles/state/".$dongle.".laccell";
$logContent=file($filename);
$logContent = array_reverse($logContent);

?>
<b><?=$name?></b><br /><br />
<?
foreach($logContent as $line)
echo( $line."<br>;n");
}





echo("<b>Лог USSD и SMS запросов ".$dongle."</b><br /><br />");

if(!file_exists($filename)) die("Нет записей.");

?>

<table cellspacing=0 cellpadding=1>
<tr>
<td><font size=1>d</td>
<td><font size=1>io</td>
<td><font size=1>spec</td>
<td><font size=1>t</td>
<td><font size=1>number</td>
<td><font size=1>text</td>
</tr>
<?

	$logContent=file($filename);
	$logContent = array_reverse($logContent);
$cnt=0;
	foreach($logContent as $line)
	{
$cnt++;
if(($cnt>=15)&&(@$cut==1)) break;


		@list($t,$io,$spec,$d,$dongle,$dongleimsi,$number, $text64)=explode("|",$line);
?>

<tr>
<td>
<font size=1>
<?
//echo($d);
@list($dat,$tim)=explode(" ",$d);
echo($tim);
echo("<br><font color='#cccccc'>");
echo($dat);

?>
</td>
<td>
<?
                            if($io=="I")  echo("<img src=imgs/state_in.png>");
                            if($io=="O")  echo("<img src=imgs/state_out.png>");
?>
</td>
<td>
<?=html_spec("$spec")?>
</td>




}
?>
</table>
<?




?>
</div>
</font>