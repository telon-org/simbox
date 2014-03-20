#!/usr/bin/php
<?
include("/usr/simbox/modules/at.php");

function supersim_make_smsp($smsp)
{
    if (strlen($smsp)!=24) {echo("Incorrect smsp Length=".strlen($smsp)); die;}
    return $smsp;
}


function supersim_make_ki($ki)
{
    if (strlen($ki)!=32) {echo("Incorrect KI Length=".strlen($ki)); die;}
    return $ki;
}

function supersim_make_imsi($imsi)
{
    if (strlen($imsi)!=18) {echo("Incorrect IMSI Length!"); die;}

    $a_imsi=str_split($imsi);

    if ($a_imsi[1].$a_imsi[0]!="08") {echo("Incorrect IMSI NOT 08......!"); die;}

    return 
	    $a_imsi[1].$a_imsi[0].
	    $a_imsi[3].$a_imsi[2].
	    $a_imsi[5].$a_imsi[4].
	    $a_imsi[7].$a_imsi[6].
	    $a_imsi[9].$a_imsi[8].
	    $a_imsi[11].$a_imsi[10].
	    $a_imsi[13].$a_imsi[12].
	    $a_imsi[15].$a_imsi[14].
	    $a_imsi[17].$a_imsi[16];

}

function supersim_make_iccid($iccid)
{
    if (strlen($iccid)==19) {$iccid=$iccid."F";}
    if (strlen($iccid)!=20) {echo("Incorrect ICCID Length!"); die;}
    $a_iccid=str_split($iccid);

    return 
	    $a_iccid[1].$a_iccid[0].
	    $a_iccid[3].$a_iccid[2].
	    $a_iccid[5].$a_iccid[4].
	    $a_iccid[7].$a_iccid[6].
	    $a_iccid[9].$a_iccid[8].
	    $a_iccid[11].$a_iccid[10].
	    $a_iccid[13].$a_iccid[12].
	    $a_iccid[15].$a_iccid[14].
	    $a_iccid[17].$a_iccid[16].
	    $a_iccid[19].$a_iccid[18];
}

function power_off($dongle)
{
    echo ("[$dongle] Power OFF\n")
    exec_at_command($dongle,'AT+CFUN=5;+CFUN?');
}

function dongle_restart($dongle)
{
    echo ("[$dongle] dongle restart\n")
    system('/usr/simbox/actions/donglerestart.sh '.$dongle.' noimsi');
}

function dongle_changeimei($dongle,$imei)
{
    $cmd='/usr/sbin/asterisk -rx "dongle changeimei '.$dongle.' '.$imei.'"';
    echo $cmd;
    system($cmd);
}

function fulltrim($t)
{
    $t1=str_replace(" ","",$t);
    return trim($t1);
}


function dongle_restart_cfun($dongle)
{
    echo ("[$dongle] dongle restart CFUN\n")
    exec_at_command($dongle,'AT+CFUN=1,1');
}






function set_ki_9($dongle,$dat_ki,$dat_imsi,$dat_iccid,$dat_smsc)
{
    echo("SET KI 9th generation\n");

    exec_at_command($dongle,'AT^STGI=0,0');
    exec_at_command($dongle,'AT^STGR=0,0,1,22');
    exec_at_command($dongle,'AT^STGI=6,1');
    exec_at_command($dongle,'AT^STGR=6,1,1,3');
    exec_at_command($dongle,'AT^STGI=3,1');
    //KI
    //exec_at_command($dongle,'AT^STGR=3,1,1,"343143444641333044313044413832373430344633413430304144353535363438443033"');
    exec_at_command($dongle,'AT^STGR=3,1,1,"'.bin2hex($dat_ki).'"');
    exec_at_command($dongle,'AT^STGI=3,1');
    //IMSI 
    //exec_at_command($dongle,'AT^STGR=3,1,1,"3038323930353939313235393434333638333037"');
    exec_at_command($dongle,'AT^STGR=3,1,1,"'.bin2hex($dat_imsi).'"');
    exec_at_command($dongle,'AT^STGI=3,1');
    //ICCID 
    //exec_at_command($dongle,'AT^STGR=3,1,1,"38393730313939313131303739383733333646463435"');
    exec_at_command($dongle,'AT^STGR=3,1,1,"'.bin2hex($dat_iccid).'"');
    exec_at_command($dongle,'AT^STGI=3,1');
    //SMSC 
    //exec_at_command($dongle,'AT^STGR=3,1,1,"30373931393733303037313131314631464646464646464643373836"');
    exec_at_command($dongle,'AT^STGR=3,1,1,"'.bin2hex($dat_smsc).'"');
    exec_at_command($dongle,'AT^STGI=6,1');
    exec_at_command($dongle,'AT^STGI=0,0');

    //SELECT 3
    sleep(1);
    exec_at_command($dongle,'AT^STGI=0,0');
    exec_at_command($dongle,'AT^STGR=0,0,1,16');
    exec_at_command($dongle,'AT^STGI=6,1');
    exec_at_command($dongle,'AT^STGR=6,1,1,3');
    sleep(1);
    exec_at_command($dongle,'AT^STGI=7,1');
    sleep(1);
    exec_at_command($dongle,'AT^STGR=7,1,0,""');
    exec_at_command($dongle,'AT^STGI=0,0');
    sleep(1);
    //sleep(1);

}


function set_ki_16($dongle,$dat_ki,$dat_imsi,$dat_iccid,$dat_smsc,$imei)
{
    echo("SET KI Supersim 16 th generation\n");


//         "ccccccccccccccccccc" - 20
    $iccid="2222222222222222222F";
//        "mmmmmmmmmmmmmmmmmm" - 18
    $imsi="081111111111111111";
//      "kkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkk" - 32
    $ki="55555555555555555555555555555555";
//        "ssssssssssssssss" - 16
    $smsp="4444444444444444";
    
    $imsi=$dat_imsi;
    $iccid=$dat_iccid;
    $ki=$dat_ki;
    $smsp=$dat_smsp;


    //$imsi="809250992196240119";
    //$iccid="8970199120555611170";
    //$ki="30145021101807888A0DF504E5C47B5B";
    //$smsp="22222222222222222222222222222222222222222222222222222222";
    $smsp="07919730071111F1FFFFFFFF";

    $imsi=supersim_make_imsi($imsi);
    $iccid=supersim_make_iccid($iccid);
    $ki=supersim_make_ki($ki);
//    $smsp=supersim_make_smsp($smsp);

    echo("\n$imsi|$iccid|$ki|$smsp\n");

//    $apdu="A0DC01044ADC1EA4E0077E87FC8E1EA4E0077E87FC8E"."3F002FE2"."0A".$iccid."7F206F07"."09".$imsi."6F3018".$ki;
//    $apdu="A0DC01044A69DD8348C6140B348A7D525065751FEF"."3F002FE2"."0A".$iccid."7F206F07"."09".$imsi."6F3018".$ki;
//    $apdu="A0DC01044A".$ki."3F002FE2"."0A".$iccid."7F206F07"."09".$imsi."6F3018"."FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF";
      $apdu="A0DC01045A814D61676963FFFFFFFFFFFFFFFFFF".$iccid.$imsi.$ki."FFFFFFFFFFFFFFFFFFFFFFFFE1FFFFFFFFFFFFFFFFFFFFFFFF".$smsp."000000";

								   //    ffffffffffffffffffffffffe1ffffffffffffffffffffffff07819730071111f1ffffffff000000
//0dc01045a814d61676963ffffffffffffffffff981009510500000010f30899105500000000101f43f020067cc599a7763f44c52ca5e3ffffffffffffffffffffffffe1ffffffffffffffffffffffff068121436587f9ffffffffff000000

//    $cmd1='AT+CSIM=14,"A0A40000027F4D";+CSIM=14,"A0A40000028F0D";';
    $cmd1='AT+CSIM=14,"A0A40000023F00";';
    $cmd2='+CSIM=14,"A0A4000002000C";';
    $cmd3='+CSIM='.strlen($apdu).',"'.$apdu.'"';

    $cmd=$cmd1.$cmd2.$cmd2.$cmd3;
    echo($cmd);
    exec_at_command($dongle,$cmd);

}


function set_ki($adapter, $dongle,$dat_ki,$dat_imsi,$dat_iccid,$dat_smsc)
{
    echo("[$dongle] Set ki. adapter=$adapter\n");

    if ($adapter=="9")
    {
	set_ki_9($dongle,$dat_ki,$dat_imsi,$dat_iccid,$dat_smsc)
    } else if ($adapter=="16")
    {
	echo("SET KI Supersim 16 th generation\n");
	set_ki_16dongle,$dat_ki,$dat_imsi,$dat_iccid,$dat_smsc)
    }
}


function set_ki_imei($adapter, $dongle,$dat_ki,$dat_imsi,$dat_iccid,$dat_smsc,$imei)
{
    echo("[$dongle] Set ki. adapter=$adapter\n");

    if ($adapter=="9")
    {
	set_ki_9($dongle,$dat_ki,$dat_imsi,$dat_iccid,$dat_smsc,$imei)
    } else if ($adapter=="16")
    {
	echo("SET KI Supersim 16 th generation\n");
	set_ki_16dongle,$dat_ki,$dat_imsi,$dat_iccid,$dat_smsc,$imei)
    }
    dongle_changeimei($dongle,$imei);
    //power_off($dongle)
    dongle_restart_cfun($dongle);
}


/*
$adapter=$argv[1];  # 9 = 9 oepokolenit
$dongle=$argv[2];
$dat_ki=fulltrim($argv[3]);
$dat_imsi=fulltrim($argv[4]);
$dat_iccid=fulltrim($argv[5]);
$dat_smsc=fulltrim($argv[6]);
$imei=fulltrim($argv[7]);


set_ki($adapter, $dongle,$dat_ki,$dat_imsi,$dat_iccid,$dat_smsc,$imei);
*/

/*
$dongle=@$argv[1];
$owner=@$argv[2];
$rot_ki=@$argv[3];
$rot_lo=@$argv[4];


function rotator_done($dongle,$msg, $group)
{
    echo("[$dongle] $msg");
    dongle_set_group($dongle,$group);
    die();
}



function rotator($dongle, $owner, $rot_ki, $rot_loop)
{
    //rot_ki - менять ki
    //rot_loop - цикл, пока не найдем хорошую
    echo ("[$dongle] Starting rotator ($owner,$rot_ki, $rot_loop)\n");
    if(($rot_ki!=1)&&($rot_loop==1)) {rotator_done($dongle,"Невозможно зациклить без смены ki",39);}

    $cnt=0;

    while(($rot_loop==1)||($cnt==0))
    {
	echo("[$dongle]-- cnt=$cnt\n");
	$cnt++;

	if($rot_ki=="1") 
	{
	    echo ("- new ki\n");
	    
	    //newimsi
	    // if(!) rotator_done($dongle,"В  базе закончились KI",38);

	    system('/usr/simbox/system/new_ki.php "16" "'.$dongle.'" "'.$owner.'"');
	    //system('/usr/simbox/system/new_ki_on.php "'.$dongle.'" "'.$owner.'"');
	    echo ("pause\n"); sleep(100);
	    // check_imsi
	    // if(!) rotator_done($dongle,"KI не изменен",37);
	    // check_imei
	    // if(!) rotator_done($dongle,"IMEI не изменен",37);
	}




$imsi=file_get_contents("/var/svistok/dongles/state/$dongle.imsi");
if($imsi<=0)
{
    
}

system('/usr/sbin/asterisk -r -x "dongle setgroupimsi '.$imsi.' 10"');

echo ("- plan\n");
system('/usr/simbox/actions/set_plan.sh "'.$dongle.'" "'.$imsi.'" beeline_spb_bad');


echo ("- activate sim\n");
system('/usr/simbox/actions/activate_sim.sh "'.$dongle.'" "'.$imsi.'"');
echo ("pause\n"); sleep(84);


echo ("- dover\n");
system('/usr/simbox/actions/get_dover.sh "'.$dongle.'" "'.$imsi.'"');
echo ("pause\n"); sleep(85);




echo ("- activate work\n");
system('/usr/simbox/actions/activate_work.sh "'.$dongle.'" "'.$imsi.'"');
echo ("pause\n"); sleep(84);


echo ("- number\n");
system('/usr/simbox/actions/get_number.sh "'.$dongle.'" "'.$imsi.'"');
echo ("pause\n"); sleep(79);

echo ("- balance\n");
system('/usr/simbox/actions/get_balance.sh "'.$dongle.'" "'.$imsi.'"');
echo ("pause\n"); sleep(85);

echo ("- tarif\n");
system('/usr/simbox/actions/get_tarif.sh "'.$dongle.'" "'.$imsi.'"');
echo ("pause\n"); sleep(69);

$imsi=file_get_contents("/var/svistok/dongles/state/$dongle.imsi");

$balance=(int)file_get_contents("/var/simbox/sim/statistics/$imsi.balance");
$tarif=file_get_contents("/var/simbox/sim/settings/$imsi.tarif");
$number=(int)file_get_contents("/var/simbox/sim/settings/$imsi.number");

echo("balance=$balance tarif=$tarif number=$number\n");

if(($balance<>0)||($tarif<>"")||($number>0))
{
    if (strstr($tarif,"XXL"))
    {
	system('/usr/sbin/asterisk -r -x "dongle setgroupimsi '.$imsi.' 50"');
	die("Finished! FOUND XXL\n");
    }
    if ($balance>0)
    {
	system('/usr/sbin/asterisk -r -x "dongle setgroupimsi '.$imsi.' 49"');
	die("Finished! FOUND BALANCE>0 => 205\n");
    }
    system('/usr/sbin/asterisk -r -x "dongle setgroupimsi '.$imsi.' 40"');

    die("Finished! FOUND SOMETHING\n");
}
system('/usr/sbin/asterisk -r -x "dongle setgroupimsi '.$imsi.' 30"');
echo ("- null SIM, restarting\n");
}
*/
?>