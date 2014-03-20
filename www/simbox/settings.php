<?
if(@isset($_POST['nosim2offline'])) $nosim2offline=$_POST['nosim2offline']; else $nosim2offline=0;
if(@isset($_POST['do_monitor_ans'])) $do_monitor_ans=$_POST['do_monitor_ans']; else $do_monitor_ans=0;
if(@isset($_POST['do_monitor_pre'])) $do_monitor_pre=$_POST['do_monitor_pre']; else $do_monitor_pre=0;
if(@isset($_POST['do_recog'])) $do_recog=$_POST['do_recog']; else $do_recog=0;

?>

<?
if(isset($_POST['save'])){
	
	$cmd='chmod -R 0777 /var/simbox/';
	$res=system("sudo ".$cmd);

	file_put_contents('/var/svistok/dongles/global.nosim2offline',$nosim2offline);
	file_put_contents('/var/simbox/do_monitor_ans',$do_monitor_ans);
	file_put_contents('/var/simbox/do_monitor_pre',$do_monitor_pre);
	file_put_contents('/var/simbox/do_recog',$do_recog);


}


$nosim2offline=file_get_contents_def2('/var/svistok/dongles/global.nosim2offline',"0");
$do_monitor_ans=file_get_contents_def2('/var/simbox/do_monitor_ans',"0");
$do_monitor_pre=file_get_contents_def2('/var/simbox/do_monitor_pre',"0");
$do_recog=file_get_contents_def2('/var/simbox/do_recog',"0");
?>


<h1>Настройки</h1>


<form method="post">
<input type="hidden" name="do_monitor" value=0>
<table>
<tr class="header" >
<td colspan=2>
Запись разговоров
</td></tr>


<tr><td><input type="checkbox" name="nosim2offline" value=1 <?if($nosim2offline==1) echo "checked";?>></td><td>Модемы без симок в Offline</td></tr>

<tr><td><input type="checkbox" name="do_monitor_pre" value=1 <?if($do_monitor_pre==1) echo "checked";?>></td><td>вести запись до поднятия трубки</td></tr>
<tr><td><input type="checkbox" name="do_monitor_ans" value=1 <?if($do_monitor_ans==1) echo "checked";?>></td><td>вести запись после поднятия трубки</td></tr>
<tr><td><input type="checkbox" name="do_recog" value=1 <?if($do_recog==1) echo "checked";?>></td><td>распознавать голос</td></tr>

<tr><td></td><td><a href="monitor/">записи</a></td></tr>
<tr><td></td><td><a href="clearmonitor.php">очистить</a></td></tr>


<tr><td colspan=2 align="center">
<input type="submit" name="save" value="Сохранить"> <br><br>
</td></tr></table>

<br><br>




<br><br>

