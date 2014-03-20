
<h1>Звонки</h1>

<?
$r=system("sudo /usr/bin/tail -n 100 /var/svistok/sim/log/calls.full > /var/svistok/sim/log/100.calls.full");
echo($r);
$r=system("sudo /usr/bin/tail -n 500 /var/svistok/sim/log/calls[6~.full > /var/svistok/sim/log/300.calls.full");
echo($r);
$r=system("sudo /usr/bin/tail -n 100 /var/svistok/sim/log/req.full > /var/svistok/sim/log/100.req.full");
echo($r);
$r=system("sudo /usr/bin/tail -n 500 /var/svistok/sim/log/req.full > /var/svistok/sim/log/500.req.full");
echo($r);
$r=system("sudo /usr/bin/tail -n 100 /var/svistok/sim/log/not.full > /var/svistok/sim/log/100.not.full");
echo($r);
$r=system("sudo /usr/bin/tail -n 500 /var/svistok/sim/log/not.full > /var/svistok/sim/log/500.not.full");
echo($r);
?>



<?

function showlog1line($filename, $t)
{
system("sudo /usr/bin/tail -n 500 /var/svistok/sim/log/".$filename.".".$t." > /var/svistok/sim/log/500.".$filename.".".$t);
$handle = fopen("/var/svistok/sim/log/500.".$filename.".".$t, "r");
if(!$handle) return;
$cnt=0;

$vip=0;
$vi1=0;
$vi2=0;
$may=0;
$wstart=0;
$wend=0;

$inew=0;
$igoo=0;
$inor=0;
$ibad=0;
$iblo=0;
$irob=0;

$imn=0;
$imb=0;
$imc=0;
$imd=0;
$ime=0;

$cdd_total=0;
$pdd_total=0;
$pdda_total=0;
$pddn_total=0;
$acd_total=0;

$cnt_ans=0;
$cnt_noans=0;

$busy=0;

if($handle)
{
while (!feof($handle)) {

    $buffer = fgets($handle, 4096);
    if(strlen($buffer)>0)
{
    @list($when, $vip, $spec, $qos,$napr_str,$numbera,$numberb)=explode("|",$buffer);
    if($wstart==0) $wstart=$when;
    $wend=$when;
    if($qos=="NEW") $inew++;
    if($qos=="GOO") $igoo++;
    if($qos=="NOR") $inor++;
    if($qos=="BAD") $ibad++;
    if($qos=="BLO") $iblo++;
    if($qos=="ROB") $irob++;


    if($spec=="MAY")
    {
	$may++;
    }
    else
    {
	$cnt++;
    }
}
}
}
fclose($handle);


$inew=round($inew/$cnt*100);
$igoo=round($igoo/$cnt*100);
$inor=round($inor/$cnt*100);
$ibad=round($ibad/$cnt*100);
$iblo=round($iblo/$cnt*100);
$irob=round($irob/$cnt*100);

$ustart=strtotime($wstart);
$uend=strtotime($wend);

$cpm=round($cnt/($uend-$ustart)*60);
?>

<tr>

<td><?=$t?></td>
<td><?=$cpm?></td>
<td><font size=1><?=$wstart?><br><?=$wend?><br></td>

<td><?=$may?></td>

<td><?=$cnt?></td>

<td><?=$inew?>%</td>
<td><?=$igoo?>%</td>
<td><?=$inor?>%</td>
<td><?=$ibad?>%</td>
<td><?=$iblo?>%</td>
<td><?=$irob?>%</td>
</tr>

<?

}


function showlog1full($filename, $name)
{

/*
$dir = "/var/simbox/sim/statistics/";
$files = scandir($dir);
array_shift($files);
array_shift($files);
for($i=0; $i<sizeof($files); $i++)
{
if (strstr($files[$i],".balance")!=FALSE)
{
$imsi=str_replace(".balance","",$files[$i]);
echo($imsi."\n");
$bal[$]
}
}
*/

?>

<table>
<tr class="header" >
<td colspan=10>
Качество последних <b><?=$name?></b> 
</td></tr>
<tr>
<td></td>
<td>CPM</td>
<td><font size=1>start<br>end</td>

<td><img src="imgs/may.png"></td>
<td><img src="imgs/state_dial.png"></td>

<td><img src="imgs/inew.png"></td>
<td><img src="imgs/igoo.png"></td>
<td><img src="imgs/inor.png"></td>
<td><img src="imgs/ibad.png"></td>
<td><img src="imgs/iblo.png"></td>
<td><img src="imgs/irob.png"></td>
</tr>

<?

showlog1line($filename,"full");
showlog1line($filename,"mts_spb");
showlog1line($filename,"tele2_spb");
showlog1line($filename,"bee_msk");
showlog1line($filename,"bee_spb");
showlog1line($filename,"bee_ru");
showlog1line($filename,"meg_msk");
showlog1line($filename,"meg_spb");
showlog1line($filename,"meg_sz");
showlog1line($filename,"meg_ru");
showlog1line($filename,"meg_chel");
showlog1line($filename,"meg_ural");

?>

</table>

<br><br>

<?
}

function showlog2line($filename, $t)
{
system("sudo /usr/bin/tail -n 500 /var/svistok/sim/log/".$filename.".".$t." > /var/svistok/sim/log/500.".$filename.".".$t);
$handle = fopen("/var/svistok/sim/log/500.".$filename.".".$t, "r");
if(!$handle) return;
$cnt=0;

$vip=0;
$vi1=0;
$vi2=0;
$may=0;
$wstart=0;
$wend=0;

$inew=0;
$igoo=0;
$inor=0;
$ibad=0;
$iblo=0;
$irob=0;

$imn=0;
$imb=0;
$imc=0;
$imd=0;
$ime=0;

$cdd_total=0;
$pdd_total=0;
$pdda_total=0;
$pddn_total=0;
$acd_total=0;

$cnt_ans=0;
$cnt_noans=0;

$busy=0;

if($handle)
{
while (!feof($handle)) {

    $buffer = fgets($handle, 4096);
    if(strlen($buffer)>0)
{
    @list($io,$uid,$when, $vip, $spec, $qos,$naprstr,$im,$numbera,$numberb,$dialstatus, $dc1, $dc2, $dc3, $durationsec, $pddc,$pdd,$billsec)=explode("|",$buffer);
    if($wstart==0) $wstart=$when;
if($io=="O")
{
    $wend=$when;

    if($qos=="NEW") $inew++;
    if($qos=="GOO") $igoo++;
    if($qos=="NOR") $inor++;
    if($qos=="BAD") $ibad++;
    if($qos=="BLO") $iblo++;
    if($qos=="ROB") $irob++;

    if($im=="-") $imn++;
    if($im=="B") $imb++;
    if($im=="C") $imc++;
    if($im=="D") $imd++;
    if($im=="E") $ime++;
    if($im=="N") $imn++;

    if($dialstatus=="BUSY") $busy++;

    if($spec=="MAY")
    {
	$may++;
    }
    else
    {
	$cnt++;
        $cdd_total+=$pddc;
        $pdd_total+=$pdd;

        if($billsec>0)
        {
	    $cnt_ans++;
    	    $acd_total+=$billsec;
            $pdda_total+=$pdd;
        } else {
    	    $cnt_noans++;
	    $pddn_total+=$pdd;
        }
    }
}
}
}
fclose($handle);
}

if($cnt<=0) return;

$inew=round($inew/$cnt*100);
$igoo=round($igoo/$cnt*100);
$inor=round($inor/$cnt*100);
$ibad=round($ibad/$cnt*100);
$iblo=round($iblo/$cnt*100);
$irob=round($irob/$cnt*100);

$imb=round($imb/$cnt*100);
$imc=round($imc/$cnt*100);
$imd=round($imd/$cnt*100);
$ime=round($ime/$cnt*100);
$imn=round($imn/$cnt*100);


$acd_total=round($acd_total/$cnt_ans);
$cdd_total=round($cdd_total/$cnt);
$pdd_total=round($pdd_total/$cnt);
$pddn_total=round($pddn_total/$cnt_noans);
$pdda_total=round($pdda_total/$cnt_ans);
$asr_total=round($cnt_ans/$cnt*100);

$busy=round($busy*100/$cnt_noans);

$ustart=strtotime($wstart);
$uend=strtotime($wend);

$cpm=round($cnt/($uend-$ustart)*60);
?>

<tr>
<td><?=$t?></td>
<td><?=$cpm?></td>
<td><font size=1><?=$wstart?><br><?=$wend?><br></td>

<td><?=$may?></td>
<td><?=$cnt?></td>
<td><?=$cnt_ans?></td>

<td><?=$inew?>%</td>
<td><?=$igoo?>%</td>
<td><?=$inor?>%</td>
<td><?=$ibad?>%</td>
<td><?=$iblo?>%</td>
<td><?=$irob?>%</td>
<td><?=$imn?>%</td>
<td><?=$imb?>%</td>
<td><?=$imc?>%</td>
<td><?=$imd?>%</td>
<td><?=$ime?>%</td>
<td><?=$cdd_total?></td>
<td><?=$pddn_total?></td>
<td><?=$pdda_total?></td>
<td><?=$acd_total?></td>
<td><?=$asr_total?>%</td>
<td><?=$busy?>%</td>

</tr>

<?
}

function showlog2full($filename, $name)
{
?>

<table>
<tr class="header" >
<td colspan=19>
Качество  последних <b><?=$name?></b> 
</td></tr>

<tr>
<td></td>
<td>CPM</td>
<td><font size=1>start<br>end</td>

<td><img src="imgs/may.png"></td>
<td><img src="imgs/state_dial.png"></td>
<td><img src="imgs/state_active.png"></td>

<td><img src="imgs/inew.png"></td>
<td><img src="imgs/igoo.png"></td>
<td><img src="imgs/inor.png"></td>
<td><img src="imgs/ibad.png"></td>
<td><img src="imgs/iblo.png"></td>
<td><img src="imgs/irob.png"></td>

<td><img src="imgs/imn.ico"></td>
<td><img src="imgs/imb.png"></td>
<td><img src="imgs/imc.ico"></td>
<td><img src="imgs/imd.ico"></td>
<td><img src="imgs/ime.ico"></td>
<td>CDD</td>
<td>PDDn</td>
<td>PDDa</td>
<td>ACD</td>
<td>ASR</td>
<td>BUSY</td>

</tr>

<?
showlog2line($filename,"full");
showlog2line($filename,"mts_spb");
showlog2line($filename,"tele2_spb");
showlog2line($filename,"bee_msk");
showlog2line($filename,"bee_spb");
showlog2line($filename,"bee_ru");
showlog2line($filename,"meg_msk");
showlog2line($filename,"meg_spb");
showlog2line($filename,"meg_sz");
showlog2line($filename,"meg_ru");
showlog2line($filename,"meg_chel");
showlog2line($filename,"meg_ural");
?>

</table>

<br><br>

<?

}

?>








<form method="post">

<input type="hidden" name="do_monitor" value=0>


<?

showlog1full("req","запросов");

showlog1full("not","circuit busy");

showlog2full("calls","соединений");



if(@$_GET['full']!="yes") echo ('<a href="?p=calls&full=yes">Показать список</a><br><br>');
else  {
?>

<a href="?p=calls">Скрыть список</a>
<br><br>



<table>
<tr class="header" >
<td colspan=17>
Последние </b>соединения</b>
</td></tr>

<?

$filename="/var/svistok/sim/log/100.calls.full";

$log=file($filename);
$log=array_reverse($log);
        foreach($log as $buffer)
        {

//echo($log);
//		        @list($uid,$when, $vip, $spec, $qos,$numbera,$numberb,$dialstatus, $dc1, $dc2, $dc3, $durationsec, $pddc,$pdd,$billsec)=explode("|",$buffer);

			@list($io,$uid,$d,$vip,$spec,$qos,$naprstr,$im,$NUMBERA,$NUMBERB,$DIALSTATUS,$END_STATUS,$CC_CAUSE,$END_PARTY,$TOTALSEC,$pdds,$pdd,$BILLSEC)=explode("|",$buffer);
$when=$d;
$numbera=$NUMBERA;
$numberb=$NUMBERB;

                        $txt_pre_in=@file_get_contents("/var/svistok/sim/log/$uid-pre-in.rasp");
                        $txt_pre_out=@file_get_contents("/var/svistok/sim/log/$uid-pre-out.rasp");
                        $txt_ans_in=@file_get_contents("/var/svistok/sim/log/$uid-ans-in.rasp");
                        $txt_ans_out=@file_get_contents("/var/svistok/sim/log/$uid-ans-out.rasp");

?>

<tr>
<td><?=$uid?></td>
<td><?=$when?></td>
<td><?=$vip?></td>
<td><?=$spec?></td>
<td><?=$qos?></td>
<td><?=$numbera?></td>
<td><?=$numberb?></td>
<td><?=$dialstatus?></td>
<td><?=$billsec?></td>
<td><font size=1>
<a href="/monitor/<?=$uid?>-pre-in.flac">&gt;&gt;<?=$txt_pre_in?></a><br>
<a href="/monitor/<?=$uid?>-pre-out.flac">&lt;&lt;<?=$txt_pre_out?></a><br>
</td>
<td><font size=1>
<a href="/monitor/<?=$uid?>-ans-in.flac">&gt;&gt;<?=$txt_ans_in?></a><br>
<a href="/monitor/<?=$uid?>-ans-out.flac">&lt;&lt;<?=$txt_ans_out?></a><br>
</td>
<td><?=$uid?></td>

</tr>
<?



}
?>

</table>

<br><br>

<table>
<tr class="header" >
<td colspan=6>
Последние <b>запросы</b>
</td></tr>

<?

$handle = fopen("/var/svistok/sim/log/100.req.full", "r");
if($handle)
{
while (!feof($handle)) {
    $buffer = fgets($handle, 4096);
    @list($when, $vip, $spec, $qos,$naprstr,$numbera,$numberb)=explode("|",$buffer);
?>

<tr>
<td><?=$when?></td>
<td><?=$vip?></td>
<td><?=$spec?></td>
<td><?=$qos?></td>
<td><?=$naprstr?></td>
<td><?=$numbera?></td>
<td><?=$numberb?></td>
</tr>
<?

}
fclose($handle);
}
?>


</table>

<br><br>

<table>
<tr class="header" >
<td colspan=6>
Последние <b>circuit busy</b>
</td></tr>

<?

$handle = fopen("/var/svistok/sim/log/100.not.full", "r");
if($handle)
{
while (!feof($handle)) {
    $buffer = fgets($handle, 4096);
    @list($when, $vip, $spec, $qos,$naprstr,$numbera,$numberb)=explode("|",$buffer);
?>

<tr>
<td><?=$when?></td>
<td><?=$vip?></td>
<td><?=$spec?></td>
<td><?=$qos?></td>
<td><?=$naprstr?></td>
<td><?=$numbera?></td>
<td><?=$numberb?></td>
</tr>
<?

}
fclose($handle);
}
?>


</table>

<br><br>




<? } ?>

<input type="submit" name="refresh" value="Обновить"> <br><br>



<br><br>
<!--
<tr><td><input type="checkbox" name="do_monitor" value=1 <?if($do_monitor==1) echo "checked";?>></td><td>вести запись</td></tr>
<tr><td></td><td><a href="monitor/">записи</a></td></tr>
<tr><td></td><td><a href="clearmonitor.php">очистить</a></td></tr>
-->

<tr><td colspan=2 align="center">
