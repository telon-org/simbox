#!/usr/bin/php

<?
function save_balance($imsi, $balance)
{
    $bal_last=@file_get_contents("/var/simbox/sim/statistics/$imsi.balance");

    if($bal_last=="")
    {
        file_put_contents("/var/simbox/sim/statistics/$imsi.bal_yest",$balance);
        $last_balance=$balance;

        $bal_minus=0;
        $bal_plus=0;
    } else {
        $bal_minus=@file_get_contents("/var/simbox/sim/statistics/$imsi.bal_minus");
        $bal_plus=@file_get_contents("/var/simbox/sim/statistics/$imsi.bal_plus");
    }

    if($balance>$bal_last) $bal_plus+=$balance-$bal_last;
    if($balance<$bal_last) $bal_minus+=$bal_last-$balance;

    file_put_contents("/var/simbox/sim/statistics/$imsi.balance",$balance);
    file_put_contents("/var/simbox/sim/statistics/$imsi.bal_last",$bal_last);
    file_put_contents("/var/simbox/sim/statistics/$imsi.bal_minus",$bal_minus);
    file_put_contents("/var/simbox/sim/statistics/$imsi.bal_plus",$bal_plus);

    file_put_contents("/var/simbox/sim/statistics/$imsi.get_balance_response",time());
}

function save_op($imsi, $t, $d)
{
    file_put_contents("/var/simbox/sim/statistics/$imsi.op_t",$t);
    file_put_contents("/var/simbox/sim/statistics/$imsi.op_d",$d);
}



function upload_balance ($imsi, $balance)
{
    $balance1=(int)$balance;

    $dongle=file_get_contents("/var/svistok/sim/state/$imsi.dongle");
    $iccid=file_get_contents("/var/svistok/dongles/state/$dongle.iccid");
    $iccid1=str_replace('"','',$iccid);
    $imsi1="809".$imsi;


    $url="http://simserver:8122/stat/upload_balance.php?imsi=$imsi1&iccid=$iccid1&balance=$balance1";
    echo("url=$url\n");
    $res=file_get_contents($url);
    echo("res=$res\n");
}


function upload_op ($imsi, $op_t_str, $op_d_str)
{
    $dongle=file_get_contents("/var/svistok/sim/state/$imsi.dongle");
    $iccid=file_get_contents("/var/svistok/dongles/state/$dongle.iccid");
    $iccid1=str_replace('"','',$iccid);
    $imsi1="809".$imsi;

    $op_t=urlencode($op_t_str);
    $op_d=urlencode($op_d_str);

    $url="http://simserver:8122/stat/upload_op.php?imsi=$imsi1&iccid=$iccid1&op_t=$op_t&op_d=$op_d";
    echo("url=$url\n");
    $res=file_get_contents($url);
    echo("res=$res\n");
}


function upload_tarif ($imsi, $tarif)
{
    $tarif1=urlencode($tarif);

    $dongle=file_get_contents("/var/svistok/sim/state/$imsi.dongle");
    $iccid=file_get_contents("/var/svistok/dongles/state/$dongle.iccid");
    $iccid1=str_replace('"','',$iccid);

    $imsi1="809".$imsi;


    $url="http://simserver:8122/stat/upload_tarif.php?imsi=$imsi1&iccid=$iccid1&tarif=$tarif1";
    echo("url=$url\n");
    $res=file_get_contents($url);
    echo("res=$res\n");
}

function upload_number ($imsi, $number)
{
//    $number1=(int)$number;
    $number1=$number;

    $dongle=file_get_contents("/var/svistok/sim/state/$imsi.dongle");
    $iccid=file_get_contents("/var/svistok/dongles/state/$dongle.iccid");
    $iccid1=str_replace('"','',$iccid);

    $imsi1="809".$imsi;


    $url="http://simserver:8122/stat/upload_number.php?imsi=$imsi1&iccid=$iccid1&number=$number1";
    echo("url=$url\n");
    $res=file_get_contents($url);
    echo("res=$res\n");
}


//upload_balance("1","2");

?>