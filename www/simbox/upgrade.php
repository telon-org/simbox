<?

if(isset($_POST['upgrade_full']))
{
    $_POST['upgrade_svn']="yes";
    $_POST['upgrade_compile']="yes";
    $_POST['upgrade_restart']="yes";
}

if(isset($_POST['upgrade_svn']))
{
?>
<table>
<tr class="header">
<td>
Результат обновления кода
</td></tr><tr><td>
<?
    svn_auth_set_parameter(SVN_AUTH_PARAM_DEFAULT_USERNAME, 'simbox');
    svn_auth_set_parameter(SVN_AUTH_PARAM_DEFAULT_PASSWORD, 'simbox4385');
    $res=svn_update("/usr/simbox");
    if($res) echo ("OK"); else echo ("FAILED");
    //exec_br("sudo /usr/simbox/svn_update.php");
?>
</td></tr></table>
<br><br>
<?
}

if(isset($_POST['upgrade_compile']))
{
?>
<table>
<tr class="header">
<td>
Результат компиляции кода
</td></tr><tr><td>
<?
    exec_br("sudo /usr/simbox/svistok-aa/upgrade.sh");
?>
</td></tr></table>
<br><br>
<?
}



if(isset($_POST['upgrade_restart']))
{
?>
<table>
<tr class="header">
<td>
Результат перезапуска софта
</td></tr><tr><td>
<?
		exec_br('sudo /usr/sbin/asterisk -r -x "core restart now"');
		echo("<hr><br>");
		exec_br('sudo /usr/sbin/asterisk start');
		echo($cmd."<br>");
		$res=system("sudo ".$cmd);

		echo("<br><br>");
?>
</td></tr></table>
<br><br>
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

<br>

<table>
<tr class="header">
<td>
Версия
</td></tr><tr><td>
<?
    exec_br("sudo svn info /usr/simbox");
?>
</td></tr></table>

<br><br>


<table>
<tr class="header">
<td>
Локальные изменения
</td></tr><tr><td>
<?
    exec_br("sudo svn status /usr/simbox");
?>
</td></tr></table>

<br><br>

<form method="post">


<table>
<tr class="header">
<td>
Действия 
</td></tr><tr><td>
<input type="submit" name="upgrade_full" value="Обновить полностью"> <hr>
Или по частям:<br>
<input type="submit" name="upgrade_svn" value="Обновить код"> <br><br>
<input type="submit" name="upgrade_compile" value="Перекомпилировать код"> <br><br>
<input type="submit" name="upgrade_restart" value="Перезапуск софта"> <br><br>
<hr>
<input type="submit" name="restart_system" value="Перезапуск операционки"> <br><br>
<br><br>
Примечание: Если обновлять полностью, то по частям не требуется.<br>
Перезапуск операционки тоже не требуется.<br>
Но если что-то не так - то для верности можно перезагрузить.
</td></tr></table>

</form>

</body>
