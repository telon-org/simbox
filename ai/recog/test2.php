#!/usr/bin/php

<?




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
yandexspeech("test3-pcm.wav");





?>