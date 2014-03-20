#!/usr/bin/php
<?
//die(hex2bin("4D6167696353494D"));
//die(bin2hex("41CDFA30D10DA827404F3A400AD555648D03"));

include("/usr/simbox/modules/at.php");


function fulltrim($t)
{
    $t1=str_replace(" ","",$t);
    return trim($t1);
}



$adapter=$argv[1];  # 9 = 9 oepokolenit
$dongle=$argv[2];
$dat_ki=fulltrim($argv[3]);
$dat_imsi=fulltrim($argv[4]);
$dat_iccid=fulltrim($argv[5]);
$dat_smsc=fulltrim($argv[6]);

echo("adapter=$adapter\n");

//die();

if ($adapter=="9")
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

//die();

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
//sleep(1);
//exec_at_command($dongle,'AT+CFUN=5;+CFUN?');
//sleep(1);
//system('/usr/simbox/actions/donglerestart.sh '.$dongle.' noimsi');


}
?>