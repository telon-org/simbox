#!/usr/bin/php

<?
//include("/usr/simbox/modules/recog_types_sim.php");
//$uid=$argv[1];
//if (strlen($uid)<=0) die("No uid");
//$imsi=trim(file_get_contents("/var/svistok/sim/state/$uid.imsi"));

$group=trim(file_get_contents("/var/svistok/sim/settings/$imsi.group"));

echo "uid=$uid\n";
echo "imsi=$imsi\n";
echo "group=$group\n";

$txt_pre_in=$pre_in; //@file_get_contents("/var/svistok/sim/log/$uid-pre-in.rasp");
$txt_pre_out=$pre_out; //@file_get_contents("/var/svistok/sim/log/$uid-pre-out.rasp");
$txt_ans_in=$ans_in; //@file_get_contents("/var/svistok/sim/log/$uid-ans-in.rasp");
$txt_ans_out=$ans_out; //@file_get_contents("/var/svistok/sim/log/$uid-ans-out.rasp");

echo("pre_in=$txt_pre_in\n");
echo("pre_out=$txt_pre_out\n");
echo("ans_in=$txt_ans_in\n");
echo("ans_out=$txt_ans_out\n");

function upload_group ($imsi, $group)
{
    $group1=(int)$group;

    $dongle=file_get_contents("/var/svistok/sim/state/$imsi.dongle");
    $iccid=file_get_contents("/var/svistok/dongles/state/$dongle.iccid");
    $iccid1=str_replace('"','',$iccid);
    $imsi1="809".$imsi;


    $url="http://simserver:8122/stat/upload_group.php?imsi=$imsi1&iccid=$iccid1&group=$group1";
    echo("url=$url\n");
    $res=file_get_contents($url);
    echo("res=$res\n");
}

$full_out=$txt_pre_out." ".$txt_ans_out.$txt_pre_in." ".$txt_ans_in;

// до-ре-ми абонент временно заблокирован


//к сожалению ваш номер временно заблокирован пожалуйста обратитесь центр поддержки клиентов билайн по телефону иной 6 1 1 info сотри его из центры блог издаю йоу секс уан
if (strstr($full_out,"сожалению ваш номер")||strstr($full_out,"ваш номер временно заблокирован"))
{
echo "BLOCKED!";
if (($group>=100)&&($group<290)||($group==10))
{
    echo ('/usr/sbin/asterisk -rx "dongle setgroupimsi '.$imsi.' 336"');
    system ('/usr/sbin/asterisk -rx "dongle setgroupimsi '.$imsi.' 336"');
    upload_group ($imsi, 336);
}
}

// beeline номер заблокирован воспользуйтесь нашими возможностями 
if (strstr($full_out,"номер заблокирован воспользуйтесь"))
{
echo "NOMONEY!";
if (($group>=100)&&($group<290)||($group==10))
{
    echo ('/usr/sbin/asterisk -rx "dongle setgroupimsi '.$imsi.' 335"');
    system ('/usr/sbin/asterisk -rx "dongle setgroupimsi '.$imsi.' 335"');
    upload_group ($imsi, 335);
}
}


/********* TELE2 *******/
//tele2 на вашем счёте недостаточно средств для совершения
//        на вашем счете недостаточно средств для смеш
if (strstr($full_out,"на вашем счете")||strstr($full_out,"на вашем счёте")||strstr($full_out,"недостаточно средств"))
{
echo "NOMONEY!";

if ($group==210)
{
    echo ('/usr/sbin/asterisk -rx "dongle setgroupimsi '.$imsi.' 209"');
    system ('/usr/sbin/asterisk -rx "dongle setgroupimsi '.$imsi.' 209"');
} else
if (($group>=100)&&($group<=295))
{
    echo ('/usr/sbin/asterisk -rx "dongle setgroupimsi '.$imsi.' 335"');
    system ('/usr/sbin/asterisk -rx "dongle setgroupimsi '.$imsi.' 335"');
}
}
if (strstr($full_out,"на ваш номер установлено ограничение")||strstr($full_out,"установлено ограничение исходящей"))
{
echo "BLOCKED!";
if (($group>=100)&&($group<=295))
{
    echo ('/usr/sbin/asterisk -rx "dongle setgroupimsi '.$imsi.' 336"');
    system ('/usr/sbin/asterisk -rx "dongle setgroupimsi '.$imsi.' 336"');
}
}


// megafon установлено ограничение
if (strstr($full_out,"установлено ограничение связи"))
{
echo "NOMONEY!";
if (($group>=100)&&($group<=295))
{
    echo ('/usr/sbin/asterisk -rx "dongle setgroupimsi '.$imsi.' 335"');
    system ('/usr/sbin/asterisk -rx "dongle setgroupimsi '.$imsi.' 335"');
}
}

//megafon BLOCKED сумма на вашем счете недостаточно для свершения исходящих вызовов для себя биссектриса набирайте 1 1 2
if (strstr($full_out,"сумма на вашем счете")||strstr($full_out,"для свершения исходящих вызовов"))
{
echo "BLOCKED!";
if (($group>=100)&&($group<=295))
{
    echo ('/usr/sbin/asterisk -rx "dongle setgroupimsi '.$imsi.' 336"');
    system ('/usr/sbin/asterisk -rx "dongle setgroupimsi '.$imsi.' 336"');
}
}

//rostel
//сумма на вашем лицевом счёте недостаточно для соединения набрать номер пожалуйста пополните ваш лицевой счет или воспользуйтесь ус
//
if (strstr($full_out,"на вашем лицевом счёте недостаточно")||strstr($full_out,"недостаточно для соединения")||strstr($full_out,"пополните ваш лицевой счет"))
{
echo "NOMONEY!";
if (($group>=100)&&($group<=295))
{
    echo ('/usr/sbin/asterisk -rx "dongle setgroupimsi '.$imsi.' 335"');
    system ('/usr/sbin/asterisk -rx "dongle setgroupimsi '.$imsi.' 335"');
}
}


// velcom - заблокирован пожалуйста скажите ходила слушать || ваш номер заблокирован
// лицевому счету недостаточно средств 
// решение вызова средств на вашем балансе достаточно рекомендуем пополнить счет
// пожалуйста пополните счет
if (($group==122)&&(strstr($full_out,"заблокирован пожалуйста скажите")||strstr($full_out,"заблокирован пожалуйста свяжитесь")||strstr($full_out,"ваш номер заблокирован")||strstr($full_out,"рекомендуем пополнить счет")||strstr($full_out,"пожалуйста пополните счет")||strstr($full_out,"средств на вашем балансе")))
{
echo "BLOCKED!";
if (($group>=100)&&($group<=295))
{
    echo ('/usr/sbin/asterisk -rx "dongle setgroupimsi '.$imsi.' 336"');
    system ('/usr/sbin/asterisk -rx "dongle setgroupimsi '.$imsi.' 336"');
}
}

// life -  извините у вас нет доступа к услуге пожалуйста обратитесь крачун самоценности
if (strstr($full_out,"извините у вас нет доступа")||strstr($full_out,"извините у вас нету когда")||strstr($full_out,"извините у вас нету что"))
{
echo "BLOCKED!";
if (($group>=100)&&($group<=295))
{
    echo ('/usr/sbin/asterisk -rx "dongle setgroupimsi '.$imsi.' 336"');
    system ('/usr/sbin/asterisk -rx "dongle setgroupimsi '.$imsi.' 336"');
}
}


/*
fa("/var/svistok/sim/log/$imsi.smsussd",$uid." ".$t." ".$result."\n");





function fa($f, $a)
{
//echo($f.">".$a."\n");
$fh = fopen($f,'a') or die("can't open file");
fwrite($fh, $a);
fclose($fh);
}*/
?>