#!/usr/bin/php
<?


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

//$cmd = exec('curl --silent -F "Content-Type=audio/x-pcm;bit=16;rate=16000" -F "audio=@'.$filename.'" asr.yandex.net/asr_xml\?key='.$key.'\&uuid='.$uuid .'\&topic='.$topic.'\&lang='.$lang, $xml);

//$res_xml = implode($xml)

//print_r($res_xml);
/*
$p = xml_parser_create();
xml_parse_into_struct($p, $res_xml, $vals, $index);
xml_parser_free($p);
//print_r($vals);
$r="";
foreach ($vals as $k=>$v)
{
    if($v['tag']=="VARIANT") $r=$r.$v['value']."/";
}
//echo($r);
$voice_text=$r;
*/

//echo($voice_text."\n");
//return($voice_text);



?>
