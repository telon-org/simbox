#!/usr/bin/php

<?
//die();




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
    $pre_in=rasp2($uid."-pre-in",$uid,1,$billsec);
    $pre_out=rasp2($uid."-pre-out",$uid,0,$billsec);
    $ans_in=rasp2($uid."-ans-in",$uid,2,$billsec);
    $ans_out=rasp2($uid."-ans-out",$uid,2,$billsec);


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
if(filesize("/var/spool/asterisk/monitor/$filename.wav")<50)
{
    ///!!!unlink("/var/spool/asterisk/monitor/$filename.wav");
    return Array(-1,"-");
}



$out = array();
$res=exec("sox -V3 /var/spool/asterisk/monitor/$filename.wav /tmp/$filename.vad.wav vad stat  2>&1", $out);
print_r($out);

$d=get_dur($out);
$v=get_vad($out);
$silence=round($d-$v,1);

$light=0;
$full_result="";
$cnt=0;

if ($res=="Probably text, not sound")
{
    //return Array($silence,"(".$silence.")");
    $light=1;
}
//echo("!!!   dur=$d vad=$v   !!!!\n\n\n");


if($light==0)
{
system("mkdir /tmp/$filename");
system("sox -V3 /tmp/$filename.vad.wav /tmp/$filename/part.wav silence 1 0.0 0.1% 1 1.0 0.1% pad 1.5 1.5 : newfile : restart");

$files=scandir("/tmp/$filename");

foreach ($files as $file)
    if(($file!=".")&&($file!=".."))
    {
	$cnt++;
	if((strlen($full_result)<=512)&&(($cnt<=4)&&($billsec>10)||($cnt<=2)))
	{
		system("flac -f -s /tmp/$filename/$file -o /tmp/$filename/$file.flac");
		$result=googlespeech("/tmp/$filename/$file.flac");
		if($result=="") {sleep(5); $result=googlespeech("/tmp/$filename/$file.flac");}
		$full_result=$full_result.$result."|";
	} else {
		$full_result=$full_result.">|";
	}
	unlink("/tmp/$filename/$file");
	unlink("/tmp/$filename/$file.flac");
    }
}


system("sox /tmp/$filename.vad.wav /tmp/$filename.min.wav trim 0 0:59");
system("flac -f -s /tmp/$filename.min.wav -o /var/spool/asterisk/monitor.flac/$filename.flac");

if(($cnt==0)||($light==1))
{
		$result=googlespeech("/var/spool/asterisk/monitor.flac/$filename.flac");
		if($result=="") {sleep(5); $result=googlespeech("/var/spool/asterisk/monitor.flac/$filename.flac");}
		$full_result=$full_result.$result."|";
}

unlink("/tmp/$filename");
unlink("/tmp/$filename.wav");
unlink("/tmp/$filename.vad.wav");
unlink("/tmp/$filename.min.wav");

//unlink("/var/spool/asterisk/monitor/$filename.wav");

return Array($silence,"[".$silence."]".$full_result);

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

?>
