<?
header('Content-Type: text/html; charset=utf-8');
include("/usr/simbox/www/simbox/modules/html.php");
?>

<div align="left">
<font size=3>
<?



    $imsi=@$_GET['imsi'];
    $dongle=@file_get_contents("/var/svistok/sim/state/".$imsi.'.dongle');
    $filename="/var/svistok/sim/log/".$imsi.".calls2";

    $recog_f=@file("/var/svistok/sim/log/".$imsi.'.rasp_imsi');
//    print_r($recog_f);

    $recog=array();

    //print_r($recog_f);

    if ($recog_f)
    foreach($recog_f as $k=>$line)
    {
	list($uid,$status,$recog_type,$pdds,$pre_in,$pre_out,$ans_in,$ans_out)=explode(";",$line);
	$recog[$uid]=Array(
	    "status"		=> $status,
	    "recog_type"	=> $recog_type,
	    "pdds"		=> $pdds,
	    "pre_in"		=> $pre_in,
	    "pre_out"		=> $pre_out,
	    "ans_in"		=> $ans_in,
	    "ans_out"		=> $ans_out
	);
    }

    echo("<b>Лог звонков $dongle </b><br /><br />");
    if(!file_exists($filename)) {
        echo("Нет записей.");
    } else {

?>

<table cellspacing=0 cellpadding=1>
<tr>
<td><font size=1>d</td>
<td><font size=1>io</td>
<td><font size=1>pro</td>
<td><font size=1>vip</td>
<td><font size=1>cap</td>
<td><font size=1>im</td>
<td><font size=1>qos</td>
<td><font size=1>fas</td>
<td><font size=1>spec</td>
<td><font size=1>NUM</td>
<td><font size=1>n</td>
<td><font size=1>DIALSTATUS</td>
<td><font size=1>T=</td>
<td><font size=1>C</td>
<td><font size=1>+D</td>
<td><font size=1>!F</td>
<td><font size=1>+B</td>
<td><font size=1>rt</td>
<td width=250><font size=1>rec</td>
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


		@list($uid,$d,$vip,$spec,$qos,$naprstr,$im,$NUMBERA,$NUMBERB,$DIALSTATUS,$END_STATUS,$CC_CAUSE,$END_PARTY,$TOTALSEC,$pdds,$pdd,$BILLSEC,$pro,$cap,$fas,$epdd,$fpdd,$hem,$hoa,$tepoch,$FASSEC,$em_type)=explode("|",$line);
$cap=trim($cap);

//echo $line;
		//@list($io,$uid,$d,$vip,$spec,$qos,$naprstr,$im,$NUMBERA,$NUMBERB,$DIALSTATUS,$END_STATUS,$CC_CAUSE,$END_PARTY,$TOTALSEC,$pdds,$pdd,$BILLSEC)=explode("|",$line);

$txt_pre_in=@$recog[$uid]["pre_in"];
$txt_pre_out=@$recog[$uid]["pre_out"];
$txt_ans_in=@$recog[$uid]["ans_in"];
$txt_ans_out=@$recog[$uid]["ans_out"];

/*
			$txt_pre_in=@file_get_contents("/var/svistok/sim/log/$uid-pre-in.rasp");
			$txt_pre_out=@file_get_contents("/var/svistok/sim/log/$uid-pre-out.rasp");
			$txt_ans_in=@file_get_contents("/var/svistok/sim/log/$uid-ans-in.rasp");
			$txt_ans_out=@file_get_contents("/var/svistok/sim/log/$uid-ans-out.rasp");
*/

if(@$cut==1)
{

$txt_pre_in=mb_substr($txt_pre_in,0,120);
$txt_pre_out=mb_substr($txt_pre_out,0,120);
$txt_ans_in=mb_substr($txt_ans_in,0,120);
$txt_ans_out=mb_substr($txt_ans_out,0,120);

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
if($tepoch>0)
{
//echo($tepoch);
$tim=date("H:i:s",$tepoch);
$dat=date("d-m-Y",$tepoch);
}
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
<font size=1>
<?

 echo($pro);
?>
</font>
</td>

<td>
<?
                            if($vip=="VIP")  echo("<img src=imgs/ivip.png>");
?>
</td>



<td>

<?

if($cap=="OK")
    echo("<img src='imgs/qos/capok.png'>");

if($cap=="FAIL")
    echo("<img src='imgs/qos/capfail.png'>");

?>

</td>

<td>
<?=html_im($im)?>
</td>


<td>
<?=html_qos($qos,$io)?>
</td>


<td>
<?=html_fas($fas)?>
</td>
<td>
<?=html_spec($spec)?>
</td>


<td><font size=1><?=$NUMBERB?><br>
<font color="#cccccc"><?=$NUMBERA?>
<br>
</td>
<td>
<?
			$napr="<img src=imgs/napravleine/hz.ico>".$naprstr;
			$billing_direction=$naprstr;
/*
                            if($billing_direction=="bee_msk") $napr="<img src=imgs/napravleine/beeline_msk.ico>";
                            if($billing_direction=="bee_spb")  $napr="<img src=imgs/napravleine/beeline_spb.ico>";
                            if($billing_direction=="bee_ru")  $napr="<img src=imgs/napravleine/beeline_ru.ico>";

                            if($billing_direction=="meg_msk")  $napr="<img src=imgs/napravleine/megafon_msk.ico>";
                            if($billing_direction=="meg_spb")  $napr="<img src=imgs/napravleine/megafon_spb.ico>";
                            if($billing_direction=="meg_sz")  $napr="<img src=imgs/napravleine/megafon_sz.ico>";
                            if($billing_direction=="meg_chel")  $napr="<img src=imgs/napravleine/megafon_chel.ico>";
                            if($billing_direction=="meg_ural")  $napr="<img src=imgs/napravleine/megafon_ural.ico>";

                            if($billing_direction=="meg_ru")  $napr="<img src=imgs/napravleine/megafon_ru.ico>";

                            if($billing_direction=="mts_msk") $napr="<img src=imgs/napravleine/mts_msk.ico>";
                            if($billing_direction=="mts_spb") $napr="<img src=imgs/napravleine/mts_spb.ico>";
                            if($billing_direction=="mts_ru") $napr="<img src=imgs/napravleine/mts_ru.ico>";
                            if($billing_direction=="mts_u") $napr="<img src=imgs/napravleine/mts_u.ico>";
                            if($billing_direction=="mts_by") $napr="<img src=imgs/napravleine/mts_by.ico>";

                            if($billing_direction=="kievstar") $napr="<img src=imgs/napravleine/kievstar.ico>";

                            if($billing_direction=="velcom_rb") $napr="<img src=imgs/napravleine/velcom_by.ico>";

                            if($billing_direction=="life_rb") $napr="<img src=imgs/napravleine/life_by.ico>";

                            if($billing_direction=="tele2_spb") $napr="<img src=imgs/napravleine/tele2_spb.ico>";
                            if($billing_direction=="tele2_ru") $napr="<img src=imgs/napravleine/tele2_ru.ico>";

                            if($billing_direction=="proper_minsk") $napr="<img src=imgs/napravleine/proper_minsk.ico>";

                            if($billing_direction=="proper_msk") $napr="<img src=imgs/napravleine/proper_msk.ico>";
                            if($billing_direction=="proper_spb") $napr="<img src=imgs/napravleine/proper_spb.ico>";
*/
		    
				echo(html_napr($billing_direction));

?>
</td>

<td>
<?=html_endparty($END_PARTY)?>
<?=@$em_type?>
<?=html_dialstatus($DIALSTATUS)?>
<?
	echo("<font size=1>($END_STATUS,$CC_CAUSE,$END_PARTY)");
?>
</td>
<td><?=$TOTALSEC?></td>
<td><?=$pdds?></td>
<td><?=$pdd?></td>
<td><?=$FASSEC-$BILLSEC?></td>
<td><?=$BILLSEC?></td>
<td><?=html_recog_type(@$recog[$uid]["recog_type"])?></td>
<? if ($BILLSEC<=0) { ?>
<td><font size=1>
<a href="monitor/<?=$uid?>-pre-in.flac">&gt;&gt;</a><?=$txt_pre_in?><br>
<a href="monitor/<?=$uid?>-pre-out.flac">&lt;&lt;</a><?=$txt_pre_out?><br>
</td>
<? } else { ?>
<td><font size=1>
<a href="monitor/<?=$uid?>-pre-in.flac">&gt;&gt;</a> <a href="monitor/<?=$uid?>-ans-out.flac">&gt;</a><?=$txt_pre_in?><?=$txt_ans_out?><br>
<a href="monitor/<?=$uid?>-pre-out.flac">&lt;&lt;</a> <a href="monitor/<?=$uid?>-ans-in.flac">&lt;</a></a><?=$txt_pre_out?><?=$txt_ans_in?><br>
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



