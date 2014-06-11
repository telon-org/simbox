#!/usr/bin/php

<?
//die();
echo ("YASPEECH\n");



$uid=$argv[1];
$dialstatus=$argv[2];
$imsi=$argv[3];
$numberb=$argv[4];
$billsec=$argv[5];

//if (strlen($uid)<=0) die("No uid");

echo "uid=$uid imsi=$imsi\n";
dorecog2($uid,$dialstatus,$imsi,$numberb,$billsec);

die();

function dorecog2($uid,$dialstatus,$imsi,$numberb,$billsec)
{

    $pre_in="";
    $pre_out="";
    $ans_in="";
    $ans_out="";

    if($billsec<=0) $pre_in=rasp3($uid."-pre-in",$uid,1,$billsec);


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


function rasp2($filename, $uid,$pre, $billsec)
{
    $txt=raspwav2($filename,$pre);
    return $txt;
}


function raspwav2($filename,$pre)
{
if(filesize("/var/spool/asterisk/monitor/$filename.wav")<50)
{
    unlink("/var/spool/asterisk/monitor/$filename.wav");
    return "-";
}



$out = array();
$res=exec("sox -V3 /var/spool/asterisk/monitor/$filename.wav /tmp/$filename.%1n.wav trim 0 10 : newfile : trim 0 10  2>&1", $out);
print_r($out);

system("flac -f -s /tmp/$filename.1.wav -o /tmp/$filename.1.flac");
$result=googlespeech("/tmp/$filename.1.flac");
if($pre==1) if($result=="") {sleep(3); $result=googlespeech("/tmp/$filename.1.flac");}
if($pre==2) {
  system("flac -f -s /tmp/$filename.2.wav -o /tmp/$filename.2.flac");
  $result.="|".googlespeech("/tmp/$filename.2.flac");
}

	unlink("/tmp/$filename.1.wav");
	unlink("/tmp/$filename.2.wav");
	unlink("/tmp/$filename.1.flac");
	unlink("/tmp/$filename.2.flac");

//if($result=="") $result="[0]"
    return "[]".$result;
}



function rasp3($filename, $uid,$pre, $billsec)
{
if(filesize("/var/spool/asterisk/monitor/$filename.wav")<50)
{
    ///!!!unlink("/var/spool/asterisk/monitor/$filename.wav");
    return Array(-1,"-");
}


$out = array();
$res=exec('sox -V3 /var/spool/asterisk/monitor/'.$filename.'.wav -r 8000 -b 16 -c 1 /tmp/'.$filename.'-pcm.wav 2>&1', $out);
//$res=exec("sox -V3 /var/spool/asterisk/monitor/$filename.wav /tmp/$filename.vad.wav vad stat  2>&1", $out);
print_r($out);

$result=yandexspeech("/tmp/$filename-pcm.wav");

unlink("/tmp/$filename-pcm.wav");
return Array(0,"[y]".$result);
}


function history2($filename) 
{
    system("sox /var/spool/asterisk/monitor/$filename.wav /tmp/$filename.min.wav trim 0 0:59");
    system("flac -f -s /tmp/$filename.min.wav -o /var/spool/asterisk/monitor.flac/$filename.flac");
    unlink("/tmp/$filename.min.wav");
    unlink("/var/spool/asterisk/monitor/$filename.wav");
}




function dorecog($uid,$dialstatus,$imsi,$numberb,$billsec)
{
    @list($tmp,$pre_in)=rasp($uid."-pre-in",$uid,0,$billsec);
    @list($pdds,$pre_out)=rasp($uid."-pre-out",$uid,1,$billsec);
    @list($tmp,$ans_in)=rasp($uid."-ans-in",$uid,0,$billsec);
    @list($tmp,$ans_out)=rasp($uid."-ans-out",$uid,0,$billsec);


    $url='http://simserver:8122/recog/recog_save.php?uid='.$uid.'&pre_in='.urlencode($pre_in).'&pre_out='.urlencode($pre_out).'&ans_in='.urlencode($ans_in).'&ans_out='.urlencode($ans_out).'&pdds='.($pdds).'&billsec='.$billsec.'&numberb='.urlencode($numberb).'&dialstatus='.urlencode($dialstatus).'';
//    $url='"http://simserver:8122/recog/recog_save.php?uid='.$uid.'&pre_in='.urlencode($pre_in).'&pre_out='.urlencode($pre_out).'&ans_in='.urlencode($ans_in).'&ans_out='.urlencode($ans_out).'&pdds='.($pdds).'&billsec='.$billsec.'"';
    echo ($url."<<<\n\n");
    $tmp=file_get_contents($url);
 //$tmp=exec('curl -s '.$url);
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

    require("/usr/simbox/ai/recog/parse/all.php");
}




function rasp($filename, $uid, $ispdds,$billsec)
{
    @list($pdds,$txt)=raspwav($filename);
//    file_put_contents("/var/svistok/sim/log/$filename.rasp",$txt);
//  ^^^^^^^^^^
//    if($ispdds==1) file_put_contents("/var/svistok/sim/log/$uid.pdds",$pdds);
//  ^^^^^^^^^^
    return Array($pdds,$txt);


}


function raspwav($filename,$billsec)
{
}





function googlespeech($flac)
{
echo "recognize ".$flac."\n";
$file_to_upload = array('myfile'=>"@$flac");
$ch = curl_init();
curl_setopt($ch, CURLOPT_URL,"https://www.google.com/speech-api/v1/recognize?xjerr=1&client=chromium&lang=ru-RU");
curl_setopt($ch, CURLOPT_POST,1);
//curl_setopt($ch, CURLOPT_HTTPHEADER, array("Content-Type: audio/x-flac; rate=16000"));
curl_setopt($ch, CURLOPT_HTTPHEADER, array("Content-Type: audio/x-flac; rate=8000"));


curl_setopt($ch, CURLOPT_POSTFIELDS, $file_to_upload);
curl_setopt($ch,CURLOPT_RETURNTRANSFER,1);
$res=curl_exec ($ch);


$er=curl_error($ch);

	//$header_size = curl_getinfo($ch,CURLINFO_HEADER_SIZE);
        //$r['header'] = substr($response, 0, $header_size);
        //$r['body'] = substr( $response, $header_size );
        $r['http_code'] = curl_getinfo($ch,CURLINFO_HTTP_CODE);
        $r['last_url'] = curl_getinfo($ch,CURLINFO_EFFECTIVE_URL);
	print_r($r);


curl_close ($ch);

$json_array = json_decode($res, true);
$result = $json_array["hypotheses"][0]["utterance"];

print_r($json_array);
echo("\n".$result);
echo("\ner:".$er);
//if (strlen($result)<=0) print_r($json_array); else echo($result);
echo("\n");

return $result;
}




function fa($f, $a)
{
//echo($f.">".$a."\n");
$fh = fopen($f,'a') or die("can't open file");
fwrite($fh, $a);
fclose($fh);
}


function get_dur($a)
{
foreach($a as $l)
{
if(strstr($l,"Duration       :"))
{
@list($x,$y)=explode("=",$l);
@list($z,$zz)=explode(" ",$y);
echo(">$zz<\n");
return $zz/8000;
//echo("$z -- $zz\n");
}
}
return 0;
}

function get_vad($a)
{
foreach($a as $l)
{
if(strstr($l,"Length (seconds)"))
{
@list($x,$y)=explode(":",$l);
return trim($y);
//echo("$y -- $x\n");
}
}
return 0;
}







function yandexspeech($filename)
{


$key = '57eda14d-e0e2-4cdc-938c-b99844a07fd8';
$topic = "freeform";
$lang = "ru-RU";
$uuid = rand(1000,9999).rand(1000,9999).rand(1000,9999).rand(1000,9999).rand(1000,9999).rand(1000,9999).rand(1000,9999).rand(1000,9999);

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

$cmd = exec('curl --silent -F "Content-Type=audio/x-pcm;bit=16;rate=8000" -F "audio=@'.$filename.'" asr.yandex.net/asr_xml\?key='.$key.'\&uuid='.$uuid .'\&topic='.$topic.'\&lang='.$lang, $xml); 

$res_xml = implode($xml);


if (preg_match('!<variant .*?>(.*)</variant>!si', $res_xml, $arr)) $voice_text = $arr[1];
    else $voice_text='';
    

print_r($xml);
echo($voice_text);
return($voice_text);

/*echo 'SET VARIABLE TEXT "'.$voice_text.'"'."\n";
fgets(STDIN);
echo 'VERBOSE ("'.$voice_text.'")'."\n";
fgets(STDIN);
exit(0);*/


}

//system('sox '.$filename.'.wav -r 8000 -b 16 -c 1 '.$filename.'-pcm.wav');
//yandexspeech("test3-pcm.wav");





?>