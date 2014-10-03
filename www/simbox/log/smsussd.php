<?
header('Content-Type: text/html; charset=utf-8');
?>

<div align="left">
<font size=3>

<?




$imsi=@$_GET['imsi'];
$dongle=@file_get_contents("/var/svistok/sim/state/".$imsi.'.dongle');

$ex=".smsussd";

$filename="/var/svistok/sim/log/".$imsi.".smsussd2";
echo("<b>Лог USSD и SMS запросов ".$dongle."</b><br /><br />");

if(!file_exists($filename)) die("Нет записей.");

?>

<table cellspacing=0 cellpadding=1>
<tr>
<td><font size=1>d</td>
<td><font size=1>io</td>
<td><font size=1>spec</td>
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
if(($spec!="")&&($spec!="LOC")&&($spec!="LO2")&&($spec!="FOR"))
{
		@list($t,$io,$d,$dongle,$dongleimsi,$number, $text64)=explode("|",$line);
		$spec="NO";
}

//echo($line."<br>");
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

$text=base64_decode($text64);

?>
</td>
<td>
<?
if($t=="SMS")
{
                            if($io=="I")  echo("<img src=imgs/sms_in.png>");
                            if($io=="O")  echo("<img src=imgs/sms_out.png>");
} else if($t=="CDS")
{
//                            if($io=="I")  echo("<img src=imgs/sms_in.png>");
                            if($io=="I")  echo("<img src=imgs/state_in.png>");
			    $text="отчет";
} else {
                            if($io=="I")  echo("<img src=imgs/state_in.png>");
                            if($io=="O")  echo("<img src=imgs/state_out.png>");
}




?>
</td>
<td>
<?

			$ss=$spec;

                            if($spec=="NO")   $ss="";
                            if($spec=="SOU")   $ss="";
                            if($spec=="PRE")  $ss="<img src=imgs/pre.png>";
                            if($spec=="PRE")  $ss="<img src=imgs/pos.png>";
                            if($spec=="MAY")  $ss="<img src=imgs/may.png>";
                            if($spec=="LOC")  $ss="<img src=imgs/local.png>";
                            if($spec=="LO2")  $ss="<img src=imgs/local2.png>";
                            if($spec=="FOR")  $ss="<img src=imgs/forwarding.png>";

		echo($ss);
?>
</td>
<td>
<font size=1>
<?=$number?>
</td>
<td>
<font size=1>
<?=$text?>
</td>
</tr>
<?
}
?>
</table>
<?


if(@$cut==1) die();

?>
<br>
FullLog:
<?
$filename="/var/svistok/sim/log/".$imsi.".smsussd2";
if(!file_exists($filename)) die("Нет записей.");

	$logContent=file($filename);
	$logContent = array_reverse($logContent);
	foreach($logContent as $line)
	{ echo "$line<br>\n"; }
?>
<br><br>
OldLog:<br>
<?
$filename="/var/svistok/sim/log/".$imsi.".smsussd";
if(!file_exists($filename)) die("Нет записей.");

	$logContent=file($filename);
	$logContent = array_reverse($logContent);
	foreach($logContent as $line)
	{ echo "$line<br>\n"; }
?>

</div>
</font>