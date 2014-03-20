<?
header('Content-Type: text/html; charset=utf-8');
?>

<?
$cut=@$cut;

if(@$_GET['calls']==1)
{
require("log/calls.php");
die();
}

if(@$_GET['mode']=="laccell")
{
require("log/laccell.php");
die();
}

require("log/smsussd.php");
?>