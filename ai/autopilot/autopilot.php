#!/usr/bin/php
<?

function can_autopilot($autopilot, $iccid, $once, $pause_next_sim, $pause_next_action)
{
    $autopilot_last_action=file_get_contents("/var/svistok/sim/statistics/$autopilot.last_action");

    if(time()-$autopilot_last_action<$pause_next_action)
    {
	echo ("!>NOT autopilot_last_action<pause_next_action");
	return FALSE;
    }

/*
    $sim_once=file_get_contents("/var/svistok/sim/statistics/$iccid.$autopilot.once")

    $autopilot_last_action=file_get_contents("/var/svistok/sim/statistics/$iccid.$autopilot.last_action")

    $sim_last_autopilot=file_get_contents("/var/svistok/sim/statistics/$iccid.$autopilot.last_action")
    $sim_last_thisaction=file_get_contents("/var/svistok/sim/statistics/$iccid.$autopilot.last_action")

    if ($once==true)
*/

    file_put_contents("/var/svistok/sim/statistics/$autopilot.last_action", time());
    return TRUE;
}

$now_hour=date("H");

$dongles = fopen("/var/svistok/lists/dongles.list", "r");
if($dongles)
while (!feof($dongles)) {
    $dongle = trim(fgets($dongles, 4096));
    echo "Autopilot for $dongle\n";

    $imsi=@file_get_contents("/var/svistok/dongles/state/$dongle.imsi");
    $iccid=@file_get_contents("/var/svistok/dongles/state/$dongle.iccid");
    $spn=substr($iccid,3,4);
    
    if(substr($iccid,3,4)=="0721") $spn="TELE2";

    $state=@file_get_contents("/var/svistok/dongles/state/$dongle.str_state");

    echo "$state\n";
    echo "imsi=$imsi iccid=$iccid spn=$spn\n";


    /* AUTOPILOT tele2/enter_pin */
    
    $autopilot="tele2_enter_pin";

    $once=TRUE;
    $pause_next_sim=456;
    $pause_next_action=456;

    if((strstr($state,"PIN"))&&($spn="TELE2"))
    {
	if (can_autopilot($autopilot,$iccid, $once, $pause_next_sim, $pause_next_action))
	{
	    echo ">>ENTERING PIN\n";
	    system("/usr/simbox/nabor/tele2_spb/commands/enter_pin.sh $dongle");
	}
    }

    //include("/usr/simbox/ai/autopilot/tele2/enter_pin.php");

}
fclose($dongles);



?>