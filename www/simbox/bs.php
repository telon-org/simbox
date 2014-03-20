<?
if(isset($_POST['save'])){
	$data=array();
	foreach($_POST['online_max'] as $bs=>$i){
		$path=$path_svistok_bs_settings.$bs;

		echo($path.'.online_max'."---".$_POST['online_max'][$bs]."\n");
		file_put_contents($path.'.online_max',$_POST['online_max'][$bs]);
		file_put_contents($path.'.connected_max',$_POST['connected_max'][$bs]);
	}
}



?>




<h1>Базовые станции</h1>

<!--фильтр по операторам-->
<form action="<?=$_SERVER['REQUEST_URI'];?>" method="post">
<table>
<tr class="header">

<td>cellid</td>
<td>operator</td> 
<td>RSSI</td>
<td>ACDL / ACD</td>
<td>ASRL / ASR</td>
<td>online/max</td>
<td>connected/max</td>
</tr>


<?
$data=file($path_svistok.'/lists/bs.list');
foreach($data as $i=>$v){
	$v=trim($v);
	$path=$path_svistok_bs_state.$v;
	$path_settings=$path_svistok_bs_settings.$v;
	?>
	<tr <?if($i%2==0)echo 'class="zebra"';?>>
		<input type="hidden" name="id1[<?=$v?>" value="1">
		<td><?=$v?></td>
		<td><?=file_get_contents($path.'.provider_name');?></td>
		<td><?=file_get_contents($path.'.rssi');?></td>
		<td><?=minsec(file_get_contents_def2($path.'.acdl','0')/1000);?> / <?=minsec(file_get_contents_def2($path.'.acd','0'));?></td>
		<td><?=file_get_contents_def2($path.'.asrl','0')/1000;?> / <?=file_get_contents_def2($path.'.asr','0')/1000;?></td>
		<td><?=file_get_contents($path.'.online');?> / <input type="text" name="online_max[<?=$v?>]" value="<?=file_get_contents_def($path_settings.'.online_max',500);?>"></td>
		<td><?=file_get_contents($path.'.connected');?> / <input type="text" name="connected_max[<?=$v?>]" value="<?=file_get_contents_def($path_settings.'.connected_max',50);?>"></td>
	</tr>
	<?
}
?>

</table>

<input type="hidden" name="save" value="save">
<input type="submit"  value="Сохранить">
</form>
