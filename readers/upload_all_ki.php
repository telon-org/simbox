#!/usr/bin/php
<?
$uploadall=0; //1



//$seller="3000";  // 2023
//$note="orenb_3000";


//$seller="2250";  // 2023
//$note="150ivan_2250_150_ivan_raznoe_2250";

$seller="2251";  // 2023
$note="2251_ivan_150_prosto";


$d="/var/svistok/readers/sim/";


//$seller="101";
//$note="yula test 150";
//$d="/var/svistok/readers/sim/150/";



$note=urlencode($note);



$dir=scandir($d);
foreach ($dir as $file)
{
    if(substr($file,-3)==".ki")
    {

	$iccid=substr($file,0,-3);
	$ki=file_get_contents($d.$iccid.".ki");
	$imsi=file_get_contents($d.$iccid.".imsi");
	$uploaded=@file_get_contents($d.$iccid.".uploaded");


	$ki_r=str_replace(" ","",$ki);
	$ki_r=trim($ki_r);
	$imsi_r=$imsi[1].$imsi[0].$imsi[3].$imsi[2].$imsi[5].$imsi[4].$imsi[7].$imsi[6].$imsi[9].$imsi[8].$imsi[11].$imsi[10].$imsi[13].$imsi[12].$imsi[15].$imsi[14].$imsi[17].$imsi[16];
	$iccid_r=$iccid[1].$iccid[0].$iccid[3].$iccid[2].$iccid[5].$iccid[4].$iccid[7].$iccid[6].$iccid[9].$iccid[8].$iccid[11].$iccid[10].$iccid[13].$iccid[12].$iccid[15].$iccid[14].$iccid[17].$iccid[16].$iccid[19];

	
	echo("$iccid_r\n$imsi_r\n$ki_r\n");
	if($ki_r=="00000000000000000000000000000000")
	{
		echo("NULL KI\n\n");
	} else {

	    if(($uploaded!=1)||($uploadall!=0))
	    {
		$result = file_get_contents("http://simserver:8122/reader/upload_new_ki.php?iccid=$iccid_r&imsi=$imsi_r&ki=$ki_r&seller=$seller&note=$note");
		file_put_contents($d.$iccid.".uploaded",1);
		echo("$result\n\n");
		//die();
	    }
	}



    }
}

//url="http://simserver:8122/readers/upload_new_ki.php?iccid=$iccid&imsi=$imsi&ki=$ki"
//echo $url

///usr/bin/curl "$URL"

?>