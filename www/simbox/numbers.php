
<?
$iccid_list=Array();
$iccid_list2=Array();

$cnt=0;
$data=file($path_svistok.'/lists/dongles.list');
//asort($data);
foreach($data as $i=>$v){
	$cnt++;
	$v=preg_replace('|[ ]{2,}|','~~~',trim($v));
	$v=explode('~~~',$v);
	$dongle=$v[0];


	$iccid="";
	$iccid_f=trim(@file_get_contents($path_svistok_dongles_state.$dongle.'.iccid'));
        if ((substr($iccid_f,0,1)=='"')&&(substr($iccid_f,21,1)=='"'))
	{
	    $iccid=$iccid_f[2].$iccid_f[1];
	    $iccid.=$iccid_f[4].$iccid_f[3];
	    $iccid.=$iccid_f[6].$iccid_f[5];
	    $iccid.=$iccid_f[8];

	    $iccid.=$iccid_f[7].$iccid_f[10];
	    $iccid.=$iccid_f[9];

	    $iccid.=$iccid_f[12].$iccid_f[11];
	    $iccid.=$iccid_f[14];

	    $iccid.=$iccid_f[13].$iccid_f[16];
	    $iccid.=$iccid_f[15].$iccid_f[18];

	    $iccid.=$iccid_f[17].$iccid_f[20].$iccid_f[19];

	    $imsi=trim(@file_get_contents($path_svistok_dongles_state.$dongle.'.imsi'));

	    $iccid_list[$iccid]=$imsi;
	    //$iccid_list2[$cnt]=$iccid;

	}
}

ksort($iccid_list);

?>


<?
if(isset($_POST['save']))
{
?>
<table>
<tr class="header">
<td>
Редактирование
</td></tr><tr><td>
<font face="courier" size="3" color="red">
Изменения сохранены<br><br>
</font>
<font face="courier" size="2">
<?
$numbers=$_POST['import_numbers'];
$numbers_a=explode("\n",$numbers);

    foreach($numbers_a as $v=>$pair)
    {
	@list($iccid,$number)=explode(";",$pair);
$iccid=trim($iccid);
$number=trim($number);
        if($iccid>0){
//	  echo("$iccid;$number,\n");

	    file_put_contents($path_simbox_sim_settings.$iccid.'.iccid_number',$number);
	    $imsi=$iccid_list[$iccid];
	    if($imsi<>"")
	    {
		file_put_contents($path_simbox_sim_settings.$imsi.'.number',$number);
		//echo("|$imsi|:|$number|,");
	    }

        }
    }

?>
</td></tr></table>
<?
}
?>




<h1>Редактирование номеров</h1>
<form method="post">
ICCID;номер<br>
каждая запись в отдельной строчке<br>
<font size=-1px>номер в международном формате, без +, без пробелов (например: 7926000000000)</font><br>
<br>
<textarea name="import_numbers" rows=15 cols=50>
<?
foreach($iccid_list as $iccid=>$imsi)
{
//	$imsi=$iccid_list[$iccid];
	$number="";

	if($imsi<>"")
	{
		$number=trim(@file_get_contents($path_simbox_sim_settings.$imsi.'.number'));
	}

	if($number=="")
	{
		$number=trim(@file_get_contents($path_simbox_sim_settings.$iccid.'.iccid_number'));
	}

    if($iccid<>"")
    {
		    echo($iccid.";".$number."\n");
    }


}
?>
</textarea>


<br><br>


<table>
<tr class="header">
	<td>
Действия
</td></tr>
<tr><td>
<input type="submit" name="refresh" value="Обновить"><br><br>
<input type="submit" name="save" value="Записать">

</td></tr>
</table>

</form>