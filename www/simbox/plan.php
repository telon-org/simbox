<?
if(@isset($_POST['show_modes'])) $show_modes=$_POST['show_modes']; else $show_modes=1;
if(@isset($_POST['show_limits'])) $show_limits=$_POST['show_limits']; else $show_limits=1;
if(@isset($_POST['show_timing'])) $show_timing=$_POST['show_timing']; else $show_timing=1;
if(@isset($_POST['show_time'])) $show_time=$_POST['show_time']; else $show_time=1;
if(@isset($_POST['show_iatt'])) $show_iatt=$_POST['show_iatt']; else $show_iatt=1;
if(@isset($_POST['show_satt'])) $show_satt=$_POST['show_satt']; else $show_satt=1;
if(@isset($_POST['show_callback'])) $show_callback=$_POST['show_callback']; else $show_callback=1;
?>

<?
if(isset($_POST['save'])){
	
	$cmd='chmod -R 0777 /var/simbox/';
	$res=system("sudo ".$cmd);


	foreach($_POST['items'] as $v=>$plan)
	
	{
		//if(trim($v)=='')unset($_POST['tarif'][$i]);
		file_put_contents($path_simbox_plan.$plan.'.online_max',$_POST['online_max'][$plan]);
		file_put_contents($path_simbox_plan.$plan.'.add_max',$_POST['add_max'][$plan]);

		file_put_contents($path_simbox_plan.$plan.'.priority',$_POST['priority'][$plan]);
		file_put_contents($path_simbox_plan.$plan.'.pro',$_POST['pro'][$plan]);

if($show_limits==1)
{
		file_put_contents($path_simbox_plan.$plan.'.limit_max.1',$_POST['limit_max1'][$plan]);
		file_put_contents($path_simbox_plan.$plan.'.limit_max.2',$_POST['limit_max2'][$plan]);
		file_put_contents($path_simbox_plan.$plan.'.limit_max.3',$_POST['limit_max3'][$plan]);
		file_put_contents($path_simbox_plan.$plan.'.limit_max.4',$_POST['limit_max4'][$plan]);

		file_put_contents($path_simbox_plan.$plan.'.limit_hard.1',$_POST['limit_hard1'][$plan]);
		file_put_contents($path_simbox_plan.$plan.'.limit_hard.2',$_POST['limit_hard2'][$plan]);
		file_put_contents($path_simbox_plan.$plan.'.limit_hard.3',$_POST['limit_hard3'][$plan]);
		file_put_contents($path_simbox_plan.$plan.'.limit_hard.4',$_POST['limit_hard4'][$plan]);


		file_put_contents($path_simbox_plan.$plan.'.alg.1',$_POST['alg1'][$plan]);
		file_put_contents($path_simbox_plan.$plan.'.alg.2',$_POST['alg2'][$plan]);
		file_put_contents($path_simbox_plan.$plan.'.alg.3',$_POST['alg3'][$plan]);
		file_put_contents($path_simbox_plan.$plan.'.alg.4',$_POST['alg4'][$plan]);

		file_put_contents($path_simbox_plan.$plan.'.nodiff.1',$_POST['nodiff1'][$plan]);
		file_put_contents($path_simbox_plan.$plan.'.nodiff.2',$_POST['nodiff2'][$plan]);
		file_put_contents($path_simbox_plan.$plan.'.nodiff.3',$_POST['nodiff3'][$plan]);
		file_put_contents($path_simbox_plan.$plan.'.nodiff.4',$_POST['nodiff4'][$plan]);

}

if($show_timing==1)
{


		file_put_contents($path_simbox_plan.$plan.'.diff_slow',$_POST['diff_slow'][$plan]);
		file_put_contents($path_simbox_plan.$plan.'.diff_min',$_POST['diff_min'][$plan]);
//		file_put_contents($path_simbox_plan.$plan.'.diff_min_out',$_POST['diff_min_out'][$plan]);
		file_put_contents($path_simbox_plan.$plan.'.diff_min_goo',$_POST['diff_min_goo'][$plan]);
		file_put_contents($path_simbox_plan.$plan.'.diff_min_nor',$_POST['diff_min_nor'][$plan]);
		file_put_contents($path_simbox_plan.$plan.'.diff_min_vip',$_POST['diff_min_vip'][$plan]);
		file_put_contents($path_simbox_plan.$plan.'.diff_min_sout',$_POST['diff_min_sout'][$plan]);
		file_put_contents($path_simbox_plan.$plan.'.diff_min_imode',$_POST['diff_min_imode'][$plan]);
}


if($show_time==1)
{

		file_put_contents($path_simbox_plan.$plan.'.time_work_wake',$_POST['time_work_wake'][$plan]);
		file_put_contents($path_simbox_plan.$plan.'.time_work_sleep',$_POST['time_work_sleep'][$plan]);
		file_put_contents($path_simbox_plan.$plan.'.time_holiday_wake',$_POST['time_holiday_wake'][$plan]);
		file_put_contents($path_simbox_plan.$plan.'.time_holiday_sleep',$_POST['time_holiday_sleep'][$plan]);

}


if($show_modes==1)
{
		file_put_contents($path_simbox_plan.$plan.'.can_in',$_POST['can_in'][$plan]);
		file_put_contents($path_simbox_plan.$plan.'.can_out',$_POST['can_out'][$plan]);
		file_put_contents($path_simbox_plan.$plan.'.can_sout',$_POST['can_sout'][$plan]);


		file_put_contents($path_simbox_plan.$plan.'.notvip',$_POST['notvip'][$plan]);
		file_put_contents($path_simbox_plan.$plan.'.ivip',$_POST['ivip'][$plan]);
		file_put_contents($path_simbox_plan.$plan.'.igoo',$_POST['igoo'][$plan]);
		file_put_contents($path_simbox_plan.$plan.'.inor',$_POST['inor'][$plan]);
		file_put_contents($path_simbox_plan.$plan.'.ibad',$_POST['ibad'][$plan]);
		file_put_contents($path_simbox_plan.$plan.'.inew',$_POST['inew'][$plan]);

		file_put_contents($path_simbox_plan.$plan.'.ine0',$_POST['ine0'][$plan]);
		file_put_contents($path_simbox_plan.$plan.'.inec',$_POST['inec'][$plan]);
		file_put_contents($path_simbox_plan.$plan.'.inem',$_POST['inem'][$plan]);


		file_put_contents($path_simbox_plan.$plan.'.inos',$_POST['inos'][$plan]);
		file_put_contents($path_simbox_plan.$plan.'.iblo',$_POST['iblo'][$plan]);
		file_put_contents($path_simbox_plan.$plan.'.irob',$_POST['irob'][$plan]);

		file_put_contents($path_simbox_plan.$plan.'.capnew',$_POST['capnew'][$plan]);
		file_put_contents($path_simbox_plan.$plan.'.capfail',$_POST['capfail'][$plan]);
		file_put_contents($path_simbox_plan.$plan.'.capok',$_POST['capok'][$plan]);


//		file_put_contents($path_simbox_plan.$plan.'.ima',$_POST['ima'][$plan]);
		file_put_contents($path_simbox_plan.$plan.'.imb',$_POST['imb'][$plan]);
		file_put_contents($path_simbox_plan.$plan.'.imc',$_POST['imc'][$plan]);
		file_put_contents($path_simbox_plan.$plan.'.imd',$_POST['imd'][$plan]);
		file_put_contents($path_simbox_plan.$plan.'.imn',$_POST['imn'][$plan]);
		file_put_contents($path_simbox_plan.$plan.'.ime',$_POST['ime'][$plan]);
}

if($show_iatt==1)
{



		file_put_contents($path_simbox_plan.$plan.'.iatt_soft',$_POST['iatt_soft'][$plan]);
		file_put_contents($path_simbox_plan.$plan.'.iatt_min',$_POST['iatt_min'][$plan]);
		file_put_contents($path_simbox_plan.$plan.'.iatt_max',$_POST['iatt_max'][$plan]);
		file_put_contents($path_simbox_plan.$plan.'.out_in_ans',$_POST['out_in_ans'][$plan]);
		file_put_contents($path_simbox_plan.$plan.'.out_in_dur',$_POST['out_in_dur'][$plan]);
		file_put_contents($path_simbox_plan.$plan.'.in_acd_min',$_POST['in_acd_min'][$plan]);
		file_put_contents($path_simbox_plan.$plan.'.in_acd_max',$_POST['in_acd_max'][$plan]);
		file_put_contents($path_simbox_plan.$plan.'.out_acd_min',$_POST['out_acd_min'][$plan]);
		file_put_contents($path_simbox_plan.$plan.'.out_acd_max',$_POST['out_acd_max'][$plan]);

		file_put_contents($path_simbox_plan.$plan.'.forwarding',$_POST['forwarding'][$plan]);
		file_put_contents($path_simbox_plan.$plan.'.outin',$_POST['outin'][$plan]);
		file_put_contents($path_simbox_plan.$plan.'.conn',$_POST['conn'][$plan]);
		file_put_contents($path_simbox_plan.$plan.'.rand',$_POST['rand'][$plan]);
		file_put_contents($path_simbox_plan.$plan.'.in_wait',$_POST['in_wait'][$plan]);
		file_put_contents($path_simbox_plan.$plan.'.in_sound',$_POST['in_sound'][$plan]);

}

if($show_satt==1)
{

		file_put_contents($path_simbox_plan.$plan.'.mon_limit',$_POST['mon_limit'][$plan]);
		file_put_contents($path_simbox_plan.$plan.'.may_limit',$_POST['may_limit'][$plan]);
		file_put_contents($path_simbox_plan.$plan.'.msm_limit',$_POST['msm_limit'][$plan]);
		file_put_contents($path_simbox_plan.$plan.'.nospam',$_POST['nospam'][$plan]);


		file_put_contents($path_simbox_plan.$plan.'.smsout_soft',$_POST['smsout_soft'][$plan]);
		file_put_contents($path_simbox_plan.$plan.'.smsout_hard',$_POST['smsout_hard'][$plan]);

		file_put_contents($path_simbox_plan.$plan.'.satt_soft',$_POST['satt_soft'][$plan]);
		file_put_contents($path_simbox_plan.$plan.'.satt_soft_day',$_POST['satt_soft_day'][$plan]);
		file_put_contents($path_simbox_plan.$plan.'.satt_soft_total',$_POST['satt_soft_total'][$plan]);

		file_put_contents($path_simbox_plan.$plan.'.satt_hard',$_POST['satt_hard'][$plan]);
		file_put_contents($path_simbox_plan.$plan.'.satt_hard_day',$_POST['satt_hard_day'][$plan]);
		file_put_contents($path_simbox_plan.$plan.'.satt_hard_total',$_POST['satt_hard_total'][$plan]);


}


	}

}
?>


<?
if(isset($_POST['create_plan'])){
$plan_name=@$_POST['plan_name'];
$plan_nabor=@$_POST['plan_nabor'];
file_put_contents($path_simbox_plan.'/plan.list',$plan_name."\n", FILE_APPEND | LOCK_EX);
file_put_contents($path_simbox_plan.$plan_name.'.nabor',$plan_nabor);
}
?>


<h1>Планы</h1>


<form method="post">
<input type="hidden" name="show_modes" value=0>
<input type="hidden" name="show_limits" value=0>
<input type="hidden" name="show_timing" value=0>
<input type="hidden" name="show_time" value=0>
<input type="hidden" name="show_callback" value=0>
<input type="hidden" name="show_satt" value=0>

<table>
<tr class="header" >
<td colspan=2>
Отображение информации
</td></tr>




<tr><td><img src=imgs/igoo.png></td><td><input type="checkbox" name="show_modes" value=1 <?if($show_modes==1) echo "checked";?>>режимы<br></td></tr>
<tr><td><img src=imgs/state_wait.png></td><td><input type="checkbox" name="show_timing" value=1 <?if($show_timing==1) echo "checked";?>>тайминги<br></td></tr>
<tr><td><img src=imgs/pause.png></td><td><input type="checkbox" name="show_time" value=1 <?if($show_time==1) echo "checked";?>>расписание<br></td></tr>
<tr><td></td><td><input type="checkbox" name="show_callback" value=1 <?if($show_callback==1) echo "checked";?>>Форвардинг звонков<br></td></tr>
<tr><td><img src=imgs/need_in.png></td><td><input type="checkbox" name="show_iatt" value=1 <?if($show_iatt==1) echo "checked";?>>генерация входящих<br></td></tr>
<tr><td><img src=imgs/satt.png></td><td><input type="checkbox" name="show_satt" value=1 <?if($show_satt==1) echo "checked";?>>генерация sms<br></td></tr>
<tr><td></td><td><input type="checkbox" name="show_limits" value=1 <?if($show_limits==1) echo "checked";?>>направления<br></td></tr>

<tr><td colspan=2 align="center">
<input type="submit" name="refresh" value="Обновить"> <br><br>
</td></tr></table>

<br><br>



<table>
<tr class="header" style="border-bottom: 1px solid #cccccc">
<td rowspan=2>online<br>max</td>
<td rowspan=2>add/res<br>max</td>
<td rowspan=2>план<br><font size=1>набор</font></td>
<td rowspan=2 style="border-right: 1px solid #cccccc">priority</td>
<td rowspan=2>pro</td>

<?
if($show_timing==1)
{
?>
<td rowspan=2 style="border-left: 1px solid #cccccc" align="center"><img src=imgs/state_wait.png><img src=imgs/slow.png><br><font size=1 color=#cccccc>diff_slow<br><br></td>
<td rowspan=2 align="center"><img src=imgs/state_wait.png><img src=imgs/inew.png><br><font size=1 color=#cccccc>diff_min<br><br></td>
<td rowspan=2 align="center"><img src=imgs/state_wait.png><img src=imgs/ivip.png><br><font size=1 color=#cccccc>diff_min<br>_vip</td>
<td rowspan=2 align="center"><img src=imgs/state_wait.png><img src=imgs/igoo.png><br><font size=1 color=#cccccc>diff_min<br>_goo</td>
<td rowspan=2 align="center"><img src=imgs/state_wait.png><img src=imgs/inor.png><br><font size=1 color=#cccccc>diff_min<br>_nor</td>
<td rowspan=2 align="center"><img src=imgs/state_wait.png><img src=imgs/state_sout.png><br><font size=1 color=#cccccc>diff_min<br>_sout</td>
<td rowspan=2 align="center" style="border-right: 1px solid #cccccc"><img src=imgs/state_wait.png><img src=imgs/imb.png><img src=imgs/imc.ico><br><font size=1 color=#cccccc>diff_min<br>_imode</td>
<?
}
?>

<?
if($show_time==1)
{
?>

<td rowspan=2 align="center"><img src=imgs/pause.png><img src=imgs/day_work.png><img src=imgs/wake.png><br><font size=1 color=#cccccc>time_work<br>_wake<br></td>
<td rowspan=2 align="center"><img src=imgs/pause.png><img src=imgs/day_work.png><img src=imgs/sleep.png><br><font size=1 color=#cccccc>time_work<br>_sleep<br></td>
<td rowspan=2 align="center"><img src=imgs/pause.png><img src=imgs/day_holiday.png><img src=imgs/wake.png><br><font size=1 color=#cccccc>time_hol<br>_wake<br></td>
<td rowspan=2 align="center" style="border-right: 1px solid #cccccc"><img src=imgs/pause.png><img src=imgs/day_holiday.png><img src=imgs/sleep.png><br><font size=1 color=#cccccc>time_hol<br>_sleep</td>
<?
}
?>


<?
if($show_modes==1)
{
?>
<td rowspan=2 style="border-left: 1px solid #cccccc" align="center"><img src=imgs/state_in.png alt="can in"><br><font size=1 color=#cccccc>can<br>_in</td>
<td rowspan=2 align="center"><img src=imgs/state_out.png alt="can out"><br><font size=1 color=#cccccc>can<br>_out</td>
<td rowspan=2 align="center"><img src=imgs/state_sout.png alt="can out"><br><font size=1 color=#cccccc>can<br>_sout</td>
<td rowspan=2 align="center"><img src=imgs/ivip.png alt=ivip><br><font size=1 color=#cccccc>iVIP<br><br></td>
<td rowspan=2 align="center" style="border-right: 1px dashed #cccccc"><img src=imgs/spec/notvip.png alt=notvip><br><font size=1 color=#cccccc>notVIP<br><br></td>
<td rowspan=2 align="center"><img src=imgs/igoo.png alt=iGOO><br><font size=1 color=#cccccc>iGOO<br><br></td>
<td rowspan=2 align="center"><img src=imgs/inor.png alt=iNOR><br><font size=1 color=#cccccc>iNOR<br><br></td>
<td rowspan=2 align="center"><img src=imgs/ibad.png alt=iBAD><br><font size=1 color=#cccccc>iBAD<br><br></td>


<td rowspan=2 align="center"><img src=imgs/qos/ine0.ico alt=iNEW><br><font size=1 color=#cccccc>iNE0<br><br></td>
<td rowspan=2 align="center"><img src=imgs/qos/inec.ico alt=iNEW><br><font size=1 color=#cccccc>iNEC<br><br></td>
<td rowspan=2 align="center"><img src=imgs/qos/inem.ico alt=iNEW><br><font size=1 color=#cccccc>iNEM<br><br></td>
<td rowspan=2 align="center"><img src=imgs/qos/inew.png alt=iNEW><br><font size=1 color=#cccccc>iNEW<br><br></td>

<td rowspan=2 align="center"><img src=imgs/inos.png alt=iNOS><br><font size=1 color=#cccccc>iNOS<br><br></td>
<td rowspan=2 align="center"><img src=imgs/iblo.png alt=iBLO><br><font size=1 color=#cccccc>iBLO<br><br></td>
<td rowspan=2 align="center" style="border-right: 1px dashed #cccccc"><img src=imgs/irob.png alt=iROB><br><font size=1 color=#cccccc>iROB<br><br></td>

<td rowspan=2 align="center"><img src=imgs/qos/capnew.png alt=capnew><br><font size=1 color=#cccccc>NEW<br><br></td>
<td rowspan=2 align="center"><img src=imgs/qos/capfail.png alt=capfail><br><font size=1 color=#cccccc>FAIL<br><br></td>
<td rowspan=2 align="center" style="border-right: 1px dashed #cccccc"><img src=imgs/qos/capok.png alt=capok><br><font size=1 color=#cccccc>OK<br><br></td>


<td rowspan=2 align="center"><img src=imgs/imn.ico alt=iMN><br><font size=1 color=#cccccc>IMN<br><br></td>
<!--<td rowspan=2 align="center"><img src=imgs/ima.png alt=iMA><br><font size=1 color=#cccccc>IMA<br><br></td>-->
<td rowspan=2 align="center"><img src=imgs/imb.png alt=iMB><br><font size=1 color=#cccccc>IMB<br><br></td>
<td rowspan=2 align="center"><img src=imgs/imc.ico alt=iMC><br><font size=1 color=#cccccc>IMC<br><br></td>
<td rowspan=2 align="center"><img src=imgs/imd.ico alt=iMD><br><font size=1 color=#cccccc>IMD<br><br></td>
<td rowspan=2 align="center"><img src=imgs/ime.ico alt=iME><br><font size=1 color=#cccccc>IME<br><br></td>
<?
}
?>



<?
if($show_limits==1)
{
?>

<td colspan=4 style="border-left: 1px solid #cccccc; border-bottom: 0px"" align="center"><font size=2 color=#cccccc>Направление 1</td>
<td colspan=4 style="border-left: 1px dashed #cccccc" align="center"><font size=2 color=#cccccc>Направление 2</td>
<td colspan=4 style="border-left: 1px dashed #cccccc" align="center"><font size=2 color=#cccccc>Направление 3</td>
<td colspan=4 style="border-left: 1px dashed #cccccc" align="center"><font size=2 color=#cccccc>Направление 4</td>

<? } ?>

<?
if($show_iatt==1)
{
?>
<td colspan=5 style="border-left: 1px solid #cccccc" align="center"><img src=imgs/need_in.png><font size=2 color=#cccccc> Запрос входящих</td>
<td colspan=2 style="border-left: 1px dashed #cccccc" align="center"><img src=imgs/state_sout_out.ico><font size=2 color=#cccccc> длит. исходящих</td>
<td colspan=2 style="border-left: 1px dashed #cccccc" align="center"><img src=imgs/state_sout_in.ico><font size=2 color=#cccccc> длит. входящих</td>
<td colspan=6 style="border-left: 1px dashed #cccccc" align="center"><font size=2 color=#cccccc>Входящие</td>
<? } ?>

<?
if($show_satt==1)
{
?>
<td colspan=12 style="border-left: 1px solid #cccccc" align="center"><img src=imgs/satt.png> <font size=2 color=#cccccc>SATT</td>
<?
}
?>

</tr>
<tr class="header" style="border-bottom: 1px solid #cccccc">


<?
if($show_limits==1)
{
?>



<td style="border-left: 1px solid #cccccc" align="center"><font size=1 color=#cccccc>alg<br><br></td>
<td align="center" valign="top"><img src=imgs/state_wait.png></td>
<td align="center"><font size=1 color=#cccccc>limit<br>_soft<br></td>
<td align="center"><font size=1 color=#cccccc>limit<br>_hard<br></td>

<td style="border-left: 1px dashed #cccccc" align="center"><font size=1 color=#cccccc>alg<br><br></td>
<td align="center" valign="top"><img src=imgs/state_wait.png></td>
<td align="center"><font size=1 color=#cccccc>limit<br>_soft<br></td>
<td align="center"><font size=1 color=#cccccc>limit<br>_hard<br></td>

<td style="border-left: 1px dashed #cccccc" align="center"><font size=1 color=#cccccc>alg<br><br></td>
<td align="center" valign="top"><img src=imgs/state_wait.png></td>
<td align="center"><font size=1 color=#cccccc>limit<br>_soft<br></td>
<td align="center"><font size=1 color=#cccccc>limit<br>_hard<br></td>

<td style="border-left: 1px dashed #cccccc" align="center"><font size=1 color=#cccccc>alg<br><br></td>
<td align="center" valign="top"><img src=imgs/state_wait.png></td>
<td align="center"><font size=1 color=#cccccc>limit<br>_soft<br></td>
<td align="center"><font size=1 color=#cccccc>limit<br>_hard<br></td>


<?
}
?>

<?
if($show_iatt==1)
{
?>
<td style="border-left: 1px solid #cccccc" align="center"><font size=1 color=#cccccc>IATT<br>_soft<br></td>
<td align="center"><font size=1 color=#cccccc>IATT<br>_MIN<br></td>
<td align="center"><font size=1 color=#cccccc>IATT<br>_MAX<br></td>
<td align="center"><font size=1 color=#cccccc>OUT_IN<br>_ANS<br></td>
<td align="center"><font size=1 color=#cccccc>OUT_IN<br>_DUR<br></td>
<td align="center" style="border-left: 1px dashed #cccccc"><font size=1 color=#cccccc>IN_ACD<br>_MIN<br></td>
<td align="center"><font size=1 color=#cccccc>IN_ACD<br>_MAX<br></td>
<td align="center" style="border-left: 1px dashed #cccccc"><font size=1 color=#cccccc>OUT_ACD<br>_MIN<br></td>
<td align="center"><font size=1 color=#cccccc>OUT_ACD<br>_MAX<br></td>

<td align="center" style="border-left: 1px dashed #cccccc"><img src=imgs/forwarding.png></td>
<td align="center"><img src=imgs/outin.png></td>
<td align="center"><img src=imgs/conn.png></td>
<td align="center"><img src=imgs/rand.ico></td>
<td align="center"><img src=imgs/in_wait.png></td>
<td align="center"><img src=imgs/in_sound.png></td>

<?
}
?>

<?
if($show_satt==1)
{
?>
<td style="border-left: 1px solid #cccccc" align="center"><img src=imgs/may.ico></td>
<td align="center"><img src=imgs/mon.ico></td>
<td align="center"><img src=imgs/msm.ico></td>

<td align="center"><img src=imgs/sms_out.png><font size=1 color=#cccccc><br>_soft</td>
<td align="center"><img src=imgs/sms_out.png><font size=1 color=#cccccc><br>_hard</td>


<td align="center"><img src=imgs/nospam.ico></td>

<td align="center"><font size=1 color=#cccccc>SATT<br>_soft<br></td>

<td align="center"><font size=1 color=#cccccc>SATT<br>_soft_day<br></td>
<td align="center"><font size=1 color=#cccccc>SATT<br>_soft_total<br></td>

<td align="center"><font size=1 color=#cccccc>SATT<br>_hard<br></td>
<td align="center"><font size=1 color=#cccccc>SATT<br>_hard_day<br></td>
<td align="center"><font size=1 color=#cccccc>SATT<br>_hard_total<br></td>
<?
}
?>


</tr>

<?
$data=file($path_simbox_plan.'/plan.list');
foreach($data as $i=>$v){
	$v=trim($v);
	$plan=$v;
	?>
	<tr <?if($i%2==0)echo 'class="zebra"';?>>
	<input type="hidden" name="items[]" value="<?=$plan;?>">
		<td><?=file_get_contents_def2($path_simbox_plan.$plan.'.online_day',"");?> <br> <input type="text" name="online_max[<?=$plan?>]" size=1 value="<?=file_get_contents_def($path_simbox_plan.$plan.'.online_max',"5");?>"></td>
		<td><?=file_get_contents_def2($path_simbox_plan.$plan.'.add_day',"0");?> / <?=file_get_contents_def2($path_simbox_plan.$plan.'.reserv_day',"0");?> <br> <input type="text" name="add_max[<?=$plan?>]" size=1 value="<?=file_get_contents_def($path_simbox_plan.$plan.'.add_max',"1");?>"></td>

		<td><?=$plan;?><br><font size=1>
		<?=file_get_contents_def($path_simbox_plan.$plan.'.nabor',"default");?></font></td>
		

		<td style="border-right: 1px solid #cccccc"><input type="text" name="priority[<?=$plan?>]" size=1 value="<?=file_get_contents_def($path_simbox_plan.$plan.'.priority',"5");?>"></td>
		<td style="border-right: 1px solid #cccccc"><input type="text" name="pro[<?=$plan?>]" size=1 value="<?=file_get_contents_def($path_simbox_plan.$plan.'.pro',"");?>"></td>

<?
if($show_timing==1)
{
?>

		<td style="border-left: 1px solid #cccccc"><input type="text" name="diff_slow[<?=$plan?>]" size=2 value="<?=file_get_contents_def($path_simbox_plan.$plan.'.diff_slow',"5");?>"></td>
		<td><input type="text" name="diff_min[<?=$plan?>]" size=2 value="<?=file_get_contents_def($path_simbox_plan.$plan.'.diff_min',"120");?>"></td>
		<td><input type="text" name="diff_min_vip[<?=$plan?>]" size=2 value="<?=file_get_contents_def($path_simbox_plan.$plan.'.diff_min_vip',"40");?>"></td>
		<td><input type="text" name="diff_min_goo[<?=$plan?>]" size=2 value="<?=file_get_contents_def($path_simbox_plan.$plan.'.diff_min_goo',"30");?>"></td>
		<td><input type="text" name="diff_min_nor[<?=$plan?>]" size=2 value="<?=file_get_contents_def($path_simbox_plan.$plan.'.diff_min_nor',"50");?>"></td>
		<td><input type="text" name="diff_min_sout[<?=$plan?>]" size=2 value="<?=file_get_contents_def($path_simbox_plan.$plan.'.diff_min_sout',"30");?>"></td>
		<td><input type="text" name="diff_min_imode[<?=$plan?>]" size=2 value="<?=file_get_contents_def($path_simbox_plan.$plan.'.diff_min_imode',"10");?>"></td>
<?
}
?>

<?
if($show_time==1)
{
?>

		<td style="border-left: 1px solid #cccccc"><input type="text" name="time_work_wake[<?=$plan?>]" size=2 value="<?=file_get_contents_def($path_simbox_plan.$plan.'.time_work_wake',"-1");?>"></td>
		<td><input type="text" name="time_work_sleep[<?=$plan?>]" size=2 value="<?=file_get_contents_def($path_simbox_plan.$plan.'.time_work_sleep',"-1");?>"></td>
		<td><input type="text" name="time_holiday_wake[<?=$plan?>]" size=2 value="<?=file_get_contents_def($path_simbox_plan.$plan.'.time_holiday_wake',"-1");?>"></td>
		<td><input type="text" name="time_holiday_sleep[<?=$plan?>]" size=2 value="<?=file_get_contents_def($path_simbox_plan.$plan.'.time_holiday_sleep',"-1");?>"></td>

<?
}
?>


<?
if($show_modes==1)
{
?>
		
		<td style="border-left: 1px solid #cccccc">
		<input type="hidden" name="can_in[<?=$plan;?>]" value=0>
		<input type="checkbox" name="can_in[<?=$plan;?>]" value=1 <?if(file_get_contents_def($path_simbox_plan.$plan.'.can_in','1')==1)echo 'checked';?>>
		</td>
		
		<td>
		<input type="hidden" name="can_out[<?=$plan;?>]" value=0>
		<input type="checkbox" name="can_out[<?=$plan;?>]" value=1 <?if(file_get_contents_def($path_simbox_plan.$plan.'.can_out','1')==1)echo 'checked';?>>
		</td>
		
		<td>
		<input type="hidden" name="can_sout[<?=$plan;?>]" value=0>
		<input type="checkbox" name="can_sout[<?=$plan;?>]" value=1 <?if(file_get_contents_def($path_simbox_plan.$plan.'.can_sout','1')==1)echo 'checked';?>>
		</td>
		
		<td>
		<input type="hidden" name="ivip[<?=$plan;?>]" value=0>
		<input type="checkbox" name="ivip[<?=$plan;?>]" value=1 <?if(file_get_contents_def($path_simbox_plan.$plan.'.ivip','1')==1)echo 'checked';?>>
		</td>
		<td style="border-right: 1px dashed #cccccc">
		<input type="hidden" name="notvip[<?=$plan;?>]" value=0>
		<input type="checkbox" name="notvip[<?=$plan;?>]" value=1 <?if(file_get_contents_def($path_simbox_plan.$plan.'.notvip','1')==1)echo 'checked';?>>
		</td>


		
		<td>
		<input type="hidden" name="igoo[<?=$plan;?>]" value=0>
		<input type="checkbox" name="igoo[<?=$plan;?>]" value=1 <?if(file_get_contents_def($path_simbox_plan.$plan.'.igoo','1')==1)echo 'checked';?>>
		</td>
		
		<td>
		<input type="hidden" name="inor[<?=$plan;?>]" value=0>
		<input type="checkbox" name="inor[<?=$plan;?>]" value=1 <?if(file_get_contents_def($path_simbox_plan.$plan.'.inor','1')==1)echo 'checked';?>>
		</td>
		
		<td>
		<input type="hidden" name="ibad[<?=$plan;?>]" value=0>
		<input type="checkbox" name="ibad[<?=$plan;?>]" value=1 <?if(file_get_contents_def($path_simbox_plan.$plan.'.ibad','1')==1)echo 'checked';?>>
		</td>
		
		<td>
		<input type="hidden" name="ine0[<?=$plan;?>]" value=0>
		<input type="checkbox" name="ine0[<?=$plan;?>]" value=1 <?if(file_get_contents_def($path_simbox_plan.$plan.'.ine0','1')==1)echo 'checked';?>>
		</td>
		<td>
		<input type="hidden" name="inec[<?=$plan;?>]" value=0>
		<input type="checkbox" name="inec[<?=$plan;?>]" value=1 <?if(file_get_contents_def($path_simbox_plan.$plan.'.inec','1')==1)echo 'checked';?>>
		</td>
		<td>
		<input type="hidden" name="inem[<?=$plan;?>]" value=0>
		<input type="checkbox" name="inem[<?=$plan;?>]" value=1 <?if(file_get_contents_def($path_simbox_plan.$plan.'.inem','1')==1)echo 'checked';?>>
		</td>
		<td>
		<input type="hidden" name="inew[<?=$plan;?>]" value=0>
		<input type="checkbox" name="inew[<?=$plan;?>]" value=1 <?if(file_get_contents_def($path_simbox_plan.$plan.'.inew','1')==1)echo 'checked';?>>
		</td>

		
		<td>
		<input type="hidden" name="inos[<?=$plan;?>]" value=0>
		<input type="checkbox" name="inos[<?=$plan;?>]" value=1 <?if(file_get_contents_def($path_simbox_plan.$plan.'.inos','0')==1)echo 'checked';?>>
		</td>
		
		<td>
		<input type="hidden" name="iblo[<?=$plan;?>]" value=0>
		<input type="checkbox" name="iblo[<?=$plan;?>]" value=1 <?if(file_get_contents_def($path_simbox_plan.$plan.'.iblo','0')==1)echo 'checked';?>>
		</td>
		
		<td style="border-right: 1px dashed #cccccc">
		<input type="hidden" name="irob[<?=$plan;?>]" value=0>
		<input type="checkbox" name="irob[<?=$plan;?>]" value=1 <?if(file_get_contents_def($path_simbox_plan.$plan.'.irob','0')==1)echo 'checked';?>>
		</td>
		

		<td>
		<input type="hidden" name="capnew[<?=$plan;?>]" value=0>
		<input type="checkbox" name="capnew[<?=$plan;?>]" value=1 <?if(file_get_contents_def($path_simbox_plan.$plan.'.capnew','1')==1)echo 'checked';?>>
		</td>

		<td>
		<input type="hidden" name="capfail[<?=$plan;?>]" value=0>
		<input type="checkbox" name="capfail[<?=$plan;?>]" value=1 <?if(file_get_contents_def($path_simbox_plan.$plan.'.capfail','0')==1)echo 'checked';?>>
		</td>

		<td style="border-right: 1px dashed #cccccc">
		<input type="hidden" name="capok[<?=$plan;?>]" value=0>
		<input type="checkbox" name="capok[<?=$plan;?>]" value=1 <?if(file_get_contents_def($path_simbox_plan.$plan.'.capok','1')==1)echo 'checked';?>>
		</td>


		<td>
		<input type="hidden" name="imn[<?=$plan;?>]" value=0>
		<input type="checkbox" name="imn[<?=$plan;?>]" value=1 <?if(file_get_contents_def($path_simbox_plan.$plan.'.imn','1')==1)echo 'checked';?>>
		</td>

<!--
		<td>
		<input type="hidden" name="ima[<?=$plan;?>]" value=0>
		<input type="checkbox" name="ima[<?=$plan;?>]" value=1 <?if(file_get_contents_def($path_simbox_plan.$plan.'.ima','1')==1)echo 'checked';?>>
		</td>
-->
		<td>
		<input type="hidden" name="imb[<?=$plan;?>]" value=0>
		<input type="checkbox" name="imb[<?=$plan;?>]" value=1 <?if(file_get_contents_def($path_simbox_plan.$plan.'.imb','1')==1)echo 'checked';?>>
		</td>

		<td>
		<input type="hidden" name="imc[<?=$plan;?>]" value=0>
		<input type="checkbox" name="imc[<?=$plan;?>]" value=1 <?if(file_get_contents_def($path_simbox_plan.$plan.'.imc','1')==1)echo 'checked';?>>
		</td>

		<td>
		<input type="hidden" name="imd[<?=$plan;?>]" value=0>
		<input type="checkbox" name="imd[<?=$plan;?>]" value=1 <?if(file_get_contents_def($path_simbox_plan.$plan.'.imd','1')==1)echo 'checked';?>>
		</td>

		<td>
		<input type="hidden" name="ime[<?=$plan;?>]" value=0>
		<input type="checkbox" name="ime[<?=$plan;?>]" value=1 <?if(file_get_contents_def($path_simbox_plan.$plan.'.ime','0')==1)echo 'checked';?>>
		</td>


<?
}
?>

<?
if($show_limits==1)
{
?>

		<!-- -->
		<td style="border-left: 1px solid #cccccc">
		<select name="alg1[<?=$plan?>]">
		<?$alg1=file_get_contents_def2($path_simbox_plan.$plan.'.alg.1','42')?>
		<option value="42" <?if($alg1==42)echo 'selected';?>>*</option>
		<option value="62" <?if($alg1==62)echo 'selected';?>>&gt</option>
		<option value="81" <?if($alg1==81)echo 'selected';?>>&gtQ</option>
		<option value="68" <?if($alg1==68)echo 'selected';?>>D</option>
		<option value="100" <?if($alg1==100)echo 'selected';?>>DQ</option>
		<option value="60" <?if($alg1==60)echo 'selected';?>>&lt</option>
		<option value="95" <?if($alg1==95)echo 'selected';?>>_</option>
		<option value="94" <?if($alg1==94)echo 'selected';?>>^</option>
		<option value="65" <?if($alg1==65)echo 'selected';?>>A</option>
		<option value="66" <?if($alg1==66)echo 'selected';?>>B</option>
		<option value="97" <?if($alg1==97)echo 'selected';?>>a</option>
		<option value="98" <?if($alg1==98)echo 'selected';?>>b</option>
		<option value="88" <?if($alg1==88)echo 'selected';?>>X</option>
		<option value="90" <?if($alg1==90)echo 'selected';?>>Z</option>
		<option value="80" <?if($alg1==80)echo 'selected';?>>P</option>
		<option value="112" <?if($alg1==112)echo 'selected';?>>p</option>
		<option value="118" <?if($alg1==118)echo 'selected';?>>v</option>
		</select>
		</td>

		<td>
		<input type="hidden" name="nodiff1[<?=$plan;?>]" value=1>
		<input type="checkbox" name="nodiff1[<?=$plan;?>]" value=0 <?if(file_get_contents_def($path_simbox_plan.$plan.'.nodiff.1','0')==0)echo 'checked';?>>
		</td>

		<td><input type="text" name="limit_max1[<?=$plan?>]" size=2 value="<?=file_get_contents_def2($path_simbox_plan.$plan.'.limit_max.1',"9000");?>"></td>
		<td><input type="text" name="limit_hard1[<?=$plan?>]" size=2 value="<?=file_get_contents_def2($path_simbox_plan.$plan.'.limit_hard.1',"10000");?>"></td>
		<!-- -->



		<!--  -->
		<td style="border-left: 1px dashed #cccccc">
		<select name="alg2[<?=$plan?>]">
		<?$alg2=file_get_contents_def2($path_simbox_plan.$plan.'.alg.2','0')?>
		<option value="42" <?if($alg2==42)echo 'selected';?>>*</option>
		<option value="62" <?if($alg2==62)echo 'selected';?>>&gt</option>
		<option value="81" <?if($alg2==81)echo 'selected';?>>&gtQ</option>
		<option value="68" <?if($alg2==68)echo 'selected';?>>D</option>
		<option value="100" <?if($alg2==100)echo 'selected';?>>DQ</option>
		<option value="60" <?if($alg2==60)echo 'selected';?>>&lt</option>
		<option value="95" <?if($alg2==95)echo 'selected';?>>_</option>
		<option value="94" <?if($alg2==94)echo 'selected';?>>^</option>
		<option value="65" <?if($alg2==65)echo 'selected';?>>A</option>
		<option value="66" <?if($alg2==66)echo 'selected';?>>B</option>
		<option value="97" <?if($alg2==97)echo 'selected';?>>a</option>
		<option value="98" <?if($alg2==98)echo 'selected';?>>b</option>
		<option value="88" <?if($alg2==88)echo 'selected';?>>X</option>
		<option value="90" <?if($alg2==90)echo 'selected';?>>Z</option>
		<option value="80" <?if($alg2==80)echo 'selected';?>>P</option>
		<option value="112" <?if($alg2==112)echo 'selected';?>>p</option>
		<option value="118" <?if($alg2==118)echo 'selected';?>>v</option>

		</select>
		</td>

		<td>
		<input type="hidden" name="nodiff2[<?=$plan;?>]" value=1>
		<input type="checkbox" name="nodiff2[<?=$plan;?>]" value=0 <?if(file_get_contents_def($path_simbox_plan.$plan.'.nodiff.2','0')==0)echo 'checked';?>>
		</td>

		<td><input type="text" name="limit_max2[<?=$plan?>]" size=2 value="<?=file_get_contents_def2($path_simbox_plan.$plan.'.limit_max.2',"9000");?>"></td>
		<td><input type="text" name="limit_hard2[<?=$plan?>]" size=2 value="<?=file_get_contents_def2($path_simbox_plan.$plan.'.limit_hard.2',"10000");?>"></td>
		<!-- -->


		<!--  -->
		<td style="border-left: 1px dashed #cccccc">
		<select name="alg3[<?=$plan?>]">
		<?$alg3=file_get_contents_def2($path_simbox_plan.$plan.'.alg.3','0')?>
		<option value="42" <?if($alg3==42)echo 'selected';?>>*</option>
		<option value="62" <?if($alg3==62)echo 'selected';?>>&gt</option>
		<option value="81" <?if($alg3==81)echo 'selected';?>>&gtQ</option>
		<option value="68" <?if($alg3==68)echo 'selected';?>>D</option>
		<option value="100" <?if($alg3==100)echo 'selected';?>>DQ</option>
		<option value="60" <?if($alg3==60)echo 'selected';?>>&lt</option>
		<option value="95" <?if($alg3==95)echo 'selected';?>>_</option>
		<option value="94" <?if($alg3==94)echo 'selected';?>>^</option>
		<option value="65" <?if($alg3==65)echo 'selected';?>>A</option>
		<option value="66" <?if($alg3==66)echo 'selected';?>>B</option>
		<option value="97" <?if($alg3==97)echo 'selected';?>>a</option>
		<option value="98" <?if($alg3==98)echo 'selected';?>>b</option>
		<option value="88" <?if($alg3==88)echo 'selected';?>>X</option>
		<option value="90" <?if($alg3==90)echo 'selected';?>>Z</option>
		<option value="80" <?if($alg3==80)echo 'selected';?>>P</option>
		<option value="112" <?if($alg3==112)echo 'selected';?>>p</option>
		<option value="118" <?if($alg3==118)echo 'selected';?>>v</option>

		</select>
		</td>

		<td>
		<input type="hidden" name="nodiff3[<?=$plan;?>]" value=1>
		<input type="checkbox" name="nodiff3[<?=$plan;?>]" value=0 <?if(file_get_contents_def($path_simbox_plan.$plan.'.nodiff.3','0')==0)echo 'checked';?>>
		</td>

		<td><input type="text" name="limit_max3[<?=$plan?>]" size=2 value="<?=file_get_contents_def2($path_simbox_plan.$plan.'.limit_max.3',"9000");?>"></td>
		<td><input type="text" name="limit_hard3[<?=$plan?>]" size=2 value="<?=file_get_contents_def2($path_simbox_plan.$plan.'.limit_hard.3',"10000");?>"></td>
		<!--  -->


		<!--  -->
		<td style="border-left: 1px dashed #cccccc">
		<select name="alg4[<?=$plan?>]">
		<?$alg4=file_get_contents_def2($path_simbox_plan.$plan.'.alg.4','0')?>
		<option value="42" <?if($alg4==42)echo 'selected';?>>*</option>
		<option value="62" <?if($alg4==62)echo 'selected';?>>&gt</option>
		<option value="81" <?if($alg4==81)echo 'selected';?>>&gtQ</option>
		<option value="68" <?if($alg4==68)echo 'selected';?>>D</option>
		<option value="100" <?if($alg4==100)echo 'selected';?>>DQ</option>
		<option value="60" <?if($alg4==60)echo 'selected';?>>&lt</option>
		<option value="95" <?if($alg4==95)echo 'selected';?>>_</option>
		<option value="94" <?if($alg4==94)echo 'selected';?>>^</option>
		<option value="65" <?if($alg4==65)echo 'selected';?>>A</option>
		<option value="66" <?if($alg4==66)echo 'selected';?>>B</option>
		<option value="97" <?if($alg4==97)echo 'selected';?>>a</option>
		<option value="98" <?if($alg4==98)echo 'selected';?>>b</option>
		<option value="88" <?if($alg4==88)echo 'selected';?>>X</option>
		<option value="90" <?if($alg4==90)echo 'selected';?>>Z</option>
		<option value="80" <?if($alg4==80)echo 'selected';?>>P</option>
		<option value="112" <?if($alg4==112)echo 'selected';?>>p</option>
		<option value="118" <?if($alg4==118)echo 'selected';?>>v</option>


		</select>
		</td>

		<td>
		<input type="hidden" name="nodiff4[<?=$plan;?>]" value=1>
		<input type="checkbox" name="nodiff4[<?=$plan;?>]" value=0 <?if(file_get_contents_def($path_simbox_plan.$plan.'.nodiff.4','0')==0)echo 'checked';?>>
		</td>

		<td><input type="text" name="limit_max4[<?=$plan?>]" size=2 value="<?=file_get_contents_def2($path_simbox_plan.$plan.'.limit_max.4',"9000");?>"></td>
		<td><input type="text" name="limit_hard4[<?=$plan?>]" size=2 value="<?=file_get_contents_def2($path_simbox_plan.$plan.'.limit_hard.4',"10000");?>"></td>
		<!-- -->




<?
}
?>


<?
if($show_iatt==1)
{
?>

		<td style="border-left: 1px solid #cccccc"><input type="text" name="iatt_soft[<?=$plan?>]" size=2 value="<?=file_get_contents_def($path_simbox_plan.$plan.'.iatt_soft',"1");?>"></td>
		<td><input type="text" name="iatt_min[<?=$plan?>]" size=2 value="<?=file_get_contents_def($path_simbox_plan.$plan.'.iatt_min',"5");?>"></td>
		<td><input type="text" name="iatt_max[<?=$plan?>]" size=2 value="<?=file_get_contents_def($path_simbox_plan.$plan.'.iatt_max',"15");?>"></td>
		<td><input type="text" name="out_in_ans[<?=$plan?>]" size=2 value="<?=file_get_contents_def($path_simbox_plan.$plan.'.out_in_ans',"6");?>"></td>
		<td><input type="text" name="out_in_dur[<?=$plan?>]" size=2 value="<?=file_get_contents_def($path_simbox_plan.$plan.'.out_in_dur',"4");?>"></td>
		<td style="border-left: 1px dashed #cccccc"><input type="text" name="in_acd_min[<?=$plan?>]" size=2 value="<?=file_get_contents_def($path_simbox_plan.$plan.'.in_acd_min',"60");?>"></td>
		<td><input type="text" name="in_acd_max[<?=$plan?>]" size=2 value="<?=file_get_contents_def($path_simbox_plan.$plan.'.in_acd_max',"180");?>"></td>
		<td style="border-left: 1px dashed #cccccc"><input type="text" name="out_acd_min[<?=$plan?>]" size=2 value="<?=file_get_contents_def($path_simbox_plan.$plan.'.out_acd_min',"60");?>"></td>
		<td><input type="text" name="out_acd_max[<?=$plan?>]" size=2 value="<?=file_get_contents_def($path_simbox_plan.$plan.'.out_acd_max',"180");?>"></td>

		<td style="border-left: 1px dashed #cccccc">
		<input type="hidden" name="forwarding[<?=$plan;?>]" value=0>
		<input type="checkbox" name="forwarding[<?=$plan;?>]" value=1 <?if(file_get_contents_def($path_simbox_plan.$plan.'.forwarding','1')==1)echo 'checked';?>>
		</td>

		<td>
		<input type="hidden" name="outin[<?=$plan;?>]" value=0>
		<input type="checkbox" name="outin[<?=$plan;?>]" value=1 <?if(file_get_contents_def($path_simbox_plan.$plan.'.outin','1')==1)echo 'checked';?>>
		</td>

		<td>
		<input type="hidden" name="conn[<?=$plan;?>]" value=0>
		<input type="checkbox" name="conn[<?=$plan;?>]" value=1 <?if(file_get_contents_def($path_simbox_plan.$plan.'.conn','1')==1)echo 'checked';?>>
		</td>

		<td>
		<input type="hidden" name="rand[<?=$plan;?>]" value=0>
		<input type="checkbox" name="rand[<?=$plan;?>]" value=1 <?if(file_get_contents_def($path_simbox_plan.$plan.'.rand','1')==1)echo 'checked';?>>
		</td>


		<td>
		<input type="hidden" name="in_wait[<?=$plan;?>]" value=0>
		<input type="checkbox" name="in_wait[<?=$plan;?>]" value=1 <?if(file_get_contents_def($path_simbox_plan.$plan.'.in_wait','0')==1)echo 'checked';?>>
		</td>

		<td>
		<input type="hidden" name="in_sound[<?=$plan;?>]" value=0>
		<input type="checkbox" name="in_sound[<?=$plan;?>]" value=1 <?if(file_get_contents_def($path_simbox_plan.$plan.'.in_sound','1')==1)echo 'checked';?>>
		</td>

<?
}
?>


<?
if($show_satt==1)
{
?>


		<td style="border-left: 1px solid #cccccc"><input type="text" name="may_limit[<?=$plan?>]" size=2 value="<?=file_get_contents_def($path_simbox_plan.$plan.'.may_limit',"5");?>"></td>
		<td><input type="text" name="mon_limit[<?=$plan?>]" size=2 value="<?=file_get_contents_def($path_simbox_plan.$plan.'.mon_limit',"2");?>"></td>
		<td><input type="text" name="msm_limit[<?=$plan?>]" size=2 value="<?=file_get_contents_def($path_simbox_plan.$plan.'.msm_limit',"1");?>"></td>

		<td><input type="text" name="smsout_soft[<?=$plan?>]" size=2 value="<?=file_get_contents_def($path_simbox_plan.$plan.'.smsout_soft',"0");?>"></td>
		<td><input type="text" name="smsout_hard[<?=$plan?>]" size=2 value="<?=file_get_contents_def($path_simbox_plan.$plan.'.smsout_hard',"1");?>"></td>

		<td>
		<input type="hidden" name="nospam[<?=$plan;?>]" value=2>
		<input type="checkbox" name="nospam[<?=$plan;?>]" value=1 <?if(file_get_contents_def($path_simbox_plan.$plan.'.nospam','1')==1)echo 'checked';?>>
		</td>

		<td><input type="text" name="satt_soft[<?=$plan?>]" size=2 value="<?=file_get_contents_def($path_simbox_plan.$plan.'.satt_soft',"10");?>"></td>

		<td><input type="text" name="satt_soft_day[<?=$plan?>]" size=2 value="<?=file_get_contents_def($path_simbox_plan.$plan.'.satt_soft_day',"10");?>"></td>
		<td><input type="text" name="satt_soft_total[<?=$plan?>]" size=2 value="<?=file_get_contents_def($path_simbox_plan.$plan.'.satt_soft_total',"100");?>"></td>

		<td><input type="text" name="satt_hard[<?=$plan?>]" size=2 value="<?=file_get_contents_def($path_simbox_plan.$plan.'.satt_hard',"50");?>"></td>
		<td><input type="text" name="satt_hard_day[<?=$plan?>]" size=2 value="<?=file_get_contents_def($path_simbox_plan.$plan.'.satt_hard_day',"3");?>"></td>
		<td><input type="text" name="satt_hard_total[<?=$plan?>]" size=2 value="<?=file_get_contents_def($path_simbox_plan.$plan.'.satt_hard_total',"20");?>"></td>


<?
}
?>


		
	</tr>
	<?
}
?>

</table>



<input type="submit" name="save" value="Сохранить">

<br><br>

<table>
<tr class="header">
<td>
Создать новый план
</td></tr><tr><td>
<?
$plan_name=@$_POST['plan_name'];
if(!$plan_name) $plan_name="noname";
?>
Создать план <input type="text" name="plan_name" value="<?=$plan_name?>"> для набора 

<select name="plan_nabor">
<?
$nabors=file('/usr/simbox/nabor/nabor.list');

foreach($nabors as $i2=>$v2){
$v2=trim($v2);
?>
<option value="<?=$v2;?>"  <?if(strcmp($v2,@$_POST['plan_nabor'])==0)echo 'selected';?> ><?=$v2;?></option>
<?}?>
</select>

<input type="submit" name="create_plan" value="Create plan"> <br><br>
</td></tr></table>

<br><br>
</form>

<a name="help"></a>

<table>
<tr class="header">
<td align=left>Пояснение</td>
</tr>

<tr>
<td align=left>
Планы нужны для 2 целей:<br>
1. Автоматизация хитрых запросов (например при парвильном плане можно вместо *100# нажать get Balance)<br>
2. Групповой установки параметров симок<br><br>
Вполне допустимо использовать план default для любых симок, экспериментов, разработки новых операторов
<br><br>
time_wake, time_sleep - когда симка засыпает, когда просыпается (номер часа). Минуты выбираются внутренним алгоритмом в заданном часе каждый день по разному для каждой симки.<br>
Пример: можно работать 9-18 (днем). Можно 18-9 (ночью)<br>
Если (time_wake не в [0;23] или time_sleep не в [0;23]) то выключено.<br>
<br><br>
Пауза между звонками<br>
diff_slow - гарантированная пауза, которую обязана выдерживать сммка перед следующим звонком в _любом_случае_<br>
diff_min - пауза на все<br>
diff_min_out - пауза на хорошие звонки<br>
diff_min_sout - пауза на звонки самому себе<br>
diff_min_imode - пауза на звонки с той же симки<br>
можно добится того  чтобы повысить количество хороших звонков, а если их нет - то уж брать остальные<br>
пауза на симку берется = min(diff_min; diff_min_imode если IMB или IMC; diff_min_out если GOO)
<br><br>
Например<br>
dif_min=500<br>
dif_min_out=20<br><br>
с 0 секунды до 20 звонки не принимаются<br><br>
20 до 500 - только хорошие<br><br>
500 - любой на котором есть галочка<br><br>
После того как изменения сделаны в плане - необходимо выбрать симки и нажать кнопочку "Восстановить параметры плана"
<br><br>

<b>Звонки сами-себе</b><br>
Для того чтобы на телефонный номер <u>пришел</u> звонок самому себе необходимо чтобы загорелся флажок в столбце IATT<br>
IATT - количество исходящих подряд<br>
IATT_SOFT -  если IATT меньше этого параметра то форвардинг звонков запрещен<br>
IATT_MIN -  если IATT меньше этого параметра то флажок не загорается, ничего дальше не проверяется<br>
IATT_MAX -  если IATT больше этого параметра то флажок загорается, ничего дальше не проверяется<br>
IATT_MIN-IATT_MAX, если IATT в этом промежутке, то проверяются следующие условия<br>
OUT_IN_ANS - планируемое отношение количества исходящих к входящим, если фактическое меньше указанного, флажок загорается<br>
OUT_IN_DUR - планируемое отношение длительности исходящих к входящим, если фактическое меньше указанного, флажок загорается<br>
IN_ACD_MIN-IN_ACD_MAX - планируемая средняя длительность входящего (расчитывается длина каждого входящего так, чтобы подогнать результирующую среднюю <u>всех звонков</u>(то есть изменить общую картиину, не только перезвонную за счет перезвонов) под эти параметры)<br>
OUT_ACD_MIN-OUT_ACD_MAX - планируемая средняя длительность  исходящего (расчитывается длина каждого так, чтобы подогнать результирующую среднюю <u>всех звонков</u>  под эти параметры)<br>

Примечание:
Звонки <u>исходят</u> из общей очереди, в соответствии с паузами diff_min_sout. Если поставить 0 - будут исходить с повышенным приоритетом, если поставить больше diff_min, то будут проходить только в период малой нагрузки.<br>
Важно контролировать паузы на модеме, на который совершается входящий. Если паузы на нем малы - он просто не успеет поймать входящий.<br>
IN_ACD_MIN-IN_ACD_MAX, OUT_ACD_MIN-OUT_ACD_MAX - некоторые показатели, которые задают ПРИМЕРНЫЕ данные, к которым система бкдет стремиться. Фактический результат может отличаться<br>

<br><br>

<b>SMS</b>
<!--
can_smsin - может принимать генерированные смс (сами себе)<br>
can_smsout - может отправлять генерированные смс (сами себе)<br>
can_smsoutworld - может отправлять смс во внешний мир<br>
-->
Флажок в столбце SATT - отправка SMS разрешена<br>
SATT - количество звонков после последней отправки SMS<br>
SATT_SOFT -  если SATT меньше этого параметра, то флажок не загорается, отправка SMS запрещена, иначе флажок загорается - отправка SMS разрешена<br>
SATT_HARD -  если SATT больше этого параметра, то делается принудительная отправка SMS<br>

<!--
SATT_MIN-SATT_MAX в этом промежутке горит флажок разрешения SMS, возможна отправка SMS для пересыла входящих СМС и т.д.<br>
-->

SATT_SOFT_DAY/TOTAL (в день/всего) - лимит по количеству, после этого порога не отправляются внутренние смс (сами себе, ни очем)<br>
SATT_HARD_DAY/TOTAL (в день/всего) - лимит по количеству,после этого порога не отправляются внешние смс (полезные для других пользователей)<br>



<br><br>
<b>Callback</b>
Звонки обратно<br>
Если сначала мы позвонили человеку (не важно дозвонились или нет), а потом челове звонит нам обратно - мы можем определить кто фактически звонил этому человеку и попытаться соединить его именно с ним.<br>
Так же можно отправить этому человеку SMS с фактическим номером того кто ему реально звонил(это одна из возможных полезных функций SMS)<br>
Данный функционал в разработке

<br><br>
<b>Направления</b><br>
1 - направление по умолчанию (2,3,4 используются для Билайна СПБ)<br>
limit_soft - пока не дошли до него, совершаются исходящие вызовы, при превышении звонок не обрывается.<br>
limit_hard - при превышении звонок обрывается.<br>
<br>
alg - алгоритмы нагрузки<br>
A (симки мегафон спб, направление мегафон спб) - limit_penalty=-10, IME=ON<br>
A (симки билайн спб, направление мтс,мег спб) - limit_penalty=-10, IME=ON<br>
B (симки билайн спб, направление би спб) - limit_penalty=-20, IME=ON<br>
X (симки ТЕЛЕ2, направление мтс спб, направление билайн спб) limit_penalty=-10. Мегафон - как? в два лимита с максимумом?<br>
Z (симки ТЕЛЕ2, направление теле2 спб) limit_penalty=-20<br>
a,b - Максимальный убой симки<br>
P - ЗАПРЕИТЬ не PRO, трафик от PRO не снимать фильры<br>
p - рпзрешить не PRO, трафик от PRO СНЯТЬ фильтры<br>
v - ЗАПРЕТИТЬ не PRO, трафик от PRO СНЯТЬ фильтры<br>

* - выбор случайным образом<br>
&gt; - по направлению (за день), сбалансированная нагрузка<br>
&lt; - по направлению (за день), нагрузка максимально нагруженного<br>
&gt;Q - по направлению (за день), сбалансированная нагрузка, брать в не зависимости от показателя качества (для звонков с одного на другово оператора, когда не боимся прозвона)<br>
D - кто дольше ждет<br>
_ - общая длительность (за все дни по всем направлениям), сбалансированная нагрузка<br>
^ - общая длительность (за все дни по всем направлениям), нагрузка максимально нагруженного<br>
<br>
<img src=imgs/state_wait.png> - использование паузы после конца вызова<br>
<!--
+ - всегда
- - никогда
G - Для все, кроме 
-->
</td>
</tr>
</table>

<br><br>

