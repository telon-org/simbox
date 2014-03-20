<?
$cut=1;

include "showlog.php";
die();


header('Content-Type: text/html; charset=utf-8');
?>

<div align="left">
<font size=2>

<?



if(@$_GET['calls']==1)
{
    $imsi=@$_GET['imsi'];
    $dongle=@file_get_contents("/var/svistok/sim/state/".$imsi.'.dongle');
    $filename="/var/svistok/sim/log/".$imsi.".calls";

    echo("<b>Лог звонков $dongle </b><br /><br />");
    if(!file_exists($filename)) {
        echo("Нет записей.");
    } else {

        $logContent=file($filename);
        $logContent = array_reverse($logContent);
	$cnt=0;
        foreach($logContent as $line)
        {
		$cnt++;
                $uid=0;
                if (substr($line,0,1)=="U")
                {
                    $up=strpos($line,"|");
                    $uid=substr($line,1,$up-1);
                    $line=substr($line,$up+1);
                    echo(123);
                }
                echo($line);
                if($uid>0)
                {
                        $txt_pre_in=@file_get_contents("/var/svistok/sim/log/$uid-pre-in.rasp");
                        $txt_pre_out=@file_get_contents("/var/svistok/sim/log/$uid-pre-out.rasp");
                        $txt_ans_in=@file_get_contents("/var/svistok/sim/log/$uid-ans-in.rasp");
                        $txt_ans_out=@file_get_contents("/var/svistok/sim/log/$uid-ans-out.rasp");

                        echo("<font size=1>$txt_pre_in</font> , ");
                        echo("<font size=1>$txt_pre_out</font> : ");
                        echo("<font size=1>$txt_ans_in</font> , ");
                        echo("<font size=1>$txt_ans_out</font> ");
                }
                echo("<br>");
		if($cnt>=20) die();
        }
    }



    die();
}



$imsi=@$_GET['imsi'];
$dongle=@file_get_contents("/var/svistok/sim/state/".$imsi.'.dongle');

$name="Лог USSD и SMS запросов ".$dongle;
$ex=".smsussd";
if(@$_GET['calls']==1)
{
$ex=".calls";
$name="Лог звонков ".$dongle;
}
$filename="/var/svistok/sim/log/".$imsi.$ex;


if(@$_GET['mode']=="laccell")
{
$dongle=$_GET['dongle'];
$name="Лог LAC/CELL ".$dongle;
$filename="/var/svistok/dongles/state/".$dongle.".laccell";
}




?>
<b><?=$name?></b><br /><br />
<?


if(!file_exists($filename)){
$logContent = "Нет записей.";
} else {
exec("/usr/bin/tail -n 15 ".$filename, $logContent, $error);
$logContent = array_reverse($logContent);
$logContent = implode($logContent, "<br />\n");

}
print $logContent;
?>
</div>
<br>
<div align="right"><a href="showlog.php?imsi=<?=$imsi?>" target="_blank">Даллее </a></div>
</font>