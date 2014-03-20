<?
header('Content-Type: text/html; charset=utf-8');
?>

<div align="left">
<font size=3>

<?

$dongle=$_GET['dongle'];
$name="Лог LAC/CELL ".$dongle;
$filename="/var/svistok/dongles/state/".$dongle.".laccell";
if(!file_exists($filename)) 
{
    die("Нет записей.");
}

$logContent=file($filename);
$logContent = array_reverse($logContent);

?>
<b>
<?=$name?></b><br /><br />
<?
foreach($logContent as $line)
echo( $line."<br>;n");
?>
</div>
</font>