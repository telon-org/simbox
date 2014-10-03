<?

		//exec_fon('chmod -R 0777 /var/simbox/');

		//exec_fon('chmod -R 0777 /var/svistok/');

		//exec_fon('/usr/sbin/asterisk -r -x "dongle update"');
		
		//exec_fon('/usr/simbox/system/parseussdsms.sh');

//print_r($_POST);

function fulltrim($t)
{
    $t1=str_replace(" ","",$t);
    return trim($t1);
}




if(isset($_POST['pon']))
{
$_POST['atcommandexec']=1;
$_POST['atcommand']='AT+CFUN=1;+CFUN=1,1;+CFUN?';
}

if(isset($_POST['poff']))
{
$_POST['atcommandexec']=1;
$_POST['atcommand']='AT+CFUN=5;+CFUN?';
}




if(isset($_POST['atcommandexec']))
{
?>
<table>
<tr class="header">
<td>
Результат AT
</td></tr><tr><td>
<?
	foreach($_POST['id'] as $v=>$imsi)
	{
        $dongle=file_get_contents($path_svistok_sim_state.$imsi.'.dongle');
        $atcommand=$_POST['atcommand'];
        $atcommand=str_replace('"','\"',$atcommand);
#       exec_s('/usr/simbox/actions/atcommand.sh '.$dongle.' noimsi "'.$atcommand.'"');
        $res=exec_delay("/usr/sbin/asterisk -rx 'dongle cmd $dongle $atcommand'");
        echo("<br><br>");
    }
?>
</td></tr></table>
<?
}



if(isset($_POST['setki']))
{
?>
<table>
<tr class="header">
<td>
Результат установки KI
</td></tr><tr><td><font face="courier" size="2">
<?


	$ok=0;
	foreach($_POST['id'] as $v=>$imsi)
	{
		if($ok==0)
		{
		    $dongle=file_get_contents($path_svistok_sim_state.$imsi.'.dongle');
		    $dat_ki=fulltrim($_POST['dat_ki']);
		    $dat_imsi=fulltrim($_POST['dat_imsi']);
		    $dat_iccid=fulltrim($_POST['dat_iccid']);
		    $dat_smsc=fulltrim($_POST['dat_smsc']);
		    $cmd='/usr/simbox/system/set_ki.php "9" "'.$dongle.'" "'.$dat_ki.'" "'.$dat_imsi.'" "'.$dat_iccid.'" "'.$dat_smsc.'"';
		    echo($cmd."<br>");
		    $res=exec_delay($cmd);
		    echo("<br><br>");
		    $ok=1;
		} else {
		    echo("<br><font color=red>Внимание!!! Не буду устанавливать одинакоый KI на несколько симок!!!</font>");
		}
	}
?>
</td></tr></table>
<?
}


if(isset($_POST['supersim_set']))
{
?>
<table>
<tr class="header">
<td>
Результат установки KI (supersim)
</td></tr><tr><td><font face="courier" size="2">
<?


	$ok=0;
	foreach($_POST['id'] as $v=>$imsi)
	{
		if($ok==0)
		{
		    $dongle=file_get_contents($path_svistok_sim_state.$imsi.'.dongle');
		    $supersim_ki=fulltrim($_POST['supersim_ki']);
		    $supersim_imsi=fulltrim($_POST['supersim_imsi']);
		    $supersim_iccid=fulltrim($_POST['supersim_iccid']);
		    $supersim_smsc=fulltrim($_POST['supersim_smsc']);
		    $cmd='/usr/simbox/system/set_ki.php "16"  "'.$dongle.'" "'.$supersim_ki.'" "'.$super_imsi.'" "'.$supersim_iccid.'" "'.$supersim_smsc.'"';
		    echo($cmd."<br>");
		    $res=exec_delay($cmd);
		    echo("<br><br>");
		    $ok=1;
		} else {
		    echo("<br><font color=red>Внимание!!! Не буду устанавливать одинакоый KI на несколько симок!!!</font>");
		}
	}
?>
</td></tr></table>
<?
}


if(isset($_POST['newki']))
{
?>
<table>
<tr class="header">
<td>
Результат установки KI (авторежим)
</td></tr><tr><td><font face="courier" size="2">
<?


	foreach($_POST['id'] as $v=>$imsi)
	{
		    $dongle=file_get_contents($path_svistok_sim_state.$imsi.'.dongle');
		    $cmd='/usr/simbox/system/new_ki.php "9" "'.$dongle.'" "'.$_POST['ki_owner'].'"';
		    echo($cmd."<br>");
		    $res=exec_delay($cmd);
		    echo("<br><br>");
	}
?>
</td></tr></table>
<?
}


if(isset($_POST['supersim_new']))
{
?>
<table>
<tr class="header">
<td>
Результат установки KI (авторежим)
</td></tr><tr><td><font face="courier" size="2">
<?


	foreach($_POST['id'] as $v=>$imsi)
	{
		    $dongle=file_get_contents($path_svistok_sim_state.$imsi.'.dongle');
		    $cmd='/usr/simbox/system/new_ki.php "16" "'.$dongle.'" "'.$_POST['supersim_ki_owner'].'"';
		    echo($cmd."<br>");
		    $res=exec_delay($cmd);
		    echo("<br><br>");
	}
?>
</td></tr></table>
<?
}


if(isset($_POST['rotki']))
{
?>
<table>
<tr class="header">
<td>
Результат запуска ротатора
</td></tr><tr><td><font face="courier" size="2">
<?


	foreach($_POST['id'] as $v=>$imsi)
	{
		if($_POST['rot_owner']>0)
	        {
		    $dongle=file_get_contents($path_svistok_sim_state.$imsi.'.dongle');
		    $cmd='/usr/simbox/system/rot_ki.php "'.$dongle.'" "'.$_POST['rot_owner'].'"  "'.$_POST['rot_ki'].'"  "'.$_POST['rot_lo'].'" > /tmp/'.$dongle.'.rotator';
		    echo($cmd."<br>");
		    $res=exec_delay($cmd);
		    echo("<br><br>");
		}
	}
?>
</td></tr></table>
<?
}


if(isset($_POST['smsspam']))
{
?>
<table>
<tr class="header">
<td>
Запуск SMS рассылки
</td></tr><tr><td><font face="courier" size="2">
<?


	foreach($_POST['id'] as $v=>$imsi)
	{
		    $dongle=file_get_contents($path_svistok_sim_state.$imsi.'.dongle');
		    $cmd='sudo /usr/simbox/system/fullsms.php "'.$imsi.'" > /tmp/'.$dongle.'.smsspam &';
		    $res=exec_br($cmd);
	}
?>
</td></tr></table>
<?
}



if(isset($_POST['donglerestart']))
{
?>
<table>
<tr class="header">
<td>
Перезапуск свистка
</td></tr><tr><td>
<font face="courier" size="2">
<?
	foreach($_POST['id'] as $v=>$imsi)
	{
		$dongle=file_get_contents_def2($path_svistok_sim_state.$imsi.'.dongle',"");
        //$ussd=$_POST['ussdcommand'];
        $cmd='/usr/simbox/actions/donglerestart.sh '.$dongle.' noimsi';
        echo($cmd."<br>");
        $res=exec_delay($cmd);
        echo("<br><br>");
    }
?>
</td></tr></table>
<?
}


if(isset($_POST['donglerestartcfun']))
{
?>
<table>
<tr class="header">
<td>
Перезапуск свистка (CFUN)
</td></tr><tr><td>
<font face="courier" size="2">
<?
	foreach($_POST['id'] as $v=>$imsi)
	{
		$dongle=file_get_contents_def2($path_svistok_sim_state.$imsi.'.dongle',"");
        //$ussd=$_POST['ussdcommand'];
        $cmd='/usr/simbox/actions/donglerestartcfun.sh '.$dongle.' noimsi';
        echo($cmd."<br>");
        $res=exec_delay($cmd);
        echo("<br><br>");
    }
?>
</td></tr></table>
<?
}




if(isset($_POST['blackimei'])){
	foreach($_POST['id'] as $v=>$imsi)
	{
		$dongle=file_get_contents_def2($path_svistok_sim_state.$imsi.'.dongle',"");
		$imei=trim(file_get_contents($path_svistok_dongles_state.$dongle.'.imei'));
		file_put_contents($path_svistok_dongles.'imei.black',$imei."\n", FILE_APPEND | LOCK_EX);
	}



}




if(isset($_POST['export_numbers']))
{
?>
<table>
<tr class="header">
<td>
Экспорт номеров
</td></tr><tr><td><font face="courier" size="2">
<?
	foreach($_POST['id'] as $v=>$imsi)
	{
		$number=file_get_contents_def2($path_simbox_sim_settings.$imsi.'.number',"");
		echo($number."<br>");
	}
?>
</td></tr></table>
<?
}


if(isset($_POST['export_masspayment']))
{
?>
<table>
<tr class="header">
<td>
Экспорт номеров
</td></tr><tr><td><font face="courier" size="2">
<?
	$needbalance=$_POST['export_masspayment_balance'];
	$needbalance_minimum=$_POST['export_masspayment_balance_minimum'];
	$needbalance_maximum=$_POST['export_masspayment_balance_maximum'];
$cnt=0;
	$pay_html="";
	$notpay_html="";


	foreach($_POST['id'] as $v=>$imsi)
	{
		$cnt++;
		$plan=file_get_contents_def2($path_simbox_sim_settings.$imsi.'.plan', 'default');
		$number_f=file_get_contents_def2($path_simbox_sim_settings.$imsi.'.number',"");
		$nabor=file_get_contents_def($path_simbox_plan.$plan.'.nabor',"default");;

		$balance=file_get_contents_def2($path_simbox_sim_statistics.$imsi.'.balance',"0");


		$topay=10;
		$opid="0";
		$number=$number_f;

		if($nabor=="beeline_spb")
		{
		    $opid=2;
		    $number=substr($number,1);
		    $topay=$needbalance-$balance;
		}

		if($nabor=="tele2_spb")
		{
		    $opid=31;
		    $number=substr($number,1);
		    $topay=$needbalance-$balance;
		}


		if($nabor=="megafon_spb")
		{
		    $opid=10;
		    $number=substr($number,1);
		    $topay=$needbalance-$balance;
		}

		if($nabor=="megafon_mks")
		{
		    $opid=3;
		    $number=substr($number,1);
		    $topay=$needbalance-$balance;
		}


		if($nabor=="life")
		{
		    $opid=623;
		    $number=substr($number,3);
		    $topay=$needbalance-($balance/252);
		}

		if($nabor=="velcom")
		{
		    $opid=621;
		    $number=substr($number,3);
		    $topay=$needbalance-($balance/252);
		}

		$topay=(int)($topay+.99);

		if ($number=="")
		{
			$notpay_html=$notpay_html."НЕ ОПРЕДЕЛЕН;".$opid.";".$topay.";WMR;".$cnt."<br>";
		}
		else
		if($topay<0)
		{
		    $topay=0;
			$notpay_html=$notpay_html.$number.";".$opid.";".$topay.";WMR;".$cnt."<br>";
		} else
		{


			if($topay<$needbalance_minimum) {$topay=$needbalance_minimum; $pay_html=$pay_html."<font color=blue>".$number.";".$opid.";".$topay.";WMR;".$cnt."</font><br>";}
			    else
			if($topay>$needbalance_maximum) {$topay=$needbalance_maximum; $pay_html=$pay_html."<font color=blue>".$number.";".$opid.";".$topay.";WMR;".$cnt."</font><br>";}
			    else
			$pay_html=$pay_html.$number.";".$opid.";".$topay.";WMR;".$cnt."<br>";
		}


	}

		echo($pay_html);
		echo("<br><font color=red>");
		echo($notpay_html);
		echo("</font>");
?>
</td></tr></table>
<?
}


if(isset($_POST['export_dongles']))
{
?>
<table>
<tr class="header">
<td>
Экспорт свистков
</td></tr><tr><td><font face="courier" size="2">
<?
	foreach($_POST['id'] as $v=>$imsi)
	{
		$dongle=file_get_contents_def2($path_svistok_sim_state.$imsi.'.dongle',"");
		echo($dongle."<br>");
	}
?>
</td></tr></table>
<?
}


if(isset($_POST['changeimei']))
{
?>
<table>
<tr class="header">
<td>
Смена IMEI
</td></tr><tr><td>
<font face="courier" size="2">
<?
    foreach($_POST['id'] as $v=>$imsi)
    {
	$dongle=file_get_contents($path_svistok_sim_state.$imsi.'.dongle');
       $cmd='/usr/simbox/actions/changeimei.php '.$dongle.' noimsi';
       echo($cmd."<br>");
       $res=exec_delay($cmd);
       echo("<br><br>");
    }
?>
</td></tr></table>

<?
}


if(isset($_POST['diagmode']))
{
?>
<table>
<tr class="header">
<td>
Запуск перепрошивки
</td></tr><tr><td>
<font face="courier" size="3" color="red">
Внимание!!! Запуск перепрошивки начнется только после вынимания SIM Карты<br><br>
</font>
<font face="courier" size="2">
<?
	foreach($_POST['id'] as $v=>$imsi)
	{
		$dongle=file_get_contents($path_svistok_sim_state.$imsi.'.dongle');
		//$ussd=$_POST['ussdcommand'];
		$cmd='/usr/simbox/actions/diagmode.sh '.$dongle.' '.$imsi.'';

		echo($cmd."<br>");
		$res=exec_delay($cmd);
		echo("<br><br>");
	}
?>
</td></tr></table>
<?
}



if(isset($_POST['activate_sim']))
{
?>
<table>
<tr class="header">
<td>
Результат хитрой активации sim
</td></tr><tr><td><font face="courier" size="2">
<?
	foreach($_POST['id'] as $v=>$imsi)
	{
		$dongle=file_get_contents($path_svistok_sim_state.$imsi.'.dongle');
		//$ussd=$_POST['ussdcommand'];
		$cmd='/usr/simbox/actions/activate_sim.sh '.$dongle.' '.$imsi.'';
		echo($cmd."<br>");
		$res=exec_delay($cmd);
		echo("<br><br>");
	}
?>
</td></tr></table>
<?
}

if(isset($_POST['activate_work']))
{
?>
<table>
<tr class="header">
<td>
Результат хитрой активации work
</td></tr><tr><td><font face="courier" size="2">
<?
	foreach($_POST['id'] as $v=>$imsi)
	{
		$dongle=file_get_contents($path_svistok_sim_state.$imsi.'.dongle');
		//$ussd=$_POST['ussdcommand'];
		$cmd='/usr/simbox/actions/activate_work.sh '.$dongle.' '.$imsi.'';
		echo($cmd."<br>");
		$res=exec_delay($cmd);
		echo("<br><br>");
	}
?>
</td></tr></table>
<?
}




if(isset($_POST['get_number']))
{
?>
<table>
<tr class="header">
<td>
Результат хитрого получения номера
</td></tr><tr><td><font face="courier" size="2">
<?
	foreach($_POST['id'] as $v=>$imsi)
	{
		$dongle=file_get_contents($path_svistok_sim_state.$imsi.'.dongle');
		//$ussd=$_POST['ussdcommand'];
		$cmd='/usr/simbox/actions/get_number.sh '.$dongle.' '.$imsi.'';
		echo($cmd."<br>");
		$res=exec_delay($cmd);
		echo("<br><br>");
	}
?>
</td></tr></table>
<?
}


if(isset($_POST['get_minutes']))
{
?>
<table>
<tr class="header">
<td>
Результат хитрого получения минут
</td></tr><tr><td><font face="courier" size="2">
<?
	foreach($_POST['id'] as $v=>$imsi)
	{
		$dongle=file_get_contents($path_svistok_sim_state.$imsi.'.dongle');
		//$ussd=$_POST['ussdcommand'];
		$cmd='/usr/simbox/actions/get_minutes.sh '.$dongle.' '.$imsi.'';
		echo($cmd."<br>");
		$res=exec_delay($cmd);
		echo("<br><br>");
	}
?>
</td></tr></table>
<?
}

if(isset($_POST['get_tarif']))
{
?>
<table>
<tr class="header">
<td>
Результат хитрого получения тарифа
</td></tr><tr><td><font face="courier" size="2">
<?
	foreach($_POST['id'] as $v=>$imsi)
	{
		$dongle=file_get_contents($path_svistok_sim_state.$imsi.'.dongle');
		//$ussd=$_POST['ussdcommand'];
		$cmd='/usr/simbox/actions/get_tarif.sh '.$dongle.' '.$imsi.'';
		echo($cmd."<br>");
		$res=exec_delay($cmd);
		echo("<br><br>");
	}
?>
</td></tr></table>
<?
}



if(isset($_POST['get_balance']))
{
?>
<table>
<tr class="header">
<td>
Результат хитрого запроса баланса
</td></tr><tr><td><font face="courier" size="2">
<?
	foreach($_POST['id'] as $v=>$imsi)
	{
		$dongle=file_get_contents($path_svistok_sim_state.$imsi.'.dongle');
		//$ussd=$_POST['ussdcommand'];
		$cmd='/usr/simbox/actions/get_balance.sh '.$dongle.' '.$imsi.'';
		echo($cmd."<br>");
		$res=exec_delay($cmd);
		echo("<br><br>");
	}
?>
</td></tr></table>
<?
}

if(isset($_POST['get_dover']))
{
?>
<table>
<tr class="header">
<td>
Результат подключения доверительного платежа
</td></tr><tr><td><font face="courier" size="2">
<?
	foreach($_POST['id'] as $v=>$imsi)
	{
		$dongle=file_get_contents($path_svistok_sim_state.$imsi.'.dongle');
		//$ussd=$_POST['ussdcommand'];
		$cmd='/usr/simbox/actions/get_dover.sh '.$dongle.' '.$imsi.'';
		echo($cmd."<br>");
		$res=exec_delay($cmd);
		echo("<br><br>");
	}
?>
</td></tr></table>
<?
}


if(isset($_POST['get_options']))
{
?>
<table>
<tr class="header">
<td>
Результат подключения опций
</td></tr><tr><td><font face="courier" size="2">
<?
	foreach($_POST['id'] as $v=>$imsi)
	{
		$dongle=file_get_contents($path_svistok_sim_state.$imsi.'.dongle');
		//$ussd=$_POST['ussdcommand'];
		$cmd='/usr/simbox/actions/get_options.sh '.$dongle.' '.$imsi.'';
		echo($cmd."<br>");
		$res=exec_delay($cmd);
		echo("<br><br>");
	}
?>
</td></tr></table>
<?
}




if(isset($_POST['complex_prepare']))
{
?>
<table>
<tr class="header">
<td>
Результат хитрой комплексной подготовки
</td></tr><tr><td><font face="courier" size="2">
<?
	foreach($_POST['id'] as $v=>$imsi)
	{
		$rnd1=rand()%160+20;
		$rnd2=rand()%160+20;
		$rnd3=rand()%160+20;
		$dongle=file_get_contents($path_svistok_sim_state.$imsi.'.dongle');
		$cmd='/usr/simbox/actions/complex_prepare.sh '.$dongle.' '.$imsi." $rnd1 $rnd2 $rnd3";
		echo($cmd."<br>");
		$res=exec_delay($cmd);
		echo("<br><br>");
	}
?>
</td></tr></table>
<?
}

if(isset($_POST['complex_prepare2']))
{
?>
<table>
<tr class="header">
<td>
Результат хитрой комплексной подготовки
</td></tr><tr><td><font face="courier" size="2">
<?
	foreach($_POST['id'] as $v=>$imsi)
	{
		$rnd1=rand()%160+20;
		$rnd2=rand()%160+20;
		$rnd3=rand()%160+20;
		$dongle=file_get_contents($path_svistok_sim_state.$imsi.'.dongle');
		$cmd='/usr/simbox/actions/complex_prepare2.sh '.$dongle.' '.$imsi." $rnd1 $rnd2 $rnd3";
		echo($cmd."<br>");
		$res=exec_delay($cmd);
		echo("<br><br>");
	}
?>
</td></tr></table>
<?
}










if(isset($_POST['set_autoblock_null']))
{
?>
<table>
<tr class="header">
<td>
Результат снятия флажков
</td></tr><tr><td><font face="courier" size="2">
<?
	foreach($_POST['id'] as $v=>$imsi)
	{
		$dongle=file_get_contents($path_svistok_sim_state.$imsi.'.dongle');
		$cmd='/usr/simbox/actions/set_autoblock_null.sh '.$dongle.' '.$imsi;
		echo($cmd."<br>");
		$res=exec_s($cmd);
		echo("<br><br>");
		

	}
?>
</td></tr></table>
<?
}


if(isset($_POST['set_plan']))
{
?>
<table>
<tr class="header">
<td>
Результат хитрой установки плана
</td></tr><tr><td><font face="courier" size="2">
<?
	foreach($_POST['id'] as $v=>$imsi)
	{
		$dongle=file_get_contents($path_svistok_sim_state.$imsi.'.dongle');
		$set_plan_select=$_POST['set_plan_select'];
		$cmd='/usr/simbox/actions/set_plan.sh '.$dongle.' '.$imsi.' '.$set_plan_select;
		echo($cmd."<br>");
		$res=exec_s($cmd);
		echo("<br><br>");

	}
?>
</td></tr></table>
<?
}



if(isset($_POST['set_plan_set']))
{
?>
<table>
<tr class="header">
<td>
Результат хитрой установки плана
</td></tr><tr><td><font face="courier" size="2">
<?
	foreach($_POST['id'] as $v=>$imsi)
	{
		$dongle=file_get_contents($path_svistok_sim_state.$imsi.'.dongle');
		$set_plan_select=$_POST['set_plan_select'];
		$cmd='/usr/simbox/actions/set_plan_set.sh '.$dongle.' '.$imsi.' '.$set_plan_select;
		echo($cmd."<br>");
		$res=exec_s($cmd);
		echo("<br><br>");
	}
?>
</td></tr></table>
<?
}


if(isset($_POST['set_plan_copy']))
{
?>
<table>
<tr class="header">
<td>
Результат хитрой установки плана
</td></tr><tr><td><font face="courier" size="2">
<?
	foreach($_POST['id'] as $v=>$imsi)
	{
		$dongle=file_get_contents($path_svistok_sim_state.$imsi.'.dongle');
		$set_plan_select=$_POST['set_plan_select'];
		$cmd='/usr/simbox/actions/set_plan_copy.sh '.$dongle.' '.$imsi.' '.$set_plan_select;
		echo($cmd."<br>");
		$res=exec_s($cmd);
		echo("<br><br>");
	}
?>
</td></tr></table>
<?
}



if(isset($_POST['sendussd']))
{
?>
<table>
<tr class="header">
<td>
Результат USSD запроса
</td></tr><tr><td><font face="courier" size="2">
<?
	foreach($_POST['id'] as $v=>$imsi)
	{
		$dongle=file_get_contents($path_svistok_sim_state.$imsi.'.dongle');
		$ussd=$_POST['ussdcommand'];
		//$cmd='/usr/sbin/asterisk -r -x "dongle ussd '.$dongle.' '.$ussd.'"';
		$cmd='/usr/simbox/system/send.sh "ussd" "LOC" "'.$dongle.'" "'.$ussd.'" ""';
		echo($cmd."<br>");
		$res=exec_delay($cmd);
		echo("<br><br>");
	}
?>
</td></tr></table>
<?
}


if(isset($_POST['sendsms']))
{
?>
<table>
<tr class="header">
<td>
Результат отправки SMS
</td></tr><tr><td><font face="courier" size="2">
<?
	foreach($_POST['id'] as $v=>$imsi)
	{
		$dongle=file_get_contents($path_svistok_sim_state.$imsi.'.dongle');

		$smsnumber=$_POST['smsnumber'];
		$smstext=$_POST['smstext'];

//echo("smsnumber=$smsnumber");
		$cmd='/usr/simbox/system/send.sh "sms" "LOC" "'.$dongle.'" "'.$smsnumber.'" "'.$smstext.'"';
		//$cmd='/usr/sbin/asterisk -r -x "dongle sms '.$dongle.' '.$smsnumber.' '.$smstext.'"';
		echo($cmd."<br>");
		$res=exec_delay($cmd);
		echo("<br><br>");
	}
?>
</td></tr></table>
<?
}





if(isset($_POST['setgroup']))
{
?>
<table>
<tr class="header">
<td>
Результат установки группы
</td></tr><tr><td><font face="courier" size="2">
<?
	foreach($_POST['id'] as $v=>$imsi)
	{
//		$dongle=file_get_contents($path_svistok_sim_state.$imsi.'.dongle');
		$group=$_POST['setgroupnumber'];
		$cmd='/usr/sbin/asterisk -r -x "dongle setgroupimsi '.$imsi.' '.$group.'"';
		echo($cmd."<br>");
		$res=exec_s($cmd);
		echo("<br><br>");
		

	}
?>
</td></tr></table>
<?
}


if(isset($_POST['calldtmf']))
{
?>
<table>
<tr class="header">
<td>
Результат звонка DTMF
</td></tr><tr><td><font face="courier" size="2">
<?
	foreach($_POST['id'] as $v=>$imsi)
	{
		$dongle=file_get_contents($path_svistok_sim_state.$imsi.'.dongle');
		$number=$_POST['calldtmfnumber'];
		$nabor=$_POST['calldtmfnabor'];
		$cmd='/usr/simbox/system/makecalldtmf.sh '.$dongle.' '.$number.' '.$nabor;
		echo($cmd."<br>");
		$res=exec_delay($cmd);
		echo("<br><br>");
	}
?>
</td></tr></table>
<?
}



if(isset($_POST['call60']))
{
?>
<table>
<tr class="header">
<td>
Результат звонка 60 сек
</td></tr><tr><td><font face="courier" size="2">
<?
	foreach($_POST['id'] as $v=>$imsi)
	{
		$dongle=file_get_contents($path_svistok_sim_state.$imsi.'.dongle');
		$number=$_POST['call60number'];
		$cmd='/usr/simbox/system/makecall60.sh '.$dongle.' '.$number;
		echo($cmd."<br>");
		$res=exec_delay($cmd);
		echo("<br><br>");
	}
?>
</td></tr></table>
<?
}

if(isset($_POST['callspeak']))
{
?>
<table>
<tr class="header">
<td>
Результат звонка с разговором
</td></tr><tr><td><font face="courier" size="2">
<?
	foreach($_POST['id'] as $v=>$imsi)
	{
		$dongle=file_get_contents($path_svistok_sim_state.$imsi.'.dongle');
		$number=$_POST['callspeaknumber'];
		$cmd='/usr/simbox/system/makecallsebe_t.sh '.$dongle.' '.$number;
		echo($cmd."<br>");
		$res=exec_delay($cmd);
		echo("<br><br>");
	}
?>
</td></tr></table>
<?
}


if(isset($_POST['save'])){




//print_r($_POST['items']);

	foreach($_POST['items'] as $v=>$imsi){

		$path=$path0.'/sim/'.$imsi;
	

		//file_put_contents($path.'.active',$v);
//		file_put_contents($path_simbox_sim_settings.$imsi.'.plan',$_POST['plan'][$imsi]);

		file_put_contents($path_svistok_sim_settings.$imsi.'.priority',$_POST['priority'][$imsi]);
		file_put_contents($path_svistok_sim_limits.$imsi.'.limit_max.1',$_POST['limit_max1'][$imsi]);
		file_put_contents($path_svistok_sim_limits.$imsi.'.limit_max.2',$_POST['limit_max2'][$imsi]);
		file_put_contents($path_svistok_sim_limits.$imsi.'.limit_max.3',$_POST['limit_max3'][$imsi]);
		file_put_contents($path_svistok_sim_limits.$imsi.'.limit_max.4',$_POST['limit_max4'][$imsi]);
		file_put_contents($path_svistok_sim_limits.$imsi.'.limit_max.5',$_POST['limit_max5'][$imsi]);


		file_put_contents($path_svistok_sim_settings.$imsi.'.diff_min',$_POST['diff_min'][$imsi]);
		file_put_contents($path_svistok_sim_settings.$imsi.'.diff_min_out',$_POST['diff_min_out'][$imsi]);
		file_put_contents($path_svistok_sim_settings.$imsi.'.diff_min_sout',$_POST['diff_min_sout'][$imsi]);

		file_put_contents($path_svistok_sim_limits.$imsi.'.start_time',$_POST['start_time'][$imsi]);
		file_put_contents($path_svistok_sim_limits.$imsi.'.end_time',$_POST['end_time'][$imsi]);
		
		
		file_put_contents($path_svistok_sim_settings.$imsi.'.can_in',$_POST['can_in'][$imsi]);
		file_put_contents($path_svistok_sim_settings.$imsi.'.can_out',$_POST['can_out'][$imsi]);
		file_put_contents($path_svistok_sim_settings.$imsi.'.can_sout',$_POST['can_sout'][$imsi]);
		
		file_put_contents($path_svistok_sim_settings.$imsi.'.igoo',$_POST['igoo'][$imsi]);
		file_put_contents($path_svistok_sim_settings.$imsi.'.ibad',$_POST['ibad'][$imsi]);
		file_put_contents($path_svistok_sim_settings.$imsi.'.inor',$_POST['inor'][$imsi]);
		file_put_contents($path_svistok_sim_settings.$imsi.'.inew',$_POST['inew'][$imsi]);
		file_put_contents($path_svistok_sim_settings.$imsi.'.inos',$_POST['inos'][$imsi]);
		file_put_contents($path_svistok_sim_settings.$imsi.'.i_mode',$_POST['i_mode'][$imsi]);
		
//echo($path_svistok_sim_limits.$imsi.'.diff_min');
	}


		exec_fon('/usr/sbin/asterisk -r -x "dongle update"');

}

?>
<body>

<h1>Симки</h1>

Select фильтр по тарифу

<!--Фильтр по Блокированным, Активным, С отриц. Балансом-->

<?
/*
<script type='text/javascript'>
jQuery(function(){
$(function(){
$('.tooltip_file').each(function(){
  var elem = $(this);
  var local_path=elem.attr('data-local');
  $.get('//showlog_cut.php',{PATH:local_path},function(data){
    elem.attr('title',data);
  });
});
$('.tooltip_file').tooltip();
});
});
</script>
*/
?>

<form method="post">
<table>
<tr class="header">
<td><input type="checkbox" name="idall" value='all' onClick="SelAll(this)"></td>

<td>group</td>
<td><font size="1">pro</td> 
<td><font size="1">cap</td> 
<td><font size="1">im</td> 
<td><font size="1">spec</td> 
<td>state</td> 
<td></td> 
<td>plan<br><font size=1>nabor<br>tarif</td>
<td>number</td>
<td width="70">operator<br><font size=2>sim</font></td>
<td>balance<br>bal_diff</td> 

<td></td>
<td></td>
<td>dongle</td>

<td></td> 
<td>tot<br>
			<font size=2 color="#cccccc">
			IMB/C<br>
			IMN/D/E<br>

</td>
<td bgcolor="#ccccff">a-o<br>a-i</td>
<td bgcolor="#ccccff">m-o<br>m-i</td>
<td bgcolor="#ccccff">ACD-o</td>
<td bgcolor="#ddddff">ACD-i</td>
<td><font size=2>ACDL</font></td>                   
<td><font size=2>DATT</font></td>                   
<td><font size=2>IATT</font></td>                   
<td><font size=2>SATT</font></td>                   
<td><img src="imgs/sms_out.png"><br><font size=1>_sended</font></td>                   
<td><font size=2>ASRL</font></td>                   
<td>PDDAS</td>                   
<td>PDDL0</td>                   
<td>PDDL1</td>                   
<td>pri</td>                     
<td>LIMIT0</td>                  
<td>LIMIT1</td>                  
<td>LIMIT2</td>                  
<td>LIMIT3</td>                  
<td>LIMIT4</td>                  
<td>LIMIT5</td>                 

<!--
<td><img src=imgs/state_wait.png><img src=imgs/inew.png><br><font size=2 color=#cccccc>diff_min</td>
<td><img src=imgs/state_wait.png><img src=imgs/igoo.png><img src=imgs/inor.png><br><font size=2 color=#cccccc>diff_min_out</td>
<td><img src=imgs/state_wait.png><img src=imgs/state_sout.png><br><font size=2 color=#cccccc>diff_min_sout</td>
<td><img src=imgs/state_wait.png><img src=imgs/imb.png><img src=imgs/imc.png><br><font size=2 color=#cccccc>diff_min_imode</td>

<td>start time</td>              
<td>end time</td>                
-->

<!--
<td><img src=imgs/state_in.png alt="can in"></td>                 
<td><img src=imgs/state_out.png alt="can out"></td>                 
<td><img src=imgs/state_sout.png alt="can out"></td>                
<td><img src=imgs/igoo.png alt=iGOO></td>                     
<td><img src=imgs/inor.png alt=iNOR></td>                    
<td><img src=imgs/ibad.png alt=iBAD></td>                    
<td><img src=imgs/inew.png alt=iNEW></td>                     
<td><img src=imgs/inos.png alt=iNOS></td>                     
<td><img src=imgs/imode.png alt=iM></td>                    
-->
<td>LAC</td>                    
<td>CELL</td>                    
<td>IMEI</td>                   
<td>IMSI</td> 
<td>log
</td>
<td>
<font size=1>
когда засунут<br>
когда первый звонок<br>
когда последний успешный звонок<br>
когда сработала автоблокировка<br>
</td>


</tr>

<?





$data=file($path_svistok.'/lists/imsi.list');
$imsilist=array();

foreach($data as $i=>$imsi)
{
$imsi=trim($imsi);
$dongle=file_get_contents($path_svistok_sim_state.$imsi.'.dongle');
//$imsilist[$imsi]=$dongle;
$imsilist[$dongle]=$imsi;
}

ksort($imsilist);
//asort($imsilist);




/*
$data=file($path_svistok.'/lists/dongles.list');
$imsilist=array();

foreach($data as $i=>$dongle)
{
$dongle=trim($dongle);
$imsi=file_get_contents($path_svistok_dongles_state.$dongle.'.imsi');
//$imsilist[$imsi]=$dongle;
$imsilist[$dongle]=$imsi;
}
ksort($imsilist);
*/


//print_r($imsilist);

$plans=file($path_simbox.'/plan/plan.list');
$cnt=0;

$filter_group=@$_POST['filter_group'];
$filter_group_not=@$_POST['filter_group_not'];
$filter_plan=@$_POST['filter_plan'];
$filter_plan_no=@$_POST['filter_plan_no'];

//$filter_0xx=(@$_POST['0xx']==2);

//$filter_xx=

$filter_xx=(1==1);

//foreach($imsilist as $imsi=>$dongle){
foreach($imsilist as $dongle=>$imsi){

//foreach($data as $i=>$v){

$imsi=trim($imsi);
$dongle=trim($dongle);

$group=file_get_contents($path_svistok_sim_settings.$imsi.'.group');
$plan=file_get_contents_def2($path_simbox_sim_settings.$imsi.'.plan', 'default');


flush();


if (((($filter_group=="")||($filter_group==$group)) && (($filter_group_not=="")||($filter_group_not!=$group)) && (($filter_plan=="")||($filter_plan==$plan)) && (($filter_plan_no=="")||($filter_plan_no!=$plan))) && $filter_xx)

{
		$cnt++;
		
		//$path=$path_svistok_sim.$imsi;
		//$/paths=$path_svistok.'/sim/settings/'.$imsi;

		//$dongle=file_get_contents($path_svistok_sim_state.$imsi.'.dongle');
		$dongle_a="";
		$imei=trim(file_get_contents($path_svistok_dongles_state.$dongle.'.imei'));


		if (substr($dongle,0,7)=="dongle0")
		{
		    $dongle_a=file_get_contents_def2($path_svistok_dongles."/statistics".$imei.'.imei_name',"???");
		    $dongle_a="<font size=1>".$dongle_a."</font>";
		}
		

        $model=@file_get_contents($path_svistok_dongles_state.$dongle.'.model');
        $cfun=@file_get_contents($path_svistok_dongles_state.$dongle.'.cfun');

        $simst=trim(@file_get_contents($path_svistok_dongles_state.$dongle.'.simst'));
        $srvst=trim(@file_get_contents($path_svistok_dongles_state.$dongle.'.srvst'));
        $pinrequired=trim(@file_get_contents($path_svistok_dongles_state.$dongle.'.pinrequired'));


		
		if(substr_count(file_get_contents($path_svistok_dongles.'imei.black'),$imei)) $imei='<b style="color:red;">'.$imei.'</b>';
	?>
		<tr <?if($cnt%2==0)echo 'class="zebra"';?>>
			<input type="hidden" name="items[]" value="<?=$imsi;?>">
			
			<td><input type="checkbox" name="id[]" class="id" value='<?=$imsi;?>' <? if(@in_array($imsi,$_POST['id'])) echo "checked"; ?>></td>
			
				<input type="hidden" name="active[<?=$imsi;?>]" value=0>

			
			
						




<td>
<?

$time=time()+14400; // +4 GMT
$date_z=floor($time/86400); // den
$date_n=floor(($date_z+3)%7)+1; // den nedeli 1 - ponedelnik
$date_m=floor(($time%3600)/60); // minuta
$date_h=floor($time/3600)%24; //chas

//echo ($time."\n");
//echo ($date_z."\n");
//echo ($date_n."\n");
//echo ($date_m."\n");
//echo ($date_h."\n");

$time_work_wake=file_get_contents_def($path_svistok_sim."/settings/$imsi.time_work_wake","-1");
$time_work_sleep=file_get_contents_def($path_svistok_sim."/settings/$imsi.time_work_sleep","-1");

$time_holiday_wake=file_get_contents_def($path_svistok_sim."/settings/$imsi.time_holiday_wake","-1");
$time_holiday_sleep=file_get_contents_def($path_svistok_sim."/settings/$imsi.time_holiday_sleep","-1");

$imsi3=substr($imsi,12,3);

$time_minutes_wake=((($imsi3*17)+($date_z*19))*17)%30*2;
$time_minutes_sleep=((($imsi3*17)+($date_z*29))*17)%30*2;

if($date_n>5)
{
    $dayholiday=2;
    $time_wake=$time_holiday_wake;
    $time_sleep=$time_holiday_sleep;
} else {
    $dayholiday=1;
    $time_wake=$time_work_wake;
    $time_sleep=$time_work_sleep;
}

$pause=0;

if($time_wake>=0)
{
    if($date_h<$time_wake) $pause=$dayholiday;
    if(($date_h==$time_wake)&&($date_m<$time_minutes_wake)) $pause=$dayholiday+10;
}

if($time_sleep>=0)
{
    if(($date_h>$time_sleep)) $pause=$dayholiday;
    if(($date_h==$time_sleep)&&($date_m<$time_minutes_sleep)) $pause=$dayholiday+20;
}

//echo($dayholiday);


?>
			<?=html_group($group,$pause)?>
			
			<br>
			
			<font size=1><? if($group>0) echo ($group);?></font>
			</td>

<td valign="top">
<font size="1">
<?
$pro_set=file_get_contents_def2($path_svistok_sim_settings.$imsi.'.pro','');
$pro_cur=file_get_contents_def2($path_svistok_sim_state.$imsi.'.pro','');
if($pro_set==$pro_cur)
    echo($pro_cur);
else
    echo("<font color=blue>".$pro_cur."</font>");
?></font>
</td>


<td valign="top">
<font size="1">
<?
$cap=file_get_contents_def2($path_svistok_sim_state.$imsi.'.cap','');
if($cap=="OK")
    echo("<img src='imgs/qos/capok.png'>");

if($cap=="FAIL")
    echo("<img src='imgs/qos/capfail.png'>");

?></font>
</td>


<td valign="top">
<?  

    if ((file_get_contents_def2($path_svistok_sim_state.$imsi.'.state_out','0'))==1) 
    {

	    $im=file_get_contents_def2($path_svistok_sim_state.$imsi.'.im','-');
	    if($im=="A")  echo("<img src=imgs/ima.png>"); 
	    if($im=="B")  echo("<img src=imgs/imb.png>"); 
	    if($im=="C")  echo("<img src=imgs/imc.ico>"); 
	    if($im=="D")  echo("<img src=imgs/imd.ico>"); 
	    if($im=="E")  echo("<img src=imgs/ime.ico>"); 
	    //if($im=="N")  echo("<img src=imgs/imn.ico>"); 
    }
?>
</td>

<td valign="top">
<?  
    if ((file_get_contents_def2($path_svistok_sim_state.$imsi.'.state_out','0'))==1) 
    {


    $fas=(file_get_contents_def2($path_svistok_sim_state.$imsi.'.fas','0'));

    $spec=(file_get_contents_def2($path_svistok_sim_state.$imsi.'.spec','0'));
    $vip=(file_get_contents_def2($path_svistok_sim_state.$imsi.'.vip','0'));
    $pre=(file_get_contents_def2($path_svistok_sim_state.$imsi.'.pre','0'));
    $pos=(file_get_contents_def2($path_svistok_sim_state.$imsi.'.pos','0'));

//echo($vip);

    if ($vip==11) {    echo("<img src=imgs/ivip1.ico>");     }
    if ($vip==12) {    echo("<img src=imgs/ivip2.ico>");     }
    else if ($vip>0) {    echo("<img src=imgs/ivip.png>");     }

    if ($pre==1) {    echo("<img src=imgs/pre.png>");     }
    if ($pos==1) {    echo("<img src=imgs/pos.png>");     }



    echo (html_fas($fas));
    echo (html_spec($spec));
    }



//echo($spec2);

    if ((file_get_contents_def2($path_svistok_sim_state.$imsi.'.state_in','0'))==1) 
    {
        $spec=(file_get_contents_def2($path_svistok_sim_state.$imsi.'.spec','0'));
        echo (html_spec($spec));
    }

?>
</td>



			<td nowrap valign="top">

			<? if ((file_get_contents_def2($path_svistok_sim_state.$imsi.'.state_waiting','0'))==1) echo("<img src=imgs/state_wait.gif>"); ?>
			<? 

			$io="";

			if ((file_get_contents_def2($path_svistok_sim_state.$imsi.'.state_in','0'))==1)
			{
				    $io="I";
				    echo(html_io($io));
				    $qos=file_get_contents_def2($path_svistok_sim_state.$imsi.'.qos','0');
				    if ((file_get_contents_def2("/var/svistok/sim/state/".$imsi.'.sout','0'))>1) $qos="SOU";

				    echo(html_qos($qos,$io));
			}
?>

			
			<? 


			if ((file_get_contents_def2($path_svistok_sim_state.$imsi.'.state_out','0'))==1)
			{
			    $io="O";
			    echo(html_io($io));
			    $qos=file_get_contents_def2($path_svistok_sim_state.$imsi.'.qos','0');
			    echo(html_qos($qos,$io));

			    $em_type=file_get_contents_def2($path_svistok_sim_state.$imsi.'.em_type','0');
			    echo($em_type);

			}
			
			?>

			<?
			
			 if ((file_get_contents_def2($path_svistok_sim_state.$imsi.'.state_dialing','0'))==1) 
			 {

			    echo("<img src=imgs/state_dial.png>");
			    $dl=time()-file_get_contents($path_svistok_sim.$imsi.'.stat_call_start');
			    echo ("<br><font size=1>( ".$dl." сек.)");

			 } else
			 if ((file_get_contents_def2($path_svistok_sim_state.$imsi.'.state_ring','0'))==1)
			 {
			    echo("<img src=imgs/state_ring.png>");
			    $dl=time()-file_get_contents($path_svistok_sim.$imsi.'.stat_call_start');
			    echo ("<br><font size=1>( ".$dl." сек.)");
    
			 } else
			 if ((file_get_contents_def2($path_svistok_sim_state.$imsi.'.state_active','0'))==1) 
			  {
			    echo("<img src=imgs/state_active.png>"); 
			    $dl=time()-file_get_contents($path_svistok_sim.$imsi.'.stat_call_connected');
			    echo ("<br><font size=1>( ".$dl." сек.)");
			  } else {

				$outgoing_sms=file_get_contents_def2($path_svistok_sim_state.$imsi.'.outgoing_sms','0');
				$outgoing_ussd=file_get_contents_def2($path_svistok_sim_state.$imsi.'.outgoing_ussd','0');
				if($outgoing_sms!=0)
				{
				    echo("<img src=imgs/sms_out.png>");
				}
				else if($outgoing_ussd==1)
				{
				    echo("<img src=imgs/sms_out.png>");
				}
				
				    $ce=@file_get_contents($path_svistok_sim.$imsi.'.stat_call_end');
				    if ($ce>0)
				    {
				    $dm=file_get_contents($path_svistok_sim_settings.$imsi.'.diff_min');
				    $dl=time()-$ce;
				    if ($dl<$dm)
				    {
				    echo("<img src=imgs/state_wait.png>");
				    echo ("<br><font size=1>( ".$dl."/".$dm." сек.)");
				    }
				    }


				
			  
			  }
			    if((file_get_contents_def2($path_svistok_sim_state.$imsi.'.busy','0'))==1)
			    {
				$numberb=file_get_contents_def2($path_svistok_sim_state.$imsi.'.numberb','');
				$numbera=file_get_contents_def2($path_svistok_sim_state.$imsi.'.numbera','');
/*
				if(substr($numberb,-4)=="#SOU")
				{
				    $numbera="#SOU";
				    $numberb=substr($numberb,0,-4);
				}
*/
				if(substr($numberb,-19,4)=="#SOU")
				{
				    $numbera=substr($numberb,-15);
				    $numberb=substr($numberb,0,-15);

				}

			      echo "<br>".$numberb."<br>";
				echo "<font color=#cccccc>";


			      echo $numbera;
			    }
			  ?>
			  
			  
<!--
			
			<?=file_get_contents_def2($path_svistok_sim_state.$imsi.'.busy','').' - '.file_get_contents_def2($path_svistok_sim_state.$imsi.'.numberb', '').' - '.file_get_contents_def2($path_svistok_sim_state.$imsi.'.durationb','');?>
-->
			</td>



<td valign="top">
<?
			if ((file_get_contents_def2($path_svistok_sim_state.$imsi.'.state_out','0'))==1) 
			{
			    $billing_direction=(file_get_contents_def2($path_svistok_sim_state.$imsi.'.billing_direction','HZ'));
			    
			    echo(html_napr($billing_direction));
			}
?>

</td>


			<td>
<?
		$plan=file_get_contents_def2($path_simbox_sim_settings.$imsi.'.plan', 'default');
		$nabor=file_get_contents_def($path_simbox_plan.$plan.'.nabor',"default");
		$tarif=file_get_contents_def($path_simbox_sim_settings.$imsi.'.tarif',"");
		$owner=file_get_contents_def("/var/simbox/sim/settings/809".$imsi.'.owner',"");
?>
<?=$plan?><br>
<font size=1 color="#cccccc">
<?=$nabor?>
<br>
<?=$tarif?>
<br>
</font>
<!--
			<select name="plan[<?=$imsi;?>]"><?
							foreach($plans as $i2=>$v2){
								  $v2=trim($v2);
								?><option value="<?=$v2;?>" <?if(strcmp($v2,file_get_contents_def2($path_simbox_sim_settings.$imsi.'.plan', 'default'))==0)echo 'selected';?>><?=$v2;?></option><?}
				?></select>
-->				
				</td>
			<td><font size=1>
			<?
				$number=file_get_contents_def2($path_simbox_sim_settings.$imsi.'.number',"");
				if(substr($number,0,1)=="7") $number=substr($number,1);
				echo($number);
			?></font></td>
			<td><?=file_get_contents_def2($path_svistok_sim_state.$imsi.'.provider_name',"");?><br>
			<font size=2 color="#cccccc"><?=file_get_contents_def2($path_svistok_sim_state.$imsi.'.provider_name2',"");?>
			<br><?=$owner?>
	
</font></td>
			<td>
<?

$get_balance_request=file_get_contents_def2($path_simbox_sim_statistics.$imsi.'.get_balance_request',0);
$get_balance_response=file_get_contents_def2($path_simbox_sim_statistics.$imsi.'.get_balance_response',0);

$get_balance_str="никогда";

$gbt=time();
$get_balance_color="#9999ff";

if ($get_balance_request>$get_balance_response) 
{ if($get_balance_request>0) { $get_balance_str="ждем ".($gbt-$get_balance_request)." с"; $get_balance_color="red";} } 
else
{ 
    if($get_balance_response>0) 
    {
	    $get_balance_str= ($gbt-$get_balance_response)." с назад";
	    if (($gbt-$get_balance_response)>7200) $get_balance_color="#aaaaff" ;

	    if (date('d.m',$get_balance_response)<>date('d.m',time()))
	    {
		$get_balance_color="#cccccc" ;
		$get_balance_str=date('d.m',$get_balance_response);
	    }
    } 

}



$balance=file_get_contents_def2($path_simbox_sim_statistics.$imsi.'.balance',"?");

$op_t=file_get_contents_def2($path_simbox_sim_statistics.$imsi.'.op_t',"");
$op_d=file_get_contents_def2($path_simbox_sim_statistics.$imsi.'.op_d',"");



$bal_yest=file_get_contents_def2($path_simbox_sim_statistics.$imsi.'.bal_yest','?');
$bal_minus="-".file_get_contents_def2($path_simbox_sim_statistics.$imsi.'.bal_minus','?');
$bal_plus="+".file_get_contents_def2($path_simbox_sim_statistics.$imsi.'.bal_plus','?');
$bal_color="#cccccc";
$bal_b=0;
if($bal_minus<-35) 
{
    $bal_color="red";
    $bal_b=1;
}
if($bal_plus>101)
{
 $bal_color="green";
 $bal_b=1;
}

?>
			<font size=1 color=<?=$get_balance_color?> ><?=$get_balance_str?></font><br>
			<font size=2><?=$balance;?></font> <font size=1><?=html_op($op_t, $op_d)?></font><br>
			<? if($bal_b) echo "<b>"; ?>
			<font size=1 color=<?=$bal_color?> >
			<?=$bal_yest;?> <?=$bal_minus;?> <?=$bal_plus;?>
			</font>
			<? if($bal_b) echo "</b>"; ?>
			</td>


<td>
<?
echo(html_dongle($model));
echo(html_cfun($cfun));
?>
</td>
                <td>
<?
echo(html_simst($simst,$pinrequired));
echo(html_srvst($srvst,$simst));
?>
</td>
<td>
<font face="courier"><?=$dongle;?><?=$dongle_a;?></td>


<td>
<!--
<a href="showlog.php?imsi=<?=$imsi?>" data-local="showlog.php?imsi=<?=$imsi?>" class="tooltip_file"" target="_blank">
<a href="showlog.php?imsi=<?=$imsi?>&calls=1" data-local="showcalls.php?imsi=<?=$imsi?>" class="tooltip_file"" target="_blank"><img src="imgs/calls.png"  border=0></a><br>
-->

<span class="tip" onmouseover="tooltip(<?=$imsi?>);" onmouseout="bye();">
<a href="showlog.php?imsi=<?=$imsi?>" target="_blank">
<img src="imgs/ussdsms.png"  border=0>
</span>
</a>

<br>

<span class="tip" onmouseover="tooltip2(<?=$imsi?>);" onmouseout="bye();">
<a href="showlog.php?imsi=<?=$imsi?>&calls=1" target="_blank">
<img src="imgs/calls.png"  border=0>
</span>
</a>


<br>



</td>
			<td><?=file_get_contents_def2($path_svistok_sim_statistics.$imsi.'.stat_out_calls','');?><br>
			<font size=2 color="#cccccc">
			<?=file_get_contents_def2($path_svistok_sim_statistics.$imsi.'.imb_count','0');?>/<?=file_get_contents_def2($path_svistok_sim_statistics.$imsi.'.imc_count','0');?><br>
			<?=file_get_contents_def2($path_svistok_sim_statistics.$imsi.'.imn_count','0');?>/<?=file_get_contents_def2($path_svistok_sim_statistics.$imsi.'.imd_count','0');?>/<?=file_get_contents_def2($path_svistok_sim_statistics.$imsi.'.ime_count','0');?><br>
			</td>
			<td><?=file_get_contents_def2($path_svistok_sim_statistics.$imsi.'.stat_calls_answered','');?><br><?=file_get_contents_def2($path_svistok_sim_statistics.$imsi.'.stat_in_answered','');?></td>
			<td><?=minsec(file_get_contents_def2($path_svistok_sim_statistics.$imsi.'.stat_calls_duration',''));?><br><?=minsec(file_get_contents_def2($path_svistok_sim_statistics.$imsi.'.stat_in_duration',''));?></td>
			<td><?=minsec(acd(file_get_contents($path_svistok_sim_statistics.$imsi.'.stat_calls_duration'),file_get_contents($path_svistok_sim_statistics.$imsi.'.stat_calls_answered')));?> / <br><!--input type="text" name="acdo_min[<?=$imsi;?>]" size=2 value="<?=minsec(file_get_contents_def($path_simbox_sim_settings.$imsi.'.acdo_min',180));?>"--></td>
			<td><?=minsec(acd(file_get_contents($path_svistok_sim_statistics.$imsi.'.stat_in_duration'),file_get_contents($path_svistok_sim_statistics.$imsi.'.stat_in_answered')));?> / <br><!--input type="text" name="acdo_min[<?=$imsi;?>]" size=2  value="<?=minsec(file_get_contents_def($path_simbox_sim_settings.$imsi.'.acdi_min',180));?>"--></td>
			<td><center><font size=2 color="#cccccc">
			<? if ((file_get_contents_def2($path_simbox_sim_state.$imsi.'.low_acdl','0'))==1) echo("<font color=#cc0000><img src=imgs/low_acdl.ico>"); ?><br>
			
			<?=minsec(file_get_contents($path_svistok_sim_statistics.$imsi.'.stat_acdl')/1000);?></td>

			<td><center><font size=2 color="#cccccc">
			<? if ((file_get_contents_def2($path_simbox_sim_state.$imsi.'.high_datt','0'))==1) echo("<font color=#cc0000><img src=imgs/high_datt.ico>"); ?><br>

			<?=file_get_contents($path_svistok_sim_statistics.$imsi.'.stat_datt');?>
			    </td>
			<td><center><font size=2 color="#cccccc">
			
			<? if ((file_get_contents_def2($path_simbox_sim_state.$imsi.'.need_in','0'))==1) echo("<font color=#cc0000><img src=imgs/need_in.png>"); ?><br>
			
			<?=file_get_contents($path_svistok_sim_statistics.$imsi.'.stat_iatt');?>
			</td>

			<td><center><font size=2 color="#cccccc">
			
			<? if ((file_get_contents_def2($path_simbox_sim_state.$imsi.'.need_sms','0'))==1) echo("<font color=#cc0000><img src=imgs/satt.png>"); ?><br>
			
			<?=file_get_contents_def2($path_svistok_sim_statistics.$imsi.'.stat_satt',0);?>
			</td>
			<td><font size=1>
			<?

			$may_sended=file_get_contents_def2("/var/simbox/sim/settings/$imsi.may_sended",0);
			$mon_sended=file_get_contents_def2("/var/simbox/sim/settings/$imsi.mon_sended",0);
			$msm_sended=file_get_contents_def2("/var/simbox/sim/settings/$imsi.msm_sended",0);

			$may_limit=file_get_contents_def2("/var/simbox/sim/settings/$imsi.may_limit",0);
			$mon_limit=file_get_contents_def2("/var/simbox/sim/settings/$imsi.mon_limit",0);
			$msm_limit=file_get_contents_def2("/var/simbox/sim/settings/$imsi.msm_limit",0);

			if($may_sended<=0) echo("<font color=#cccccc>");
			echo("MAY:".$may_sended."/".$may_limit."<br>");
			if($may_sended<=0) echo("</font>");
			if($mon_sended<=0) echo("<font color=#cccccc>");
			echo("MON:".$mon_sended."/".$mon_limit."<br>");
			if($mon_sended<=0) echo("</font>");
			if($msm_sended<=0) echo("<font color=#cccccc>");
			echo("MSM:".$msm_sended."/".$msm_limit."<br>");
			if($msm_sended<=0) echo("</font>");


			$smsout_sended=file_get_contents_def2("/var/simbox/sim/settings/$imsi.smsout_sended",0);

			$smsout_soft=file_get_contents_def2("/var/simbox/sim/settings/$imsi.smsout_soft",0);
			$smsout_hard=file_get_contents_def2("/var/simbox/sim/settings/$imsi.smsout_hard",0);

			if($smsout_sended<=0) echo("<font color=#cccccc>");
			echo("SMS:".$smsout_sended."/[$smsout_soft;$smsout_hard]");
			if($smsout_sended<=0) echo("</font>");
?>
			</td>



			<td><?=file_get_contents($path_svistok_sim_statistics.$imsi.'.stat_asrl')/1000;?></td>
			<td><?=file_get_contents($path_svistok_sim_statistics.$imsi.'.stat_asrl')/1000;?></td>
			<td><?=minsec(file_get_contents($path_svistok_sim_statistics.$imsi.'.stat_pddl0'));?></td>
			<td><?=minsec(file_get_contents($path_svistok_sim_statistics.$imsi.'.stat_pddl1'));?></td>
			<td><!--input type="text" name="priority[<?=$imsi?>]" size=1 value="<?=file_get_contents($path_svistok_sim_settings.$imsi.'.priority');?>"--></td>
<?

$palevo=file_get_contents_def2("/var/simbox/sim/settings/".$imsi.'.palevo',"0");
$palevo0=file_get_contents_def2("/var/simbox/sim/settings/".$imsi.'.1.palevo',"0");
$palevo1=file_get_contents_def2("/var/simbox/sim/settings/".$imsi.'.2.palevo',"0");
$palevo2=file_get_contents_def2("/var/simbox/sim/settings/".$imsi.'.3.palevo',"0");
$palevo3=file_get_contents_def2("/var/simbox/sim/settings/".$imsi.'.4.palevo',"0");
$palevo4=file_get_contents_def2("/var/simbox/sim/settings/".$imsi.'.5.palevo',"0");
$palevo5=file_get_contents_def2("/var/simbox/sim/settings/".$imsi.'.6.palevo',"0");



?>

			<td> <? if($palevo=="1")  echo("<img src=imgs/ipalevo.png>");?> <?=file_get_contents_def2($path_svistok_sim_limits.$imsi.'.limit.0',"");?> / <br><?=file_get_contents_def2($path_svistok_sim_limits.$imsi.'.limit_max.0',"");?></td>
			<td><? if($palevo1=="1")  echo("<img src=imgs/ipalevo.png>");?> <?=file_get_contents_def2($path_svistok_sim_limits.$imsi.'.limit.1',"");?> / <br><?=file_get_contents_def2($path_svistok_sim_limits.$imsi.'.limit_max.1',"");?></td>
			<td><? if($palevo2=="1")  echo("<img src=imgs/ipalevo.png>");?> <?=file_get_contents_def2($path_svistok_sim_limits.$imsi.'.limit.2',"");?> / <br><?=file_get_contents_def2($path_svistok_sim_limits.$imsi.'.limit_max.2',"");?></td>
			<td><? if($palevo3=="1")  echo("<img src=imgs/ipalevo.png>");?> <?=file_get_contents_def2($path_svistok_sim_limits.$imsi.'.limit.3',"");?> / <br><?=file_get_contents_def2($path_svistok_sim_limits.$imsi.'.limit_max.3',"");?></td>
			<td><? if($palevo4=="1")  echo("<img src=imgs/ipalevo.png>");?> <?=file_get_contents_def2($path_svistok_sim_limits.$imsi.'.limit.4',"");?> / <br><?=file_get_contents_def2($path_svistok_sim_limits.$imsi.'.limit_max.4',"");?></td>
			<td><? if($palevo5=="1")  echo("<img src=imgs/ipalevo.png>");?> <?=file_get_contents_def2($path_svistok_sim_limits.$imsi.'.limit.5',"");?> / <br><?=file_get_contents_def2($path_svistok_sim_limits.$imsi.'.limit_max.5',"");?></td>
<!--
			<td><input type="text" name="diff_min[<?=$imsi?>]" size=3 value="<?=file_get_contents($path_svistok_sim_settings.$imsi.'.diff_min');?>"></td>
			<td><input type="text" name="diff_min_out[<?=$imsi?>]" size=3 value="<?=file_get_contents($path_svistok_sim_settings.$imsi.'.diff_min_out');?>"></td>
			<td><input type="text" name="diff_min_sout[<?=$imsi?>]" size=3 value="<?=file_get_contents($path_svistok_sim_settings.$imsi.'.diff_min_sout');?>"></td>
			<td><input type="text" name="diff_min_imode[<?=$imsi?>]" size=3 value="<?=file_get_contents($path_svistok_sim_settings.$imsi.'.diff_min_imode');?>"></td>
			<td><input type="text" name="start_time[<?=$imsi?>]" size=2 value="<?=file_get_contents_def2($path_svistok_sim_settings.$imsi.'.start_time',"");?>"></td>
			<td><input type="text" name="end_time[<?=$imsi?>]" size=2 value="<?=file_get_contents_def2($path_svistok_sim_settings.$imsi.'.end_time',"");?>"></td>
-->

<!--
				<input type="hidden" name="can_in[<?=$imsi;?>]" value=0>
			<td><input type="checkbox" name="can_in[<?=$imsi;?>]" value=1 <?if(file_get_contents($path_svistok_sim_settings.$imsi.'.can_in')==1)echo 'checked';?>></td>

				<input type="hidden" name="can_out[<?=$imsi;?>]" value=0>
			<td><input type="checkbox" name="can_out[<?=$imsi;?>]" value=1 <?if(file_get_contents($path_svistok_sim_settings.$imsi.'.can_out')==1)echo 'checked';?>></td>

				<input type="hidden" name="can_sout[<?=$imsi;?>]" value=0>
			<td><input type="checkbox" name="can_sout[<?=$imsi;?>]" value=1 <?if(file_get_contents($path_svistok_sim_settings.$imsi.'.can_sout')==1)echo 'checked';?>></td>

				<input type="hidden" name="igoo[<?=$imsi;?>]" value=0>
			<td><input type="checkbox" name="igoo[<?=$imsi;?>]" value=1 <?if(file_get_contents($path_svistok_sim_settings.$imsi.'.igoo')==1)echo 'checked';?>></td>

				<input type="hidden" name="inor[<?=$imsi;?>]" value=0>
			<td><input type="checkbox" name="inor[<?=$imsi;?>]" value=1 <?if(file_get_contents($path_svistok_sim_settings.$imsi.'.inor')==1)echo 'checked';?>></td>


				<input type="hidden" name="ibad[<?=$imsi;?>]" value=0>
			<td><input type="checkbox" name="ibad[<?=$imsi;?>]" value=1 <?if(file_get_contents($path_svistok_sim_settings.$imsi.'.ibad')==1)echo 'checked';?>></td>


				<input type="hidden" name="inew[<?=$imsi;?>]" value=0>
			<td><input type="checkbox" name="inew[<?=$imsi;?>]" value=1 <?if(file_get_contents($path_svistok_sim_settings.$imsi.'.inew')==1)echo 'checked';?>></td>

				<input type="hidden" name="inos[<?=$imsi;?>]" value=0>
			<td><input type="checkbox" name="inos[<?=$imsi;?>]" value=1 <?if(file_get_contents($path_svistok_sim_settings.$imsi.'.inos')==1)echo 'checked';?>></td>


				<input type="hidden" name="i_mode[<?=$imsi;?>]" value=0>
			<td><input type="checkbox" name="i_mode[<?=$imsi;?>]" value=1 <? //if(file_get_contents($path_svistok_sim_settings.$imsi.'.i_mode')==1)echo 'checked';?>></td>

-->
			<td><?=file_get_contents_def2($path_svistok_sim_state.$imsi.'.lac','');?></td>
			<td><?=file_get_contents_def2($path_svistok_sim_state.$imsi.'.cell','');?></td>
			<td><?=$imei;?></td>
			<td><?=$imsi;?></td>


			
			<td><a href="showlog.php?imsi=<?=$imsi?>" target="_blank">ussd&sms</a><br>
			<a href="showcalls.php?imsi=<?=$imsi?>" target="_blank">calls</a>
			</td>

			<td>
			<font size="1">
			<?=file_get_contents_def2($path_svistok_sim_statistics.$imsi.'.date_activated',"");?><br>
			<?=file_get_contents_def2($path_svistok_sim_statistics.$imsi.'.date_1call',"");?><br>
			<?=file_get_contents_def2($path_svistok_sim_statistics.$imsi.'.date_lcall',"");?><br>
			<?=file_get_contents_def2($path_simbox_sim_state.$imsi.'.date_blocked',"");?><br>

			</font>
			</td>


			
		</tr>
	<?
}
}
?>

<tr class="header"><td colspan=53>Всего: <?=$cnt?></td></tr>

</table>

<br><br>

<table>
<tr class="header">
<td>
Редактирование
</td></tr><tr><td>
фильтр по группе <input type="text" name="filter_group" value="<?=@$_POST['filter_group']?>">, не<input type="text" name="filter_group_not" value="<?=@$_POST['filter_group_not']?>"><br>
фильтр по плану <select name="filter_plan">
			<option value=""></option>
			<?
							foreach($plans as $i2=>$v2){
								  $v2=trim($v2);
								?><option value="<?=$v2;?>" <?if(strcmp($v2,@$_POST['filter_plan'])==0)echo 'selected';?>><?=$v2;?></option><?}
				?></select> 
, не
			<select name="filter_plan_no">
			<option value=""></option>
			<?
							foreach($plans as $i2=>$v2){
								  $v2=trim($v2);
								?><option value="<?=$v2;?>" <?if(strcmp($v2,@$_POST['filter_plan_no'])==0)echo 'selected';?>><?=$v2;?></option><?}
				?></select>
<br>

<!--

<input type="hidden" name="0xx" value="2">
<input type="hidden" name="1xx" value="2">
<input type="hidden" name="3xx" value="2">
<input type="hidden" name="5xx" value="2">


<input type="checkbox" name="0xx" value="1" <?if(@$_POST['0xx']!="2") echo("checked");?>> 0xx
<input type="checkbox" name="1xx" value="1" <?if(@$_POST['1xx']!="2") echo("checked");?>> 1xx
<input type="checkbox" name="3xx" value="1" <?if(@$_POST['3xx']!="2") echo("checked");?>> 3xx
<input type="checkbox" name="5xx" value="1" <?if(@$_POST['5xx']!="2") echo("checked");?>> 5xx

-->


<br>
<input type="submit" name="refresh" value="Обновить"> 
<!--
<hr>

<input type="submit" name="save" value="Сохранить"> 
-->
</td></tr></table>


<br><br>
<? require("modules/actions.php"); ?>


<table>
<tr class="header">
        <td>
<img src="imgs/state/state_dial.png"> Передатчик
</td></tr>
<tr><td>
<img src="imgs/p-on.png"><input type="submit" name="pon" value="ВКЛ">
<br>
<img src="imgs/p-off.png"><input type="submit" name="poff" value="ВЫКЛ">
</td></tr>
</table>



<br><br>



<table>
<tr class="header">
<td>
Действия простые на выбранные симки
</td></tr><tr><td>
USSD запрос <input type="text" name="ussdcommand" value="<?=@$_POST['ussdcommand']?>"> <input type="submit" name="sendussd" value="USSD"> <br><br>
SMS на номер <input type="text" name="smsnumber" value="<?=@$_POST['smsnumber']?>"> сообщение <input type="text" name="smstext" value="<?=@$_POST['smstext']?>"> <input type="submit" name="sendsms" value="SMS"> <br><br>
Звонок на номер <input type="text" name="call60number"  value="<?=@$_POST['call60number']?>"> с тишиной <input type="submit" name="call60" value="Call60"> <br><br>
<font size=1>Формат как на телефоне например 0611 или 89261112233</font><br>
Звонок на номер <input type="text" name="callspeaknumber" value="<?=@$_POST['callspeaknumber']?>"> с разговором <input type="submit" name="callspeak" value="CallSpeak"> <br><br>
<font size=1>Формат как на телефоне например 0611 или 89261112233</font><br>
Звонок на номер <input type="text" name="calldtmfnumber" value="<?=@$_POST['calldtmfnumber']?>"> с последовательностью <input type="text" name="calldtmfnabor" value="<?=@$_POST['calldtmfnabor']?>"> <input type="submit" name="calldtmf" value="CallDTMF"> <br>
<font size=1>Последовательность цифр, которые набираем, w - пауза 0.5 сек. Например номер 0206 последовательность 1wwwwww1</font>
<br><br>
</td></tr></table>

<br><br>


<table>
<tr class="header">
<td>
Действия групповые и плановые
</td></tr><tr><td>

Сменить группу на <input type="text" name="setgroupnumber" value="<?=@$_POST['setgroupnumber']?>"> <input type="submit" name="setgroup" value="Set group"> <br><br>

Установить план <select name="set_plan_select"><?
							foreach($plans as $i2=>$v2){
								  $v2=trim($v2);
								?><option value="<?=$v2;?>"  <?if(strcmp($v2,@$_POST['set_plan_select'])==0)echo 'selected';?> ><?=$v2;?></option><?}
				?></select>
на выбранные <input type="submit" name="set_plan_set" value="без копирования параметров"> или <input type="submit" name="set_plan" value="с копированием параметров">

<br><br>
<input type="submit" name="set_plan_copy" value="Восстановить параметры плана"> выбранных сим
<br><br>
<input type="submit" name="set_autoblock_null" value="Снять флажки автоблокировки"> выбранных сим
</td></tr></table>

<br><br>


<table>
<tr class="header">
<td>
Действия хитрые на выбранные симки (работают при правильно выбранном плане)
</td></tr><tr><td>
Активировать сим-карту (стартовый баланс) <input type="submit" name="activate_sim" value="Activate SIM"> <br><br>
Запросить информацию о балансе <input type="submit" name="get_balance" value="Get balance"> <br><br>
Запросить информацию о номере <input type="submit" name="get_number" value="Get number"> <br><br>
Запросить информацию о минутах <input type="submit" name="get_minutes" value="Get minutes"> <br><br>
Запросить информацию о тарифе <input type="submit" name="get_tarif" value="Get tarif"> <br><br>
Запросить информацию о опциях <input type="submit" name="get_options" value="Get options"> <br><br>
Подключить обещанный платеж <input type="submit" name="get_dover" value="Get dover"> <br><br>
<hr>
Активировать рабочий режим (возможность звонить) <input type="submit" name="activate_work" value="Activate work"> <br><br>
<hr>
</td></tr></table>


<br><br>

<table>
<tr class="header">
<td>
Действия комплексные на выбранные симки (работают при правильно выбранном плане)
</td></tr><tr><td>
Подготовка (1. Активировать сим-карту 2. запрос баланса, номера и тарифа 3. отправить в запас <input type="submit" name="complex_prepare" value="Complex prepare"> <br><br>
Подготовка2 (1. Активировать сим-карту 2. запрос баланса, номера и тарифа 3. отправить в запас. 4. Возможность звонить.  <input type="submit" name="complex_prepare2" value="Complex prepare 2"> <br><br>
В работу (1. Возможность звонить. 2. Ожидание успеха. 3. В работу<input type="submit" name="Complex_work" value="Complex work"> <br><br>
</td></tr></table>

<br><br>

<table>
<tr class="header">
<td>
Импорт
</td></tr><tr><td>
<a href="?p=numbers" target="_blank">Импорт номеров</a>
</td></tr></table>

<br><br>


<table>
<tr class="header">
<td>
Экспорт
</td></tr><tr><td>
Экспортировать список свистков <input type="submit" name="export_dongles" value="Export dongles"> <br><br>
Экспортировать список номеров <input type="submit" name="export_numbers" value="Export numbers"> <br><br>
<?
if (!isset($_POST['export_masspayment_balance'])) $_POST['export_masspayment_balance']=2;
if (!isset($_POST['export_masspayment_balance_minimum'])) $_POST['export_masspayment_balance_minimum']=10;
if (!isset($_POST['export_masspayment_balance_maximum'])) $_POST['export_masspayment_balance_maximum']=37;
?>
Экспортировать csv для <a href="https://masspayment.wmtransfer.com/">masspayment</a><br>
<input type="text" name="export_masspayment_balance" value="<?=@$_POST['export_masspayment_balance']?>"> необходимый баланс <br>
<input type="text" name="export_masspayment_balance_minimum" value="<?=@$_POST['export_masspayment_balance_minimum']?>"> минимальный платеж <br>
<input type="text" name="export_masspayment_balance_maximum" value="<?=@$_POST['export_masspayment_balance_maximum']?>"> максимальный платеж <br>
<input type="submit" name="export_masspayment" value="Export masspayment">
<br>
<br><font size=1>Автоматически рассчитывается необходимая сумма в WMR для того чтобы баланс (в WMR) стал как заданный. Предварительно необходимо обновить текущий баланс!</font>
</td></tr></table>

<br><br>

<table>
<tr class="header">
<td>
Опции
</td></tr><tr><td>
Запуск действий в фоновом режиме с задержкой <input type="text" name="delay_min" value="<?=@$_POST['delay_min']?>"> + случайной задержкой до <input type="text" name="delay_rnd" value="<?=@$_POST['delay_rnd']?>"> сек<br><br>
<input type="checkbox" name="delay_queue" value=1  <?if(@$_POST['delay_queue']==1)echo 'checked';?>> Вместо запуска поместить в очередь<br>
<!--
<font size=1>Важно! при использовании очереди и случайной задержки - случайное время идет по очереди, т.е. суммируется; без использования очереди все задания исполнятся в промежутке
-->
</td></tr></table>

<br><br>

<table>
<tr class="header">
<td>
Замена KI (адаптер Super Sim)
</td></tr><tr><td>
<input type="submit" name="supersim_new" value="Auto new supersim KI"> <input type="text" name="supersim_ki_owner" value="<?=@$_POST['supersim_ki_owner']?>"><br>
<hr>
imsi: <input type="text" name="dat_imsi" value="<?=@$_POST['supersim_imsi']?>"> <br>
iccid: <input type="text" name="dat_iccid" value="<?=@$_POST['supersim_iccid']?>"> <br>
ki: <input type="text" name="dat_ki" value="<?=@$_POST['supersim_ki']?>"> <br>
smsc: <input type="text" name="dat_smsc" value="<?=@$_POST['supersim_smsc']?>"> <br>
<input type="submit" name="supersim_set" value="Set data"> <br>
</td></tr></table>
<br><br>

<table>
<tr class="header">
<td>
Замена KI (адаптер dual)
</td></tr><tr><td>
<input type="submit" name="newki" value="Auto new KI"> <input type="text" name="ki_owner" value="<?=@$_POST['ki_owner']?>"><br>
<hr>
dat_imsi: <input type="text" name="dat_imsi" value="<?=@$_POST['dat_imsi']?>"> <br>
dat_iccid: <input type="text" name="dat_iccid" value="<?=@$_POST['dat_iccid']?>"> <br>
dat_ki: <input type="text" name="dat_ki" value="<?=@$_POST['dat_ki']?>"> <br>
dat_smsc: <input type="text" name="dat_smsc" value="<?=@$_POST['dat_smsc']?>"> <br>
<input type="submit" name="setki" value="Set data"> <br>
</td></tr></table>

<br><br>

<table>
<tr class="header">
<td>
Rotator (поиск среди старых)
</td></tr><tr><td>

<!--
<input type="checkbox" name="rot_ki" value='1' <? if(@$_POST['rot_ki']) echo "checked"; ?>> New KI<br>
<input type="checkbox" name="rot_lo" value='1' <? if(@$_POST['rot_lo']) echo "checked"; ?>> Цикл<br>
<input type="text" name="rot_owner" value="<?=@$_POST['rot_owner']?>"><br>
<input type="submit" name="rotki" value="Rotator"><br>
-->


</td></tr></table>

<br><br>

<table>
<tr class="header">
<td>
SMS рассылка
</td></tr><tr><td>
<input type="submit" name="smsspam" value="Разослать"><br>

</td></tr></table>

<br><br>



</form>
<br><br>


<table>
<tr class="header">
<td>
Примечание:
</td></tr><tr><td>
m-i,m-o, и т.д.<br>
a - количество<br>
m - минуты<br>
i - входящие<br>
o - исходящие<br>

ACD - отношение длины разговоров к количеству (ACDL - последние 20)<br>
ASR - отношение количества успешных к общему количеству звонков (ASRL - последние 20)<br>
PDD - время до ответа<br>
DATT - количество недозвонов подряд<br>
IATT - количество исходящих подряд<br>
<img src=imgs/state_in.png> can in/<img src=imgs/state_out.png> can out/<img src=imgs/state_sout.png> can sout - разрешает входящие/исходящие/исходящие для входящих<br>
<br>

<img src=imgs/ivip.png> iVIP - звонки с достоверных источников (карточный, свой и т.д.)<br>
<img src=imgs/igoo.png> iGOO - белый список номеров с очень качественными звонками<br>
<img src=imgs/inor.png> iNOR - белый список номеров с нормальными показателями<br>
<img src=imgs/ibad.png> iBAD - черный список номеров с низкими показателями<br>
<img src=imgs/inew.png> iNEW - номер в списках не значится<br>
<img src=imgs/inos.png> iNOS - информация не получена, т.к. сервер не отвечает.<br>
<img src=imgs/imn.ico> IMN - вызов на НЕ вызываемый ранне номер<br>

<img src=imgs/imb.png> IMB - вызов на вывываемый ранее номер (number B) с той же симки.<br>
<img src=imgs/imc.ico> IMC - вызов на вывываемый ранее номер (number B) с той же симки (но не первой).<br>
<img src=imgs/imd.ico> IMD - вызов на вывываемый ранее номер (number B) с другой симки (используемые - заняты!) для новой сессии.<br>
<img src=imgs/ime.ico> IME - вызов на вывываемый ранее номер (number B) с другой симки (используемые - заняты!) для старой(тырит чужие, даже активные) сессии. (использовать аккуратно, могут прозвонить все такие симки)<br>

<img src=imgs/iblo.png> iBLO - названиевает как обезьяна (возможно прозвон)<br>
<img src=imgs/irob.png> iROB - названиевает как робот (более возможно прозвон)<br>
<br>
<img src=imgs/high_datt.ico> - флаг автоблокировки при высоком datt<br>
<img src=imgs/low_acdl.ico> - флаг автоблокировки при низком acdl<br>
<img src=imgs/need_in.png> - флаг необходимости входящего<br>
<img src=imgs/satt.png> - флаг необходимости SMS<br>

<br>
<center>
Группы:<br>
<table>
<tr class="header"><td>группа</td><td>симки<br><font size=1>(откуда)</td><td>направления<br><font size=1>(куда)</td></tr>
<tr><td>101</td><td>питерские симки Мегафон</td><td><img src=imgs/napravleine/megafon_spb.ico><img src=imgs/napravleine/megafon_ru.ico></td></tr>
<tr><td>102</td><td>питерские симки Билайн</td><td><img src=imgs/napravleine/beeline_spb.ico><img src=imgs/napravleine/beeline_ru.ico><img src=imgs/napravleine/mts_spb.ico><img src=imgs/napravleine/megafon_spb.ico><img src=imgs/napravleine/tele2_spb.ico><img src=imgs/napravleine/proper_spb.ico></td></tr>
<tr><td>103</td><td>питерские симки МТС</td><td><img src=imgs/napravleine/mts_spb.ico></td></tr>
<tr><td>104</td><td>московские симки Мегафон</td><td><img src=imgs/napravleine/megafon_msk.ico></td></tr>
<tr><td>105</td><td>московские симки МТС</td><td><img src=imgs/napravleine/mts_msk.ico></td></tr>
<tr><td>106</td><td>московские симки Билайн</td><td><img src=imgs/napravleine/beeline_msk.ico></td></tr>
<tr><td>109</td><td>питерские симки TELE2</td><td><img src=imgs/napravleine/tele2_spb.ico></td></tr>
<tr><td>111</td><td>киевстар, украина</td><td><img src=imgs/napravleine/kievstar.ico></td></tr>
<tr><td>121</td><td>беларусия, мтс</td><td><img src=imgs/napravleine/mts_by.ico></td></tr>
<tr><td>122</td><td>беларусия, велком</td><td><img src=imgs/napravleine/velcom_by.ico></td></tr>
<tr><td>123</td><td>беларусия, life</td><td><img src=imgs/napravleine/velcom_by.ico><img src=imgs/napravleine/life_by.ico></td></tr>
<tr><td>152</td><td>челябинская обл., мегафон</td><td><img src=imgs/napravleine/megafon_chel.ico></td></tr>
<tr><td>153</td><td>урал., мегафон</td><td><img src=imgs/napravleine/megafon_ural.ico></td></tr>
<tr><td>155</td><td>челябинская обл., билайн</td><td><img src=imgs/napravleine/beeline_chel.ico></td></tr>
<tr><td>160</td><td>saunalahti</td><td><img src=imgs/napravleine/elisa.ico></td></tr>
<tr><td>161</td><td>dna</td><td><img src=imgs/napravleine/dna.ico></td></tr>
<tr><td>203</td><td>юр питерские симки МТС</td><td><img src=imgs/napravleine/mts_ru.ico></td></tr>
<tr><td>209</td><td>юр питерские симки TELE2</td><td><img src=imgs/napravleine/tele2_ru.ico></td></tr>

<tr><td>222</td><td>питерские симки Ростелеком (на фикс)</td><td><img src=imgs/napravleine/rostel_spb.ico></td></tr>
<tr><td>232</td><td>питерские симки Ростелеком (на СНГ)</td><td><img src=imgs/napravleine/rostel_spb.ico></td></tr>
<tr><td colspan=3><hr></td></tr>
<tr><td>333</td><td>автоблокировка по DATT<td><img src=imgs/high_datt.ico></td></tr>
<tr><td>334</td><td>автоблокировка по ACDL<td><img src=imgs/low_acdl.ico></td></tr>
<tr><td>335</td><td>автоблокировка по SMS о блокировке по балансу<td><img src=imgs/blocked_balance.ico></td></tr>
<tr><td>336</td><td>автоблокировка сим заблокирована<td><img src=imgs/simblocked.ico></td></tr>

<tr><td>410</td><td>low balance<td><img src=imgs/low_balance.png></td></tr>
<tr><td>510</td><td>blocked<td><img src=imgs/blocked.png></td></tr>

</td></tr></table>

<br><br>

</td></tr></table>




</body>
