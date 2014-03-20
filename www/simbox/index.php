<?
include_once('head.php');
if(isset($_GET['p']))include_once($_GET['p'].'.php'); else include_once('sim.php');
include_once('foot.php');
?>
