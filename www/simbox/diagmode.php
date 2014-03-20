<h1>Свистки (update mode)</h1>
<form method="post">
<table>
<tr class="header">

	<td></td>
	<td><font face=courier size=2>device</td>
	<td><font face=courier size=2></td>
	<td><font face=courier size=2>port</td>
	<td><font face=courier size=2></td>
	<td><font face=courier size=2></td>
</tr>

<?
$cnt=0;


$data=@file("/var/svistok/lists/devices_diag.list");
if ($data)
foreach($data as $i=>$device){
	$cnt++;
$device=trim($device);
?>
	<tr <?if($cnt%2==0)echo 'class="zebra"';?>>

		<td><a href="dmlog.php"><img src="imgs/diagmode/diagmode_log.png"></a></td>
		<td><font face=courier size=2><?=$device?></td>
		<td align="right"><font face=courier size=2><?=file_get_contents_def2("/var/svistok/devices/".$device.".model","")?></td>
		<td><font face=courier size=2><?=file_get_contents_def2("/var/svistok/devices/".$device.".dataport","")?></td>
		<td><font face=courier size=2>
<?
$state=file_get_contents_def2("/var/svistok/devices/".$device.".state","");
if ($state=="init") echo "<img src=imgs/diagmode/diagmode_init.png>";
elseif ($state=="diag") echo "<img src=imgs/diagmode/diagmode_start.png>";
elseif ($state=="wait") echo "<img src=imgs/diagmode/diagmode_wait.png>";
elseif ($state=="update") echo "<img src=imgs/diagmode/diagmode_update.png>";
elseif ($state=="done") echo "<img src=imgs/diagmode/diagmode_done.png>";
else echo($state);
?>
</td>
		<td align="right"><font face=courier size=2>
<?=file_get_contents_def2("/var/svistok/devices/".$device.".progress","0")?>%</td>


	</tr>
	<?
}

?>

<tr class="header"><td colspan=6>Всего: <?=$cnt?></td></tr>
</table>

<br><br>

<input type="submit" name="refresh" value="Обновить">
</form>