#!/usr/bin/php
<?
//die();
echo ("YASPEECH\n");



$uid=$argv[1];
$dialstatus=$argv[2];
$imsi=$argv[3];
$numberb=$argv[4];
$billsec=$argv[5];

if (strlen($uid)<=0) die("No uid");
echo "uid=$uid imsi=$imsi\n";

dorecog2($uid,$dialstatus,$imsi,$numberb,$billsec);

die();

function dorecog2($uid,$dialstatus,$imsi,$numberb,$billsec)
{

    $pre_in="";
    $pre_out="";
    $ans_in="";
    $ans_out="";

    $pre_in=rasp3($uid."-pre-in",$uid,1,$billsec);
    $pre_out=rasp3($uid."-pre-out",$uid,1,$billsec);

    if($billsec>0) $ans_in=rasp3($uid."-ans-in",$uid,1,$billsec);
    if($billsec>0) $ans_out=rasp3($uid."-ans-out",$uid,1,$billsec);


    $url='http://simserver:8122/recog/recog_save.php?uid='.$uid.'&pre_in='.urlencode($pre_in).'&pre_out='.urlencode($pre_out).'&ans_in='.urlencode($ans_in).'&ans_out='.urlencode($ans_out).'&pdds='.($pdds).'&billsec='.$billsec.'&numberb='.urlencode($numberb).'&dialstatus='.urlencode($dialstatus).'';
    echo ($url."<<<\n\n");
    $tmp=file_get_contents($url);
    $tmp=trim($tmp);
    echo(">>>".$tmp.">>>\n\n");


    // v odin file imsi;
    list($status,$recog_type)=explode(";",$tmp);
    if($status=="OK")
    {
	file_put_contents("/var/svistok/sim/log/$imsi.rasp_imsi","$uid;$status;$recog_type;$pdds;$pre_in;$pre_out;$ans_in;$ans_out\n", FILE_APPEND | LOCK_EX);
	file_put_contents("/tmp/rasp_imsi.full","$imsi;$uid;$billsec   $tmp    $status    $pdds;$pre_in;$pre_out;$ans_in;$ans_out\n", FILE_APPEND | LOCK_EX);
    } else {
	file_put_contents("/tmp/rasp_imsi.error","$imsi;$uid;$billsec   $tmp    $status    $pdds;$pre_in;$pre_out;$ans_in;$ans_out\n", FILE_APPEND | LOCK_EX);
    }

    history2($uid."-pre-in");
    history2($uid."-pre-out");
    history2($uid."-ans-in");
    history2($uid."-ans-out");

    require("/usr/simbox/ai/recog/parse/all.php");
}



function rasp3($filename, $uid,$pre, $billsec)
{
if(filesize("/var/spool/asterisk/monitor/$filename.wav")<50)
{
    ///!!!unlink("/var/spool/asterisk/monitor/$filename.wav");
    return "-";
}


$out = array();
$res=exec('sox -V3 /var/spool/asterisk/monitor/'.$filename.'.wav -r 16000 -b 16 -c 1 /tmp/'.$filename.'-pcm.wav  trim 0 0:07 2>&1', $out);
//$res=exec("sox -V3 /var/spool/asterisk/monitor/$filename.wav /tmp/$filename.vad.wav vad stat  2>&1", $out);
print_r($out);

$result=yandexspeech("/tmp/$filename-pcm.wav");

unlink("/tmp/$filename-pcm.wav");
return "[y]".$result;

}


function history2($filename) 
{
    system("sox /var/spool/asterisk/monitor/$filename.wav /tmp/$filename.min.wav trim 0 0:59");
    system("flac -f -s /tmp/$filename.min.wav -o /var/spool/asterisk/monitor.flac/$filename.flac");
    unlink("/tmp/$filename.min.wav");
    // !!! unlink("/var/spool/asterisk/monitor/$filename.wav");
}




function yandexspeech($filename)
{


$key = '57eda14d-e0e2-4cdc-938c-b99844a07fd8';
$topic = "freeform";
$lang = "ru-RU";
$uuid = rand(1000,9999).rand(1000,9999).rand(1000,9999).rand(1000,9999).rand(1000,9999).rand(1000,9999).rand(1000,9999).rand(1000,9999);
//echo("uuid=$uuid");
/*
// v2
$file_to_upload = array('audio'=>'@'.$filename.';'.'Content-type=audio/x-pcm;bit=16;rate=8000');
$ch = curl_init();
curl_setopt($ch, CURLOPT_URL,'asr.yandex.net/asr_xml?key='.$key.'&uuid='.$uuid .'&topic='.$topic.'&lang='.$lang);
curl_setopt($ch, CURLOPT_POST,1);
//curl_setopt($ch, CURLOPT_HTTPHEADER, array("Content-Type: audio/x-pcm; bit=16; rate=8000"));
//curl_setopt($ch, CURLOPT_HTTPHEADER, array("Content-type=multipart/form-data"));
curl_setopt($ch, CURLOPT_POSTFIELDS, $file_to_upload);
curl_setopt($ch, CURLOPT_RETURNTRANSFER,1);
$result=curl_exec ($ch);
echo(curl_error($ch));

curl_close ($ch);

echo($result);
*/

$cmd = exec('curl --silent -F "Content-Type=audio/x-pcm;bit=16;rate=16000" -F "audio=@'.$filename.'" asr.yandex.net/asr_xml\?key='.$key.'\&uuid='.$uuid .'\&topic='.$topic.'\&lang='.$lang, $xml);

$res_xml = implode($xml)

/*
if (preg_match('!<variant .*?>(.*)</variant>!si', $res_xml, $arr)) $voice_text = $arr[1];
    else $voice_text='';
*/

print_r($res_xml);

$p = xml_parser_create();
xml_parse_into_struct($p, $res_xml, $vals, $index);
xml_parser_free($p);

print_r($vals);
$r="";
foreach ($vals as $k=>$v)
{
    if($v['tag']=="VARIANT") $r=$r.$v['value']."/";
}
//echo($r);
$voice_text=$r;


echo($voice_text."\n");
return($voice_text);


}


?>
