<?

$filename = "test";

//exec('flac -f -s '.$filename.'.wav -o '.$filename.'.flac');

$file_to_upload = array('myfile'=>'@'.$filename.'.flac');
$ch = curl_init();
curl_setopt($ch, CURLOPT_URL,"https://www.google.com/speech-api/v1/recognize?xjerr=1&client=chromium&lang=ru-RU");
curl_setopt($ch, CURLOPT_POST,1);
curl_setopt($ch, CURLOPT_HTTPHEADER, array("Content-Type: audio/x-flac; rate=16000"));
curl_setopt($ch, CURLOPT_POSTFIELDS, $file_to_upload);
curl_setopt($ch,CURLOPT_RETURNTRANSFER,1);
$result=curl_exec ($ch);
echo(curl_error($ch));

curl_close ($ch);

echo($result);

$json_array = json_decode($result, true);
$voice_cmd = $json_array["hypotheses"][0]["utterance"];

//unlink($filename.'.flac');
//unlink($filename.'.wav');

//echo 'SET VARIABLE VOICE "'.$voice_cmd.'"'."\n";
//fgets(STDIN);
//echo 'VERBOSE ("'.$voice_cmd.'")'."\n";
//fgets(STDIN);
exit(0);

?>