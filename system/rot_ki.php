#!/usr/bin/php
<?
include("/usr/simbox/modules/at.php");

$dongle=@$argv[1];
$owner=@$argv[2];
$rot_ki=@$argv[3];
$rot_lo=@$argv[4];


echo ("===== Starting rotator for $dongle ($owner)\n");
$cnt=0;

while(($rot_lo==1)||($cnt==0))
{
echo("- cnt=$cnt\n");
$cnt++;

if($rot_ki=="1") 
{
echo ("- new ki\n");

system('/usr/simbox/system/new_ki.php "16" "'.$dongle.'" "'.$owner.'"');
//system('/usr/simbox/system/new_ki_on.php "'.$dongle.'" "'.$owner.'"');
echo ("pause\n"); sleep(100);


//echo ("- p-on\n");
//exec_at_command($dongle,'AT+CFUN=1;+CFUN?');
//echo ("pause\n"); sleep(30);

//echo ("- p-on\n");
//exec_at_command($dongle,'AT+CFUN=1,1;+CFUN?');
//echo ("pause\n"); sleep(100);


//echo ("- restart\n");
//system('/usr/simbox/actions/donglerestart.sh "'.$dongle.'" "noimsi"');
//echo ("pause\n"); sleep(200);

//echo ("- p-on\n");
//exec_at_command($dongle,'AT+CFUN=1,1;+CFUN?');
//echo ("pause\n"); sleep(30);


//echo ("- restart 1\n");
//system('/usr/simbox/actions/donglerestart.sh "'.$dongle.'" "noimsi"');
//echo ("pause\n"); sleep(78);

//echo ("- restart 2\n");
//system('/usr/simbox/actions/donglerestart.sh "'.$dongle.'" "noimsi"');
//echo ("pause\n"); sleep(180);

//echo ("- restart 3\n");
//system('/usr/simbox/actions/donglerestart.sh "'.$dongle.'" "noimsi"');
//echo ("pause\n"); sleep(210);

}


$imsi=file_get_contents("/var/svistok/dongles/state/$dongle.imsi");
if($imsi<=0)
{
    die("NO IMSI. FINISHED!\n");
}
echo("\nIMSI=".$imsi."\n");

system('/usr/sbin/asterisk -r -x "dongle setgroupimsi '.$imsi.' 10"');

echo ("- plan\n");
system('/usr/simbox/actions/set_plan.sh "'.$dongle.'" "'.$imsi.'" beeline_spb_bad');


//echo ("- activate sim\n");
//system('/usr/simbox/actions/activate_sim.sh "'.$dongle.'" "'.$imsi.'"');
//echo ("pause\n"); sleep(54);

echo ("- call\n");
system('/usr/simbox/system/makecall60.sh "'.$dongle.'" 8904'.rand(1000000,9999999));
echo ("pause\n"); sleep(69);


//echo ("- dover\n");
//system('/usr/simbox/actions/get_dover.sh "'.$dongle.'" "'.$imsi.'"');
//echo ("pause\n"); sleep(85);


//echo ("- activate work\n");
//system('/usr/simbox/actions/activate_work.sh "'.$dongle.'" "'.$imsi.'"');
//echo ("pause\n"); sleep(84);


echo ("- tarif\n");
system('/usr/simbox/actions/get_tarif.sh "'.$dongle.'" "'.$imsi.'"');
echo ("pause\n"); sleep(49);

echo ("- balance\n");
system('/usr/simbox/actions/get_balance.sh "'.$dongle.'" "'.$imsi.'"');
echo ("pause\n"); sleep(35);


echo ("- number\n");
system('/usr/simbox/actions/get_number.sh "'.$dongle.'" "'.$imsi.'"');
echo ("pause\n"); sleep(39);




$imsi=file_get_contents("/var/svistok/dongles/state/$dongle.imsi");

$balance=(int)file_get_contents("/var/simbox/sim/statistics/$imsi.balance");
$tarif=file_get_contents("/var/simbox/sim/settings/$imsi.tarif");
$number=(int)file_get_contents("/var/simbox/sim/settings/$imsi.number");

echo("balance=$balance tarif=$tarif number=$number\n");

/*
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
*/

system('/usr/sbin/asterisk -r -x "dongle setgroupimsi '.$imsi.' 30"');
echo ("- null SIM, restarting\n");
}

?>