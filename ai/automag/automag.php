<?
proc_nice(19);

$path_svistok_sim='/var/svistok/sim/';
$path_svistok_sim_state='/var/svistok/sim/state/';
$path_svistok_sim_settings='/var/svistok/sim/settings/';

while(1)
{

$data=file('/var/svistok/lists/imsi.list');
$imsilist=array();

foreach($data as $i=>$imsi)
{
$imsi=trim($imsi);
$dongle=file_get_contents($path_svistok_sim_state.$imsi.'.dongle');
//$imsilist[$imsi]=$dongle;
$imsilist[$dongle]=$imsi;
}
asort($imsilist);

$cnt_wait=0;
$cnt_busy=0;
$cnt_ready=0;


foreach($imsilist as $dongle=>$imsi)
{
    $group=file_get_contents($path_svistok_sim_settings.$imsi.'.group');
    if($group==295)
    {
	$w=0;

                                  $ce=@file_get_contents($path_svistok_sim.$imsi.'.stat_call_end');
                                  if ($ce>0)
                                  {
                                  $dm=file_get_contents($path_svistok_sim_settings.$imsi.'.diff_min');
                                  $dl=time()-$ce;
                                  if ($dl<$dm) $w=1;
                                  }

	if ($w==1) $cnt_wait++;
	else if ((file_get_contents($path_svistok_sim_state.$imsi.'.state_in'))==1) $cnt_busy++;
	else if ((file_get_contents($path_svistok_sim_state.$imsi.'.state_out'))==1) $cnt_busy++;
	else $cnt_ready++;
    }
}


echo("wait:$cnt_wait busy:$cnt_busy ready:$cnt_ready\n");

if($cnt_ready>4)
//if($cnt_ready>9)
{
    echo("get\n");
    $newmag=file_get_contents("http://simserver:8122/mag/get_new_mag.php");
    echo("ok\n");
    list($status, $numberb)=explode("|",$newmag);
    if($status=="MAG")
    {
	if($numberb!=0)
	{
	echo("MAG to $numberb\n");
	$cmd="/usr/simbox/system/makecallmag.sh L1D=HZ295 '+$numberb' '$numberb' 'NE0' 'AUT' 'hz' '999999999999999;' ''";
	echo ($cmd);
	system($cmd);
	} else echo(0);
    } else
    {
	echo("$status DIE\n");
	die();
    }
    sleep (1);
} else 
{
sleep (1);
}


}
?>