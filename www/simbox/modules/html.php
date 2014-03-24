<?


function html_op($op_t, $op_d)
{
    if ($op_t=="") return "";
    if ($op_t=="<50") return "ОП: нет, траты<50";
    if ($op_t=="баланс") return "ОП: нет, баланс";
    if ($op_t=="до") return "ОП: ".$op_t." ".date("d.m",$op_d);
    if ($op_t=="после")
    {
	$dn=floor(($op_d-time())/86400);
	if ($dn>0) return "ОП: через $dn дн.";
	    else return "ОП: можно";
    }


    return "ОП: ".$op_t." ".date("d.m.y",$op_d);
}

function html_napr($billing_direction)
{
    $napr="<img src=imgs/napravleine/hz.ico>".$billing_direction;


    if($billing_direction=="bee_msk") $napr="<img src=imgs/napravleine/beeline_msk.ico>";
    if($billing_direction=="bee_spb")  $napr="<img src=imgs/napravleine/beeline_spb.ico>";
    if($billing_direction=="bee_ru")  $napr="<img src=imgs/napravleine/beeline_ru.ico>";

    if($billing_direction=="meg_msk")  $napr="<img src=imgs/napravleine/megafon_msk.ico>";
    if($billing_direction=="meg_spb")  $napr="<img src=imgs/napravleine/megafon_spb.ico>";
    if($billing_direction=="meg_sz")  $napr="<img src=imgs/napravleine/megafon_sz.ico>";
    if($billing_direction=="meg_chel")  $napr="<img src=imgs/napravleine/megafon_chel.ico>";
    if($billing_direction=="meg_ural")  $napr="<img src=imgs/napravleine/megafon_ural.ico>";

    if($billing_direction=="meg_ru")  $napr="<img src=imgs/napravleine/megafon_ru.ico>";

    if($billing_direction=="mts_msk") $napr="<img src=imgs/napravleine/mts_msk.ico>";
    if($billing_direction=="mts_spb") $napr="<img src=imgs/napravleine/mts_spb.ico>";
    if($billing_direction=="mts_ru") $napr="<img src=imgs/napravleine/mts_ru.ico>";
    if($billing_direction=="mts_u") $napr="<img src=imgs/napravleine/mts_u.ico>";
    if($billing_direction=="mts_by") $napr="<img src=imgs/napravleine/mts_by.ico>";

    if($billing_direction=="kievstar") $napr="<img src=imgs/napravleine/kievstar.ico>";

    if($billing_direction=="velcom_by") $napr="<img src=imgs/napravleine/velcom_by.ico>";

    if($billing_direction=="life_by") $napr="<img src=imgs/napravleine/life_by.ico>";

    if($billing_direction=="tele2_spb") $napr="<img src=imgs/napravleine/tele2_spb.ico>";
    if($billing_direction=="tele2_ru") $napr="<img src=imgs/napravleine/tele2_ru.ico>";

    if($billing_direction=="proper_minsk") $napr="<img src=imgs/napravleine/proper_minsk.ico>";

    if($billing_direction=="proper_msk") $napr="<img src=imgs/napravleine/proper_msk.ico>";
    if($billing_direction=="proper_spb") $napr="<img src=imgs/napravleine/proper_spb.ico>";

    if($billing_direction=="elisa_fi") $napr="<img src=imgs/napravleine/elisa.ico>";
    if($billing_direction=="dna_fi") $napr="<img src=imgs/napravleine/dna.ico>";
    if($billing_direction=="sonera_fi") $napr="<img src=imgs/napravleine/sonera.ico>";

    if($billing_direction=="rostel_spb_mob") $napr="<img src=imgs/napravleine/rostel_spb_mob.png>";
    if($billing_direction=="rostel_spb_gor") $napr="<img src=imgs/napravleine/rostel_spb_gor.png>";


    if($billing_direction=="HZ") $napr="<img src=imgs/napravleine/hz.ico>";
    if($billing_direction=="BM") $napr="<img src=imgs/napravleine/beeline_msk.ico>";
    if($billing_direction=="BS") $napr="<img src=imgs/napravleine/beeline_spb.ico>";
    if($billing_direction=="BR") $napr="<img src=imgs/napravleine/beeline_ru.ico>";

    if($billing_direction=="NM") $napr="<img src=imgs/napravleine/megafon_msk.ico>";
    if($billing_direction=="NS") $napr="<img src=imgs/napravleine/megafon_spb.ico>";
    if($billing_direction=="NZ") $napr="<img src=imgs/napravleine/megafon_sz.ico>";
    if($billing_direction=="NR") $napr="<img src=imgs/napravleine/megafon_ru.ico>";

    if($billing_direction=="SM") $napr="<img src=imgs/napravleine/mts_msk.ico>";
    if($billing_direction=="SS") $napr="<img src=imgs/napravleine/mts_spb.ico>";
    if($billing_direction=="SR") $napr="<img src=imgs/napravleine/mts_ru.ico>";
    if($billing_direction=="SU") $napr="<img src=imgs/napravleine/mts_u.ico>";
    if($billing_direction=="SB") $napr="<img src=imgs/napravleine/mts_by.ico>";

    if($billing_direction=="SR") $napr="<img src=imgs/napravleine/rostel_spb_mob.png>";
    if($billing_direction=="PR") $napr="<img src=imgs/napravleine/rostel_spb_gor.png>";

    if($billing_direction=="KU") $napr="<img src=imgs/napravleine/kievstar.ico>";

    if($billing_direction=="VB") $napr="<img src=imgs/napravleine/velcom_by.ico>";

    if($billing_direction=="LB") $napr="<img src=imgs/napravleine/life_by.ico>";

    if($billing_direction=="TS") $napr="<img src=imgs/napravleine/tele2_spb.ico>";
    if($billing_direction=="TR") $napr="<img src=imgs/napravleine/tele2_ru.ico>";

    if($billing_direction=="PB") $napr="<img src=imgs/napravleine/proper_minsk.ico>";

    if($billing_direction=="PM") $napr="<img src=imgs/napravleine/proper_msk.ico>";
    if($billing_direction=="PS") $napr="<img src=imgs/napravleine/proper_spb.ico>";


    if($billing_direction=="EF") $napr="<img src=imgs/napravleine/elisa.ico>";
    if($billing_direction=="DF") $napr="<img src=imgs/napravleine/dna.ico>";
    if($billing_direction=="SF") $napr="<img src=imgs/napravleine/sonera.ico>";

    return $napr;
}


function html_group($group, $pause)
{
    $group_html="";

    if(($group>=100)&&($group<=299)) 
    {
	$group_html="<img src=imgs/play.png>";
	if ($pause==1) $group_html="<img src=imgs/pause.png><img src=imgs/day_work.png>";
	if ($pause==2) $group_html="<img src=imgs/pause.png><img src=imgs/day_holiday.png>";

	if ($pause==11) $group_html="<img src=imgs/wake.png><img src=imgs/day_work.png>";
	if ($pause==12) $group_html="<img src=imgs/wake.png><img src=imgs/day_holiday.png>";

	if ($pause==21) $group_html="<img src=imgs/sleep.png><img src=imgs/day_work.png>";
	if ($pause==22) $group_html="<img src=imgs/slep.png><img src=imgs/day_holiday.png>";

    }
    if($group==333) $group_html="<img src=imgs/high_datt.ico>"; else
    if($group==334) $group_html="<img src=imgs/low_acdl.ico>"; else
    if($group==335) $group_html="<img src=imgs/blocked_balance.ico>"; else
    if($group==336) $group_html="<img src=imgs/simblocked.ico>"; else
    if(($group>=300)&&($group<=399)) $group_html="<img src=imgs/low_acdl.png>";
    if(($group>=400)&&($group<=499)) $group_html="<img src=imgs/low_balance.png>";
    if(($group>=500)&&($group<=599)) $group_html="<img src=imgs/blocked.png>";

    return $group_html;
}


function html_dialstatus($ds)
{
    $ds_html="<img src=imgs/napravleine/hz.ico><font size=1>".substr($ds,0,4);
    if($ds=="ANSWER")   $ds_html="<img src=imgs/state_active.png>";
    if($ds=="NOANSWER") $ds_html="<img src=imgs/state_dial.png>";
    if($ds=="BUSY") $ds_html="<img src=imgs/recog_types/30.png>";

    return $ds_html;
}

function html_endparty($ep)
{
    $ep_html="<img src=imgs/state/end_party/-1.ico>";
    if($ep==1) $ep_html="<img src=imgs/state/end_party/1.ico>";
    if($ep==2) $ep_html="<img src=imgs/state/end_party/2.ico>";
    if($ep==3) $ep_html="<img src=imgs/state/end_party/3.ico>";

    return $ep_html;
}

function html_recog_type($rt)
{
    $rt_img=$rt;

    if ($rt=="0") $rt_img='';
    if ($rt=="10") $rt_img='<img src="imgs/recog_types/10.ico" valign=bottom>';
    if ($rt=="20") $rt_img='<img src="imgs/recog_types/20.png" valign=bottom>';
    if ($rt=="30") $rt_img='<img src="imgs/recog_types/30.png" valign=bottom>';
    if (($rt>=50)&&($rt<=59)) $rt_img='<img src="imgs/recog_types/50.png" valign=bottom>';
    if ($rt=="90") $rt_img='<img src="imgs/recog_types/90.ico" valign=bottom>';
    if ($rt=="91") $rt_img='<img src="imgs/recog_types/91.ico" valign=bottom>';
    if ($rt=="92") $rt_img='<img src="imgs/recog_types/92.ico" valign=bottom>';
    if ($rt=="100") $rt_img='<img src="imgs/recog_types/100.png" valign=bottom>';
    if (($rt>=110)&&($rt<=119)) $rt_img='<img src="imgs/recog_types/110.ico" valign=bottom>';
    if (($rt>=120)&&($rt<=129)) $rt_img='<img src="imgs/recog_types/120.ico" valign=bottom>';

    return($rt_img);
}


function html_dongle($model)
{
    $dongle_img='<img src="imgs/dongle.png" valign=bottom>'.$model;
    if ($model=="E1550") $dongle_img='<img src="imgs/dongle1550.ico" valign=bottom>';
    if ($model=="E173") $dongle_img='<img src="imgs/dongle173.ico" valign=bottom>';
    return($dongle_img);
}


function html_cfun($cfun)
{
    $power_img=$cfun;
    if ($cfun=="-1") $power_img='<img src="imgs/state/-1.ico" valign=bottom>';
    if ($cfun=="1") $power_img='<img src="imgs/p-on.png" valign=bottom>';
    if ($cfun=="5") $power_img='<img src="imgs/p-off.png" valign=bottom>';
    if ($cfun=="4") $power_img='<img src="imgs/state/cfun/4.ico" valign=bottom>';
    if ($cfun=="6") $power_img='<img src="imgs/state/cfun/6.ico" valign=bottom>';

    return($power_img);
}

function html_simst($simst,$pinrequired)
{
    $simst_img=$simst;

    if ($simst=="-1") $simst_img='<img src="imgs/state/-1.ico" valign=bottom>';
    if ($simst=="0") $simst_img='<img src="imgs/state/simst/0.ico" valign=bottom>';
    if ($simst=="1") $simst_img='<img src="imgs/state/simst/1.ico" valign=bottom>';
    if ($simst=="3") $simst_img='<img src="imgs/state/simst/4.ico" valign=bottom>';
    if ($simst=="4") $simst_img='<img src="imgs/state/simst/4.ico" valign=bottom>';
    if (($simst=="0")&&($pinrequired>0)) $simst_img='<img src="imgs/state/simst/16.ico" valign=bottom>';
    if ($simst=="255") $simst_img='<img src="imgs/state/simst/255.ico" valign=bottom>';


    return($simst_img);
//    return($simst_img.$simst);
}

function html_srvst($srvst,$simst)
{
    $srvst_img=$srvst;

    if ($srvst=="-1") $srvst_img='<img src="imgs/state/-1.ico" valign=bottom>';
    if ($srvst=="0") $srvst_img='<img src="imgs/state/srvst/0.ico" valign=bottom>';
    if ($srvst=="1")
    {
      if(($simst=="0")||($simst=="255"))
        $srvst_img='<img src="imgs/state/srvst/112.ico" valign=bottom>';
      else
        $srvst_img='<img src="imgs/state/srvst/1.ico" valign=bottom>';
    }
    if ($srvst=="2") $srvst_img='<img src="imgs/state/srvst/2.ico" valign=bottom>';


    return($srvst_img);
//    return($srvst_img.$srvst);

}

function html_fas($fas)
{
    $ss=$fas;

    if($fas=="0")   $ss="";
    if ($fas>0) $ss="<img src=imgs/fas.png>";

    return $ss;
}


function html_spec($spec)
{
    $ss=$spec;

    if($spec=="NO")   $ss="";
    if($spec=="SOU")   $ss="";
    if($spec=="PRE")  $ss="<img src=imgs/spec/pre.png>";
    if($spec=="PRE")  $ss="<img src=imgs/spec/pos.png>";
    if($spec=="MAY")  $ss="<img src=imgs/spec/may.png>";
    if($spec=="LOC")  $ss="<img src=imgs/spec/local.png>";
    if($spec=="LO2")  $ss="<img src=imgs/spec/local2.png>";

    if ($spec=="FOR") $ss="<img src=imgs/spec/forwarding.png>";
    if ($spec=="WAI") $ss="<img src=imgs/spec/in_wait.png>";
    if ($spec=="SPE") $ss="<img src=imgs/spec/in_sound.png>";

    if ($spec=="CAROUSEL") $ss="<img src=imgs/spec/carousel.ico>";
    if ($spec=="INTER") $ss="<img src=imgs/spec/conn.ico>";

    if($spec=="MAG")  $ss="<img src=imgs/spec/mag.png>";
    if($spec=="200")  $ss="<img src=imgs/spec/mag.png>";

    if($spec=="0")   $ss="";
    if ($spec==20) $ss="<img src=imgs/spec/may.png>";
    if ($spec==30) $ss="<img src=imgs/spec/nav.png>";

    if ($spec==101) $ss="<img src=imgs/spec/local.png>";
    if ($spec==102) $ss="<img src=imgs/spec/local2.png>";

    return $ss;
}


function html_im($im)
{
    $ss=$im;

    if($im=="-")  $ss="";
    if($im=="N")  $ss="";
    if($im=="A")  $ss="<img src=imgs/im/ima.png>";
    if($im=="B")  $ss="<img src=imgs/im/imb.png>";
    if($im=="C")  $ss="<img src=imgs/im/imc.ico>";
    if($im=="D")  $ss="<img src=imgs/im/imd.ico>";
    if($im=="E")  $ss="<img src=imgs/im/ime.ico>";

    return $ss;
}


function html_io($io)
{
    $ss=$io;
    if($io=="O")  $ss="<img src=imgs/state_out.png>";
    if($io=="I")  $ss="<img src=imgs/state_in.png>";

    return $ss;
}

function html_qos($qos, $io)
{
    $qosstr=$qos;

    if($qos=="FAST")  $qosstr="<img src=imgs/qos/fast.ico>";
    if($qos=="VERY")  $qosstr="<img src=imgs/qos/very.ico>";
    if($qos=="SLOW")  $qosstr="<img src=imgs/qos/slow.png>";
    if($qos=="NEVER")  $qosstr="<img src=imgs/qos/never.png>";

    if($qos=="NOS")  $qosstr="<img src=imgs/qos/inos.png>";
    if($qos=="GOO")  $qosstr="<img src=imgs/qos/igoo.png>";
    if($qos=="BAD")  $qosstr="<img src=imgs/qos/ibad.png>";
    if($qos=="NOR")  $qosstr="<img src=imgs/qos/inor.png>";
    if($qos=="NEW")  $qosstr="<img src=imgs/qos/inew.png>";

    if($qos=="NE0")  $qosstr="<img src=imgs/qos/ine0.ico>";
    if($qos=="NEM")  $qosstr="<img src=imgs/qos/inem.ico>";
    if($qos=="NEC")  $qosstr="<img src=imgs/qos/inec.ico>";

    if($qos=="40")  $qosstr="<img src=imgs/qos/ine0.ico>";
    if($qos=="41")  $qosstr="<img src=imgs/qos/inec.ico>";
    if($qos=="42")  $qosstr="<img src=imgs/qos/inem.ico>";

    if(($qos=="SOU")&&($io=="O")) $qosstr="<img src=imgs/state/state_sout_out.ico>";
    if(($qos=="SOU")&&($io=="I")) $qosstr="<img src=imgs/state/state_sout_in.ico>";
    if($qos=="ROB")  $qosstr="<img src=imgs/qos/irob.png>";
    if($qos=="BLO")  $qosstr="<img src=imgs/qos/iblo.png>";


    if($qos=="0") $qosstr="<img src=imgs/inos.png>";
    if($qos==1)  $qosstr="<img src=imgs/igoo.png>";
    if($qos==2)  $qosstr="<img src=imgs/ibad.png>";
    if($qos==3)  $qosstr="<img src=imgs/inor.png>";
    if($qos==4)  $qosstr="<img src=imgs/inew.png>";
    if($qos==5)  $qosstr="<img src=imgs/state_sout_out.ico>";
    if($qos==6)  $qosstr="<img src=imgs/imode.png>";
    if($qos==7)  $qosstr="<img src=imgs/ivip.png>";
    if($qos==8)  $qosstr="<img src=imgs/irob.png>";
    if($qos==9)  $qosstr="<img src=imgs/iblo.png>";


    return $qosstr;
}

?>