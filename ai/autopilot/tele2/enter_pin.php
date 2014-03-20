#!/usr/bin/php
<?


$autopilot="tele2/enter_pin";

echo("autopilot=$autopilot\n");

$autopilot_do=0;

// Задержка перед включением автопилота

$autopilot_delay_min=3; //В минутах
$autopilot_delay_max=10;

// Задержка перед сдедующей операцией с сим

$sim_delay_min=30;
$sim_delay_max=60;

$autopilot_work_hour_start=0;  //>=0
$autopilot_work_hour_end=23;   //<=23


if (($now_hour>=$autopilot_work_start)&&($now_hour<=$autopilot_work_end))
{
    $autopilot_last=get_autopilot_last($autopilot);
    
    $veroyatnost=((time()-$autopilot_last)-($autopilot_delay_min*60))*100/($autopilot_delay_max*60)

    if($veroyatnost>rand(0,100)) $autopilot_do=1;
    
} else {
    echo ("not work hour\n");
}

echo("autopilot_do=$autopilot_do\n");

if($autopilot_do==1)
{
    echo("doing\n");
    // bybrat vse tele2
    // vybrat gde est pin
    $sim_last=get_sim_last($autopilot);


    // snat pin

    set_autopilot_last($autopilot)
}


?>