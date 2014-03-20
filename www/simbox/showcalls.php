<?
header('Content-Type: text/html; charset=utf-8');

$imsi=$_GET['imsi'];

$log=file_get_contents("/var/svistok/sim/log/".$imsi.".calls");
$log=htmlspecialchars($log);
$log=str_replace("\n","<br>",$log);

echo($log);
?>

