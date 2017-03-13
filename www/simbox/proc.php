<?

if(isset($_POST['clearsms']))
{
?>
<table>
<tr class="header">
<td>
clear SMS 
</td></tr><tr><td>
<?

		$cmd='/usr/simbox/system/clearsms.sh >> /tmp/clearsms.log &';
		echo($cmd."<br>");
		$res=exec_delay("sudo ".$cmd);
		echo($res);
		echo("<br><br>");


?>
</td></tr></table>
<?
}




if(isset($_POST['smsmag']))
{
?>
<table>
<tr class="header">
<td>
SMS mag
</td></tr><tr><td>
<?
/*
		$cmd='/usr/bin/php /usr/simbox/ai/automag/automag.php >> /tmp/automag.log &';
		echo($cmd."<br>");
		$res=system("sudo ".$cmd);
		echo($res);
		echo("<br><br>");
*/

		$cmd='/usr/bin/php /usr/simbox/ai/sms/autosms.php >> /tmp/autosms.log &';
		echo($cmd."<br>");
		$res=system("sudo ".$cmd);
		echo($res);
		echo("<br><br>");


?>
</td></tr></table>
<?
}




if(isset($_POST['modeswitch']))
{
?>
<table>
<tr class="header">
<td>
Результат перевода модемов в правильный режим (modeswitch)
</td></tr><tr><td>
<?
		$cmd='/usr/simbox/programmator/modeswitch.sh';
		echo($cmd."<br>");
		$res=system("sudo ".$cmd);
		echo($res);
		echo("<br><br>");
?>
</td></tr></table>
<?
}

if(isset($_POST['u2diag']))
{
?>
<table>
<tr class="header">
<td>
Результат перевода модемов в правильный режим (u2diag)
</td></tr><tr><td>
<?
		$cmd='/usr/simbox/programmator/u2diag_all.sh';
		echo($cmd."<br>");
		$res=system("sudo ".$cmd);
		echo($res);
		echo("<br><br>");
?>
</td></tr></table>
<?
}

if(isset($_POST['clear_sms']))
{
?>
<table>
<tr class="header">
<td>
Результат чистки SMS
</td></tr><tr><td>
<?
		$cmd='/usr/simbox/system/clearsms.sh';
		echo($cmd."<br>");
		$res=system("sudo ".$cmd);
		echo($res);
		echo("<br><br>");
?>
</td></tr></table>
<?
}


if(isset($_POST['restart_svistok']))
{
?>
<table>
<tr class="header">
<td>
Результат перезапуска свистков
</td></tr><tr><td>
<?
		$cmd='/usr/sbin/asterisk -r -x "core restart now"';
		echo($cmd."<br>");
		$res=system("sudo ".$cmd);

		$cmd='/usr/sbin/asterisk start';
		echo($cmd."<br>");
		$res=system("sudo ".$cmd);

		echo("<br><br>");
?>
</td></tr></table>
<?
}


if(isset($_POST['restart_system']))
{
?>
<table>
<tr class="header">
<td>
Результат перезапуска системы
</td></tr><tr><td>
<?
		$cmd='/sbin/reboot';
		echo($cmd."<br>");
		$res=system("sudo ".$cmd);
		echo("<br><br>");
?>
</td></tr></table>
<?
}
?>

<br><br>
<form method="post">

<table>
<tr class="header">
<td>
Действия 
</td></tr><tr><td>


<input type="submit" name="clear_sms" value="Почистить смс"> <br><br>
<input type="submit" name="restart_svistok" value="Перезапуск софта"> <br><br>
<input type="submit" name="restart_system" value="Перезапуск операционки"> <br><br>
<hr>
<input type="submit" name="modeswitch" value="Поискать модемы (перевод в правильный режим - modeswitch)"> <br><br>
<input type="submit" name="u2diag" value="Поискать модемы (перевод в правильный режим - u2diag)"> <br><br>
<input type="submit" name="dongles_restart" value="Попробовать рестартовать модемы"> <br><br>
<input type="submit" name="hubs_restart" value="Попробовать рестартовать хабы"> <br><br>
<input type="submit" name="clearsms" value="clearsms"> <br><br>
<input type="submit" name="smsmag" value="smsmag"> <br><br>


<br><br>
Примечание: в случае если не приходят SMS или USSD рекомендуется почистить SMS и перезаргузить свистки
</td></tr></table>

</form>

</body>
