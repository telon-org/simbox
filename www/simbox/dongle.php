<?
function calc($imei,$type)
{
if($type==1)
{
$const="97b7bc6be525ab44";
}
else
{
$const="5e8dd316726b0335";
}

//echo "CONST: ".$const."<br>";
$imei14=substr($imei,0,15);
//echo "IMEI14: ".$imei14."<br>";
$md5input=$imei14.$const;
//echo "IMEI14+CONST: ".$md5input."<br>";
$magic1=md5($md5input);
//echo "MD5(IMEI14+CONST): ".$magic1."<br>";
$magic2=pack("H*",$magic1);
$magic=str_split($magic2);
$hexcode[3]=array();
$hexcode[3]=ord((($magic[0]^$magic[4])^$magic[12])^$magic[8]);
$hexcode[2]=ord((($magic[1]^$magic[5])^$magic[13])^$magic[9]);
$hexcode[1]=ord((($magic[2]^$magic[6])^$magic[14])^$magic[10]);
$hexcode[0]=ord((($magic[3]^$magic[7])^$magic[15])^$magic[11]);
$hexcode[3]=(($hexcode[3]) & 0x01);
$hexcode[3]=(($hexcode[3]) | 0x02);
$hextemp=
str_pad(dechex($hexcode[3]),2,'0',0).
str_pad(dechex($hexcode[2]),2,'0',0).
str_pad(dechex($hexcode[1]),2,'0',0).
str_pad(dechex($hexcode[0]),2,'0',0);
$finalcode=hexdec($hextemp);
return $finalcode;
}


exec_fon('/usr/sbin/asterisk -r -x "dongle update"');


if(isset($_POST['diagmode']))
{
?>
<table>
<tr class="header">
<td>
Запуск перепрошивки
</td></tr><tr><td>
<font face="courier" size="3" color="red">
Внимание!!! Запуск перепрошивки начнется только после вынимания SIM Карты<br><br>
</font>
<font face="courier" size="2">
<?
    foreach($_POST['id'] as $v=>$dongle)
    {
	//$dongle=file_get_contents($path_svistok_sim_state.$imsi.'.dongle');
	//$ussd=$_POST['ussdcommand'];
	$cmd='/usr/simbox/actions/diagmode.sh '.$dongle.' noimsi';
	echo($cmd."<br>");
	$res=exec_delay($cmd);
	echo("<br><br>");
    }
?>
</td></tr></table>
<?
}

if(isset($_POST['changeimei']))
{
?>
<table>
<tr class="header">
<td>
Смена IMEI
</td></tr><tr><td>
<font face="courier" size="2">
<?
    foreach($_POST['id'] as $v=>$dongle)
    {
	//$dongle=file_get_contents($path_svistok_sim_state.$imsi.'.dongle');
	//$ussd=$_POST['ussdcommand'];
	$cmd='/usr/simbox/actions/changeimei.php '.$dongle.' noimsi';
	echo($cmd."<br>");
	$res=exec_delay($cmd);
	echo("<br><br>");
    }
?>
</td></tr></table>
<?
}


if(isset($_POST['donglerestart']))
{
?>
<table>
<tr class="header">
<td>
Перезапуск свистка
</td></tr><tr><td>
<font face="courier" size="2">
<?
    foreach($_POST['id'] as $v=>$dongle)
    {
	//$dongle=file_get_contents($path_svistok_sim_state.$imsi.'.dongle');
	//$ussd=$_POST['ussdcommand'];
	$cmd='/usr/simbox/actions/donglerestart.sh '.$dongle.' noimsi';
	echo($cmd."<br>");
	$res=exec_delay($cmd);
	echo("<br><br>");
    }
?>
</td></tr></table>
<?
}



if(isset($_POST['blackimei'])){
foreach($_POST['id'] as $v=>$dongle)
{
//$dongle=file_get_contents_def2($path_svistok_sim_state.$imsi.'.dongle',"");
//$imei=trim(file_get_contents($path_svistok_dongles.$dongle.'.imei'));
$imei=trim(file_get_contents($path_svistok_dongles_state.$dongle.'.imei'));
file_put_contents($path_svistok_dongles.'imei.black',$imei."\n", FILE_APPEND | LOCK_EX);
}
}

/*if(isset($_POST['changeimei'])){
if(isset($_POST['id'])){
	file_put_contents($path_svistok_dongles.'imei.black',implode("\n",$_POST['id'])."\n", FILE_APPEND | LOCK_EX);
}
}

if(isset($_POST['restart'])){
if(isset($_POST['id'])){
    echo "restart ".$_POST['id'];
}
}*/

?>

<?

/*
if(isset($_POST['nullpin']))
{
$_POST['atcommandexec']=1;
$_POST['atcommand']='AT+CLCK="SC",0,"'.$_POST['pin'].'"';
}
*/


if(isset($_POST['pon']))
{
$_POST['atcommandexec']=1;
$_POST['atcommand']='AT+CFUN=1;+CFUN=1,1;+CFUN?';
}

if(isset($_POST['poff']))
{
$_POST['atcommandexec']=1;
$_POST['atcommand']='AT+CFUN=5;+CFUN?';
}


if(isset($_POST['enterpin']))
{
$_POST['atcommandexec']=1;
$_POST['atcommand']='AT+CPIN="'.$_POST['pin'].'"'.";".'+CLCK="SC",0,"'.$_POST['pin'].'";+CPIN?';
}

if(isset($_POST['setpin']))
{
$_POST['atcommandexec']=1;
$_POST['atcommand']='AT+CLCK="SC",1,"'.$_POST['setpinpin'].'";+CFUN=1,1';
}




if(isset($_POST['atcommandexec']))
{
?>
<table>
<tr class="header">
<td>
Результат AT
</td></tr><tr><td>
<?
    foreach($_POST['id'] as $v=>$dongle)
    {
	$atcommand=$_POST['atcommand'];
	$atcommand=str_replace('"','\"',$atcommand);
#	exec_s('/usr/simbox/actions/atcommand.sh '.$dongle.' noimsi "'.$atcommand.'"');
#	exec_s("/usr/sbin/asterisk -rx 'dongle cmd $dongle $atcommand'");
        $res=exec_delay("/usr/sbin/asterisk -rx 'dongle cmd $dongle $atcommand'");
    }
?>
</td></tr></table>
<?
}
?>



<?
if(isset($_POST['unlock']))
{
?>
<table>
<tr class="header">
<td>
Результат разблокировки
</td></tr><tr><td>
<?
    foreach($_POST['id'] as $v=>$dongle)
    {
	$imei=trim(file_get_contents($path_svistok_dongles.$dongle.'.imei'));
	$unclockcode=calc($imei,0);
	$atcommand='AT^CARDLOCK="'.$unclockcode.'";+CFUN=1,1';

	$atcommand=str_replace('"','\"',$atcommand);
	exec_s("/usr/sbin/asterisk -rx 'dongle cmd $dongle $atcommand'");

    }
?>
</td></tr></table>
<?
}
?>


<?
if(isset($_POST['freqlock']))
{
?>
<table>
<tr class="header">
<td>
Результат установки привязки к каналу
</td></tr><tr><td>
<?
    foreach($_POST['id'] as $v=>$dongle)
    {
	$freq=$_POST['freq'];
	if($freq!="0") $freq="1,".$freq;

	$atcommand='AT^FREQLOCK=$freq;+CFUN=1,1';

	$atcommand=str_replace('"','\"',$atcommand);
	exec_s("/usr/sbin/asterisk -rx 'dongle cmd $dongle $atcommand'");
    }
?>
</td></tr></table>
<?
}
?>



<?
if(isset($_POST['setmode_gsm']))
{
?>
<table>
<tr class="header">
<td>
Результат установки режима GSM
</td></tr><tr><td>
<?
    foreach($_POST['id'] as $v=>$dongle)
    {
	$atcommand='AT^SYSCFG=13,1,3FFFFFFF,0,3;+CFUN=1,1';

	$atcommand=str_replace('"','\"',$atcommand);
	exec_s("/usr/sbin/asterisk -rx 'dongle cmd $dongle $atcommand'");
    }
?>
</td></tr></table>
<?
}
?>


<?
// ??? AT^HSPA=0 – режим WCDMA
if(isset($_POST['setmode_wcdma']))
{
?>
<table>
<tr class="header">
<td>
Результат установки режима WCDMA
</td></tr><tr><td>
<?
    foreach($_POST['id'] as $v=>$dongle)
    {
//	$atcommand='AT^SYSCFG=14,2,3FFFFFFF,0,1;^HSPA=0;+CFUN=1,1';
//	$atcommand='AT^SYSCFG=14,2,3FFFFFFF,1,2;+CFUN=1,1';
	$atcommand='AT^SYSCFG=14,2,3FFFFFFF,0,3;+CFUN=1,1';

	$atcommand=str_replace('"','\"',$atcommand);
	exec_s("/usr/sbin/asterisk -rx 'dongle cmd $dongle $atcommand'");
    }
?>
</td></tr></table>
<?
}
?>



<?
if(isset($_POST['u2diag']))
{
?>
<table>
<tr class="header">
<td>
Результат установки режима u2diag=0
</td></tr><tr><td>
<?
	exec_s("/usr/simbox/system/u2diag.sh");
?>
</td></tr></table>
<?
}
?>



<h1>Свистки (normal mode)</h1>
<form method="post">
<table>
<tr class="header">
	<td><input type="checkbox" name="idall" value='all' onClick="SelAll(this)"></td>
	<td></td>
	<td></td>
	<td></td>
	<td></td>
	<td>Свисток</td>
	<td><img src="imgs/lock.png"></td>
	<td>state</td>
	<td>ERR0</td>
	<td>ERR1</td>
	<td>ERR2</td>
	<td>M</td>
	<td><font size=1>Ch</td>
	<td>RSSI</td>
	<td>SNR</td>
	<td>Oper</td>
	<td><font size=1>CELL<br><font color="#cccccc">LAC</td>
	<td>ICCID</td>
	<td>Serial</td>
	<td>IMEI</td>
	<td>firmware</td>
	<td>model</td>
	<td>m</td>
	<td>audio</td>
	<td>data</td>
	<td>dev</td>
</tr>

<?
$cnt=0;
$data=file($path_svistok.'/lists/dongles.list');
asort($data);
foreach($data as $i=>$v){
	$cnt++;
	$v=preg_replace('|[ ]{2,}|','~~~',trim($v));
	$v=explode('~~~',$v);
//echo ($path_svistok_dongles_state.$dongle.'.imei');

	$dongle=$v[0];

	$imei=trim(file_get_contents($path_svistok_dongles_state.$dongle.'.imei'));

	$dongle_a="";

///	if (substr($dongle,0,7)=="dongle0") $dongle_a="<font size=1>???</font>";


              if (substr($dongle,0,7)=="dongle0")
              {
                  $dongle_a=file_get_contents_def2($path_svistok_dongles."statistics/".$imei.'.imei_name',"???");
                  $dongle_a="<font size=1>".$dongle_a."</font>";
              }

	
	$path=$path_svistok_dongles.$v[0];
	$err0=trim(@file_get_contents($path_svistok_dongles.'errors/'.$dongle.'.errors.0'));
	$err1=trim(@file_get_contents($path_svistok_dongles.'errors/'.$dongle.'.errors.1'));
	$err2=trim(@file_get_contents($path_svistok_dongles.'errors/'.$dongle.'.errors.2'));



	$operator=trim(@file_get_contents($path_svistok_dongles."/state/".$dongle.'.operator'));
	$operator2=trim(@file_get_contents($path_svistok_dongles."/state/".$dongle.'.operator2'));
	$lac=trim(@file_get_contents($path_svistok_dongles."/state/".$dongle.'.lac'));
	$cell=trim(@file_get_contents($path_svistok_dongles."/state/".$dongle.'.cell'));

	$model=@file_get_contents($path_svistok_dongles."/state/".$dongle.'.model');
	$manufacturer=@file_get_contents($path_svistok_dongles."/state/".$dongle.'.manufacturer');
	$cfun=@file_get_contents($path_svistok_dongles."/state/".$dongle.'.cfun');


	$lock_start=trim(@file_get_contents($path_svistok_dongles."/state/".$dongle.'.lock_start'));
	$lock_filename=trim(@file_get_contents($path_svistok_dongles."/state/".$dongle.'.lock_filename'));
	$lock_lineno=trim(@file_get_contents($path_svistok_dongles."/state/".$dongle.'.lock_lineno'));

	if($lock_start>0) $lock_where=$lock_filename.":".$lock_lineno;

	$simst=trim(@file_get_contents($path_svistok_dongles_state.$dongle.'.simst'));
	$srvst=trim(@file_get_contents($path_svistok_dongles_state.$dongle.'.srvst'));
	$pinrequired=trim(@file_get_contents($path_svistok_dongles_state.$dongle.'.pinrequired'));


	$mode=trim(@file_get_contents($path_svistok_dongles_state.$dongle.'.mode'));
	$submode=trim(@file_get_contents($path_svistok_dongles_state.$dongle.'.submode'));
	$ch=trim(@file_get_contents($path_svistok_dongles_state.$dongle.'.freqlock'));

	$snr=trim(@file_get_contents($path_svistok_dongles_state.$dongle.'.snr'));

	$rssi=trim(@file_get_contents($path_svistok_dongles_state.$dongle.'.rssi'));

	$rssidb=($rssi*2-113)."dBm";
	$rssil=-1;

	$m="<font size=1>?/".$mode."/".$submode;

	if($mode=="") $m="<font size=1>-";
	if($mode=="-1") $m="<font size=1>-";
	if($mode=="3") $m="<font size=1>GSM";
	if($mode=="5") $m="<font size=1>WCDMA";



	if($rssi=="-1") 
	{
	    $rssil="";
	    $rssidb="";
	} else
	if($rssi=="") 
	{
	    $rssil="";
	    $rssidb="";
	}
	 else
	if($rssi==0) $rssil='<img src="imgs/rssi/rssi-0.ico">'; else
	if($rssi==31) $rssil='<img src="imgs/rssi/rssi-4.ico">'; else 
	if(($rssi>0)&&($rssi<7)) $rssil='<img src="imgs/rssi/rssi-1.ico">'; else
	if(($rssi>=7)&&($rssi<15)) $rssil='<img src="imgs/rssi/rssi-2.ico">'; else
	if(($rssi>=15)&&($rssi<20)) $rssil='<img src="imgs/rssi/rssi-3.ico">'; else
	if(($rssi>=20)&&($rssi<31)) $rssil='<img src="imgs/rssi/rssi-4.ico">'; else
	{
	    $rssil="";
	    $rssidb="";
	}
	
/*

[-113 + Х * 2]

+CSQ: ,
where
– received signal strength indication
0 – (-113) dBm or less
1 – (-111) dBm
2..30 – (-109)dBm..(-53)dBm / 2 dBm per step
31 – (-51)dBm or greater    - BETTER
99 – not known or not detectable


*/
	$serial=trim(@file_get_contents($path_svistok_dongles_state.$dongle.'.serial'));
	$iccid="";
	$iccid_f=trim(@file_get_contents($path_svistok_dongles_state.$dongle.'.iccid'));
        if ((substr($iccid_f,0,1)=='"')&&(substr($iccid_f,21,1)=='"'))
	{
	    $iccid=$iccid_f[2].$iccid_f[1];
	    $iccid.=$iccid_f[4].$iccid_f[3];
	    $iccid.=$iccid_f[6].$iccid_f[5];
	    $iccid.=$iccid_f[8].$iccid_f[7];
	    $iccid.$iccid_f[10].$iccid_f[9];

	    $iccid.=$iccid_f[12].$iccid_f[11];
	    $iccid.=$iccid_f[14].$iccid_f[13];
	    
	    $iccid.=$iccid_f[16].$iccid_f[15];
	    $iccid.=$iccid_f[18].$iccid_f[17];
	    $iccid.=$iccid_f[20].$iccid_f[19];


//echo $iccid[0];
//	    $iccid_a=explode("",$iccid);
//	print_r($iccid_a);
	}

	$str_state=trim(@file_get_contents($path_svistok_dongles_state.$dongle.'.str_state'));
	$imei2=$imei;
	$firmware=trim(@file_get_contents($path_svistok_dongles_state.$dongle.'.firmware'));
	if(@substr_count(@file_get_contents($path_svistok_dongles.'imei.black'),$imei)) $imei='<b style="color:red;">'.$imei.'</b>';

	?>
	<tr <?if($cnt%2==0)echo 'class="zebra"';?>>
		<td><input type="checkbox" name="id[]" class="id" value='<?=$dongle;?>' <? if(@in_array($dongle,$_POST['id'])) echo "checked"; ?>></td>

<td>
<?
echo(html_dongle($model));
?>
</td>


<td>
<?
echo(html_cfun($cfun));
?>
</td>


<td>
<?
echo(html_simst($simst,$pinrequired));
?>
</td>
<td>
<?
echo(html_srvst($srvst,$simst));
?>
</td>
<td>
<font face="courier"><?=$dongle;?><?=$dongle_a;?></td>
		<td><font size=1><? if ($lock_start>0) 
{
	    echo("<font size=1>".(time()-$lock_start)." сек<br>".$lock_where); 

}
?></td>
		<td><?=$str_state;?></td>
		<td><?=$err0;?></td>
		<td><?=$err1;?></td>
		<td><?=$err2;?></td>
		<td><?=$m?></td>
		<td><font size=1><?=$ch;?></td>
		<td>
    <?=$rssil?>
<br><font size=1><?=$rssidb?>
</td>
		<td><font size=1><?=$snr?></td>
		<td><font size=1><?=$operator;?><br><font color="#cccccc"><?=$operator2;?></td>
		<td><font size=1>

<span class="tip" onmouseover="tooltip3(<?=$dongle?>);" onmouseout="bye();">
<a href="showlog.php?dongle=<?=$dongle?>&mode=laccell" target="_blank">
<?=$cell;?>
</span>
</a>

<br><font color="#cccccc"><?=$lac;?></td>
		<td><?=$iccid;?></td>
		<td><?=$serial;?></td>
		<td><?=$imei;?></td>
		<td><?=$firmware;?></td>
		<td><font face="courier"><?=$model?></td>
		<td><font face="courier"><?=$manufacturer?></td>
		<td><font face="courier"><?=@file_get_contents($path_svistok_dongles_state.$dongle.'.audio');?></td>
		<td><font face="courier"><?=@file_get_contents($path_svistok_dongles_state.$dongle.'.data');?></td>
		<td><font face="courier"><?=@file_get_contents($path_svistok_dongles_state.$dongle.'.dev');?></td>
	</tr>
	<?
}
?>

<tr class="header"><td colspan=23>Всего: <?=$cnt?></td></tr>
</table>

<br><br>

<table>
<tr class="header">
	<td>
Действия
</td></tr>
<tr><td>

<center>
<input type="submit" name="refresh" value="Обновить">
<br><br><hr>
<input type="submit" name="changeimei" value="сменить IMEI">
<input type="submit" name="blackimei" value="IMEI в черный список">
<hr>
<input type="submit" name="diagmode" value="В diagmode">
<hr>
<input type="submit" name="donglerestart" value="Перезапустить свисток">
</center>
</td></tr>
</table>

<br><br>


<table>
<tr class="header">
        <td>
<img src="imgs/state/state_dial.png"> Передатчик
</td></tr>
<tr><td>
<img src="imgs/p-on.png"><input type="submit" name="pon" value="ВКЛ">
<br>
<img src="imgs/p-off.png"><input type="submit" name="poff" value="ВЫКЛ">
</td></tr>
</table>


<br><br>

<table>
<tr class="header">
	<td>
PIN
</td></tr>
<tr><td>
<input type="text" name="pin" value="<?=@$_POST["pin"]?>">
<input type="submit" name="enterpin" value="Ввести и снять PIN">
<br>

<input type="text" name="setpinpin" value="<?=@$_POST["setpinpin"]?>">
<input type="submit" name="setpin" value="Установить новый PIN">
<br>

Примечание:<br><br>
<!--1. Прежде чем снимать пин-его нужно ввести<br>-->
При снятии саисток перезапускается- нужно просто подождать около минуты.<br>
До установки пина - он должен быть снят<br>
После установки пина симка не соединяется с БС. В теории IMEI тоже не предеается (точно не уверен).<br>
</td></tr>
</table>


<br><br>

<table>
<tr class="header">
	<td>
Unlock
</td></tr>
<tr><td>
<input type="submit" name="unlock" value="unlock CARDLOCK">
<input type="submit" name="u2diag" value="U2DIAG">

</td></tr>
</table>


<br><br>


<table>
<tr class="header">
<td>
Режимы GSM/WCDMA
</td></tr>
<tr><td>
<input type="submit" name="setmode_gsm" value="set GSM">
<input type="submit" name="setmode_wcdma" value="set WCDMA">

</td></tr>
</table>

<br><br>


<table>
<tr class="header">
<td>
Установить привязку к каналу (только WCDMA)
</td></tr>
<tr><td>
<input type="text" name="freq"  value="<?=@$_POST["freq"]?>">
<input type="submit" name="freqlock" value="Привязать к каналу">
</td></tr>
</table>



<br><br>


<table>
<tr class="header">
	<td>
AT-команда
</td></tr>
<tr><td>
<input type="text" name="atcommand"  value="<?=@$_POST["atcommand"]?>">
<input type="submit" name="atcommandexec" value="Выполнить AT команду">
</td></tr>
</table>

<br><br>
<table>
<tr class="header">
<td>
Опции
</td></tr><tr><td>
Запуск действий в фоновом режиме с задержкой <input type="text" name="delay_min" value="<?=@$_POST['delay_min']?>"> + случайной задержкой до <input type="text" name="delay_rnd" value="<?=@$_POST['delay_rnd']?>"> сек<br><br>
<input type="checkbox" name="delay_queue" value=1  <?if(@$_POST['delay_queue']==1)echo 'checked';?>> Вместо запуска поместить в очередь<br>
<!--
<font size=1>Важно! при использовании очереди и случайной задержки - случайное время идет по очереди, т.е. суммируется; без использования очереди все задания исполнятся в промежутке
-->
</td></tr></table>


</form>

