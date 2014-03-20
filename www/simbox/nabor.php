
<h1>Наборы комманд</h1>


<form action="<?=$_SERVER['REQUEST_URI'];?>" method="post">
<table>
<tr class="header">
<td>Поддерживаемые наборы команд</td>
</tr>

<?
$data=file($file_naborlist);
foreach($data as $i=>$v){
	$v=trim($v);
	$nabor=$v;
	?>
	<tr <?if($i%2==0)echo 'class="zebra"';?>>
		<input type="hidden" name="items[]" value="<?=$nabor;?>">
		<td><?=$nabor;?></td>
	</tr>
	<?
}
?>

</table>



</form>
