<?
// Используем cURL для формирования HTTP POST-запроса к Google API
// Пакет php5-curl в Debian

//die();


$file=$argv[1];
$res=rasp($file,"pre-in");
$res=rasp($file,"pre-out");
$res=rasp($file,"ans-in");
$res=rasp($file,"ans-out");

die();



function rasp($uid,$t)
{
if(filesize("/var/spool/asterisk/monitor/$uid-$t.wav")<50) return "";
echo($uid." ".$t."\n");
//echo("sox /var/spool/asterisk/monitor/$uid-$t.wav -r 16000 /tmp/$uid.wav trim 0 0:30");
system("sox /var/spool/asterisk/monitor/$uid-$t.wav -r 16000 /tmp/$uid.wav trim 0 0:20");
system("flac -f -s /tmp/$uid.wav -o /tmp/$uid.flac");


$file_to_upload = array('myfile'=>"@/tmp/$uid.flac");
//$file_to_upload = array('myfile'=>'@/tmp/$uid.flac');
$ch = curl_init();
curl_setopt($ch, CURLOPT_URL,"https://www.google.com/speech-api/v1/recognize?xjerr=1&client=chromium&lang=ru-RU");
curl_setopt($ch, CURLOPT_POST,1);
curl_setopt($ch, CURLOPT_HTTPHEADER, array("Content-Type: audio/x-flac; rate=16000"));
curl_setopt($ch, CURLOPT_POSTFIELDS, $file_to_upload);
curl_setopt($ch,CURLOPT_RETURNTRANSFER,1);
$res=curl_exec ($ch);
curl_close ($ch);

$json_array = json_decode($res, true);
//print_r($json_array);
$result = $json_array["hypotheses"][0]["utterance"];


echo($result."\n");
file_put_contents("/var/svistok/sim/log/$uid.$t.rasp",$result);
$imsi=trim(file_get_contents("/var/svistok/sim/state/$uid.imsi"));
fa("/var/svistok/sim/log/$imsi.smsussd",$uid." ".$t." ".$result."\n");

////////!!!!!!!
unlink("/var/svistok/sim/state/$uid.imsi");

system("rm /var/spool/asterisk/monitor/$uid-$t.wav");
system("rm /tmp/$uid.wav");
system("rm /tmp/$uid.flac");


return($result);

}

function fa($f, $a)
{
echo($f.">".$a."\n");
$fh = fopen($f,'a') or die("can't open file");
fwrite($fh, $a);
fclose($fh);
}
/*
die();
// Описываем команды, которые мы будем выполнять
$cmd_matrix = array(
        array(array("включ", "свет"), "switch on"),
        array(array("выключ", "свет"), "switch off")
        );

// Google возвращает JSON, поэтому парсим стандартной функцией. Доступна в PHP 5.2
$json_array = json_decode($result, true);
$voice_cmd = $json_array["hypotheses"][0]["utterance"];

// Ищем в ответе Google наши команды.
// Если находим, выполняем заранее запрограммированное действие. В данном случае, вывод на экран
for ( $i = 0; $i < count($cmd_matrix); $i++ )
{
        $ok = 1;
        for ( $k = 0; $k < count($cmd_matrix[$i][0]); $k++ )
        {
                if ( !preg_match("/".$cmd_matrix[$i][0][$k]."/", $voice_cmd) )
                $ok = 0;
        }
        if ( $ok == 1 )
        echo $cmd_matrix[$i][1];
}
*/


?>