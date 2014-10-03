<?



//exec_fon('/usr/sbin/asterisk -r -x "dongle update"');

if(isset($_POST['findki']))
{
?>
<table>
<tr class="header">
<td>
Поиск KI
</td></tr><tr><td>
<font face="courier" size="3" color="red">
Внимание!!! Во время подбора KI карта недоступна для других операций.<br><br>
</font>
<font face="courier" size="2">
<?
    foreach($_POST['id'] as $v=>$device)
    {
	system("ulimit -n 300000");
	$dataport=file_get_contents_def2("/var/svistok/devices/$device.dataport","");
	$cmd=$dataport;
	//$dongle=file_get_contents($path_svistok_sim_state.$imsi.'.dongle');
	//$ussd=$_POST['ussdcommand'];
	$cmd='sudo nice -n 19 ionice -c3 /usr/simbox/wtss/wts --svistokmode=1 --device=reader  --speed=9600  --ignorects --port='.$dataport.' --dev='.$device.'> /tmp/reader_'.$device.'.log &';
	echo($cmd."<br>");
	$res=exec_delay($cmd);
	echo("<br><br>");
	sleep(1);
	//usleep(300000);
	flush();
    }
?>
</td></tr></table>
<?
}


/*

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



if(isset($_POST['changeimei'])){
foreach($_POST['id'] as $v=>$dongle)
{
//$dongle=file_get_contents_def2($path_svistok_sim_state.$imsi.'.dongle',"");
$imei=trim(file_get_contents($path_svistok_dongles.$dongle.'.imei'));
file_put_contents($path_svistok_dongles.'imei.black',$imei, FILE_APPEND | LOCK_EX);
}
}
*/


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

if(isset($_POST['enterpin']))
{
$_POST['atcommandexec']=1;
$_POST['atcommand']='AT+CPIN="'.$_POST['pin'].'"'.";".'+CLCK="SC",0,"'.$_POST['pin'].'";+CFUN=1,1';
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
	exec_s("/usr/sbin/asterisk -rx 'dongle cmd $dongle $atcommand'");
    }
?>
</td></tr></table>
<?
}
?>






<h1>Ридеры</h1>
<form method="post">
<table>
<tr class="header">

	<td><input type="checkbox" name="idall" value='all' onClick="SelAll(this)"></td>
	<td></td>
	<td>Ридер</td>
	<td><img src="imgs/lock.png"></td>
	<td>state</td>
	<td>SPN</td>
	<td>ICCID</td>
	<td>PIN</td>
	<td>IMSI</td>
	<td>KI</td>
	<td></td>
	<td>dataport</td>
</tr>

<?
$cnt=0;
$data=@file("/var/svistok/lists/readers.list");
asort($data);

if ($data)
foreach($data as $i=>$device){
        $cnt++;
	$device=trim($device);

?>
<tr <?if($cnt%2==0)echo 'class="zebra"';?>>
<td><input type="checkbox" name="id[]" class="id" value='<?=$device;?>' <? if(@in_array($device,$_POST['id'])) echo "checked"; ?>></td>
<td><?
$model=file_get_contents_def2("/var/svistok/devices/$device.model","");
$model_str=$model;

if($model=="1001") $model_str="<img src=imgs/pl2303.ico>";

echo($model_str);
$iccid=file_get_contents_def2("/var/svistok/readers/state/$device.iccid","");
$state=file_get_contents_def2("/var/svistok/readers/state/$device.status","Not connected");
$result=file_get_contents_def2("/var/svistok/readers/sim/$iccid.result","0");

$state_str=$state;
if(($result!=0)&&($result!=1000)) $state_str=$state_str."<font size=1>".$result."</font>";

$imsi=file_get_contents_def2("/var/svistok/readers/sim/$iccid.imsi","");
$ki=file_get_contents_def2("/var/svistok/readers/sim/$iccid.ki","");
$progress=floor(@filesize("/var/svistok/readers/sim/$iccid.gsm")/58);
$ki_str=$ki;
if ($ki=="00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00") $ki_str="00"; else

$progress_str="";
if ($progress>0) {$progress_str=" <font size=1>".$progress."/31044</font>";}
?></td>

<td><?=$device?></td>
<td><?=file_get_contents_def2("/var/svistok/readers/$device.lock","")?></td>
<td><?=$state_str?></td>
<td><?=file_get_contents_def2("/var/svistok/readers/$device.spn","")?></td>
<td><?=$iccid?></td>
<td><?=file_get_contents_def2("/var/svistok/readers/$device.pin","")?></td>
<td><?=$imsi?></td>
<td><font face="courier" size=2><?=$ki_str?></font></td>
<td><?=$progress_str?></td>
<td><?=file_get_contents_def2("/var/svistok/devices/$device.dataport","")?></td>

</tr>
<? } ?>

<tr class="header"><td colspan=10>Всего: <?=$cnt?></td></tr>
</table>

<br><br>

<table>
<tr class="header">
<td>
Действия
</td></tr>
<tr><td>
<input type="submit" name="refresh" value="Обновить"><br><br>
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
<input type="submit" name="removepin" value="Снять PIN">
<br>

<input type="text" name="setpinpin" value="<?=@$_POST["setpinpin"]?>">
<input type="submit" name="setpin" value="Установить PIN">
<br>

</td></tr>
</table>

<br><br>


<table>
<tr class="header">
	<td>
Поиск KI
</td></tr>
<tr><td>
<input type="submit" name="findki" value="Запустить поиск KI">
</td></tr>
</table>


<br><br>


<table>
<tr class="header">
	<td>
APDU-команда
</td></tr>
<tr><td>
<input type="text" name="apducommand"  value="<?=@$_POST["apducommand"]?>">
<input type="submit" name="apducommandexec" value="Выполнить APDU команду">
</td></tr>
</table>


</form>

