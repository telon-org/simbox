#!/usr/bin/php
<?

$imsilist=file("/var/svistok/lists/imsi.list");

foreach($imsilist as $k=>$imsi)
{
$imsi=trim($imsi);
$group=file_get_contents("/var/svistok/sim/settings/$imsi.group");
$need_in=file_get_contents("/var/simbox/sim/state/$imsi.need_in");
$number=file_get_contents("/var/simbox/sim/settings/$imsi.number");
$busy=file_get_contents("/var/svistok/sim/state/$imsi.busy");
$str_state=file_get_contents("/var/svistok/sim/state/$imsi.str_state");

$ca=file_get_contents("/var/svistok/sim/statistics/$imsi.stat_in_answered");

echo("$imsi => $group|$need_in|$number|$busy|$ca => ");


if($group==102) 
{
    if($ca<=5)
    {
	echo(" ca<=5 => needin=1 ");
	$need_in=1;
    }
}

if(($group>99)&&($group<200))
{
if($need_in==1)
{
if($busy!=1)
{
if($number>0)
{
if($str_state=="Free")
{

$cmd="/usr/simbox/system/makecallsebe.sh \"nodongle\" \"$number\" \"$imsi\"";
echo $cmd;
system($cmd);
sleep(10);

} else { echo (" ne state==Free"); }
} else { echo (" no number"); }
} else { echo (" busy"); }
} else { echo (" ne needin=1"); }
} else { echo (" ne (group>99)&&(group<200)"); }

echo("\n");
}
?>