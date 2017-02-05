<?php

function execAsync($cmd) {
    if (substr(php_uname(), 0, 7) == "Windows"){
        pclose(popen("start /B ". $cmd, "r"));
    }
    else {
        exec($cmd . " > /dev/null &");
    }
}

function pr($var) {
  echo '<pre>'.var_export($var,true).'</pre>';
}

$json = @getallheaders()['User-Agent'] == 'Mastermind';
$json=TRUE; //Подредактировал, т.к. nanoact не шлет user-agent

define('DIR_SVI','/var/svistok/');
$path_svistok_sim_state='/var/svistok/sim/state/';
define('DIR_SIM','/var/simbox/sim/settings/');

$data = file(DIR_SVI.'/lists/imsi.list');
$imsilist=array();

foreach($data as $i=>$imsi) {
  $imsi = trim($imsi);

  $dongle = @file_get_contents($path_svistok_sim_state.$imsi.'.dongle');
  $number = @file_get_contents(DIR_SIM.$imsi.'.number');

  $iccid = @file_get_contents("/var/svistok/dongles/state/".$dongle.'.iccid');
  $operator = @file_get_contents("/var/svistok/dongles/state/".$dongle.'.operator');

  if (!$number) {
    //echo("!!!$dongle");
    $r=exec('sudo /usr/simbox/system/send.sh "ussd" "LOC" "'.$dongle.'" "*205#" ""');
    //echo("$r");
    // execAsync('sudo /usr/simbox/system/send.sh "ussd" "LOC" "'.$dongle.'" "*205#" ""');
    $number = null;
  }

  $imsi = number_format($imsi, 0, '', '');
  $number = $number ? number_format($number, 0, '', '') : null;

  //$imsilist[$imsi]=$dongle;

  $smsussd_j="[".@file_get_contents("/var/svistok/sim/log/".$imsi.".smsussd3")."{}]";
  $smsussd=json_decode($smsussd_j);

  array_push( $imsilist, array(
	'dongle'=>$dongle,
	'imsi'=>$imsi,
	'iccid'=>$iccid,
	'number'=>$number,
	'operator'=>$operator,
	'smsussd'=>$smsussd) );

}



$data=$imsilist;


// exec



// $path_svistok_dongles='/var/svistok/dongles/';
// $path_svistok_dongles_state='/var/svistok/dongles/state/';

/*
foreach($data as $i=>$imsi)  {
$imsi=trim($imsi);
$dongle=file_get_contents($path_svistok_sim_state.$imsi.'.dongle');
//$imsilist[$imsi]=$dongle;
$imsilist[$dongle]=$imsi;
}
ksort($imsilist);
*/






// If req from mastermind - plain text json
if ($json) {
  $out = json_encode($data);
  header('Content-Type: application/json');
  print $out;
} else {
  $out = json_encode($data, JSON_PRETTY_PRINT);
  print '<pre>'.$out.'</pre>';
}