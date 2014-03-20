<?



//exec_fon('/usr/sbin/asterisk -r -x "dongle update"');

if((isset($_POST['poff']))||(isset($_POST['pon']))||(isset($_POST['prestart'])))
{
?>
<table>
<tr class="header">
<td>
Изменение питания
</td></tr><tr><td>
<font face="courier" size="2">
<?
    if(isset($_POST['poff'])) $onoff=0;
    if(isset($_POST['pon'])) $onoff=1;
    if(isset($_POST['prestart'])) $onoff=2;


    foreach($_POST['id'] as $v=>$adr)
    {
	@list($bus,$dev,$port)=explode(":",$adr);
	if (($dev>0)&&($port>0))
	{
	    //$cmd="/usr/simbox/bin/hub-ctrl -b $bus -d $dev -P $port -p 0";
	    if ($onoff==0) $cmd="/usr/simbox/bin/hub-ctrl -b $bus -d $dev -P $port -p 0";
	    if ($onoff==1) $cmd="/usr/simbox/bin/hub-ctrl -b $bus -d $dev -P $port -p 1";
	    if ($onoff==2) $cmd="/usr/simbox/bin/hub-ctrl -b $bus -d $dev -P $port -p 0 && /bin/sleep 2 && /usr/simbox/bin/hub-ctrl -b $bus -d $dev -P $port -p 1";

	    echo($cmd."<br>");
	    $res=exec_delay($cmd);
	    echo("<br><br>");
	}
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
	<td></td>
	<td></td>
	<td></td>
	<td></td>
	<td></td>
	<td></td>
	<td></td>

</tr>

<?
$cnt=0;

$command="lsusb -t";
exec($command, $data);
//print_r($data);


if ($data)
foreach($data as $i=>$device_f){

if (  (!(strstr($device_f,"If 1,"))) && (!(strstr($device_f,"If 2,"))) )
{

        $cnt++;
	$device=$device_f;


	if (substr($device_f,0,4)=="/:  ")
	{
	    $lvl=0;
	    $device=substr($device_f,4);
	}

	if (substr($device_f,0,8)=="    |__ ")
	{
	    $lvl=1;
	    $device=substr($device_f,8);
	}

	if (substr($device_f,0,12)=="        |__ ")
	{
	    $lvl=2;
	    $device=substr($device_f,12);
	}

	if (substr($device_f,0,16)=="            |__ ")
	{
	    $lvl=3;
	    $device=substr($device_f,16);
	}

	if (substr($device_f,0,20)=="                |__ ")
	{
	    $lvl=4;
	    $device=substr($device_f,20);
	}


	if (substr($device,0,4)=="Bus ")
	{
	    $bus=substr($device,4,2);
	}

	$dev_str=strstr($device,"Dev");
	if (substr($dev_str,0,4)=="Dev ")
	{
	    $dev_c=substr($dev_str,4,strpos($dev_str,",")-4);
	    $dev_l[$lvl]=$dev_c;
	}

	$isport=0;
	if (substr($device,0,5)=="Port ")
	{
	    $port=substr($device,5,1);
	    $isport=1;
	}


	//$device=trim($device);
	$device_img="<img src='imgs/usb/unknown.ico'>";

	if (strstr($device,"Class=vend.")) $device_img="<img src='imgs/usb/usb_port.ico'>";
	if (strstr($device,"Class=root_hub")) $device_img="<img src='imgs/usb/usb_pci.ico'>";
	if (strstr($device,"Class=hub")) $device_img="<img src='imgs/usb/hub_16.ico'>";

	$power_img="";
	if($isport==1)
	{
	    $power_img="<img src='imgs/p-on.png'>";
	}

	
	if($isport==1) 
	{
	    $dev=$dev_l[$lvl-1];
	    $adr="$bus:$dev:$port";
	} else $adr="$bus";

?>
<tr <?if($cnt%2==0)echo 'class="zebra"';?>>

<td><input type="checkbox" name="id[]" class="id" value='<?=$adr;?>' <? if(@in_array($adr,$_POST['id'])) echo "checked"; ?>></td>

<? if ($lvl==0) echo("<td>$device_img</td><td>$power_img</td><td></td><td></td><td></td><td></td>"); ?>
<? if ($lvl==1) echo("<td><img src='imgs/tree/sub.ico'></td><td>$device_img</td><td>$power_img</td><td></td><td></td><td></td>"); ?>
<? if ($lvl==2) echo("<td><img src='imgs/tree/down.ico'></td><td><img src='imgs/tree/sub.ico'></td><td>$device_img</td><td>$power_img</td><td></td><td></td>"); ?>
<? if ($lvl==3) echo("<td><img src='imgs/tree/down.ico'></td><td><img src='imgs/tree/down.ico'></td><td><img src='imgs/tree/sub.ico'></td><td>$device_img</td><td>$power_img</td><td></td>"); ?>
<? if ($lvl==4) echo("<td><img src='imgs/tree/down.ico'></td><td><img src='imgs/tree/down.ico'></td><td><img src='imgs/tree/down.ico'></td><td><img src='imgs/tree/sub.ico'></td><td>$device_img</td><td>$power_img</td>"); ?>


<td><? echo($device); ?></td>
<td><? echo($adr); ?></td>

</tr>
<? 
}
}

?>

<tr class="header"><td colspan=9>Всего: <?=$cnt?></td></tr>
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
Питание
</td></tr>
<tr><td>
<img src="imgs/p-on.png"><input type="submit" name="pon" value="ВКЛ">
<br>
<img src="imgs/p-off.png"><input type="submit" name="poff" value="ВЫКЛ">
<br>
<img src="imgs/p-off.png"><img src="imgs/p-on.png"><input type="submit" name="prestart" value="РЕСТАРТ">
<br>


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


<?

/*

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
*/
?>


</form>

