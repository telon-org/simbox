<table width="1000">
<tr class="header">
<td>
sysdevs
</td></tr><tr><td>
<font face="courier" size=2>
<?

$log=file_get_contents("/var/svistok/lists/sysdevs.list");
$log=htmlspecialchars($log);
$log=str_replace("\n","<br>",$log);

echo($log);

?>
</font>
</td></tr></table>

<br><br>

<table width="1000">
<tr class="header">
<td>
usbdevs
</td></tr><tr><td>
<font face="courier" size=2>
<?

$log=file_get_contents("/var/svistok/lists/usbdevs_all.list");
$log=htmlspecialchars($log);
$log=str_replace("\n","<br>",$log);

echo($log);

?>
</font>
</td></tr></table>
