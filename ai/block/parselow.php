#!/usr/bin/php
<?

if(preg_match("/OCTATOK MEHEE 10p/",$text,$res))
{
$group=trim(file_get_contents("/var/svistok/sim/settings/$imsi.group"));
print_r($res);
echo "$dongle>$imsi>";



if ($group==210)
{
    system ('/usr/sbin/asterisk -rx "dongle setgroupimsi '.$imsi.' 209"');
    system ('(/bin/sleep 60 && /usr/simbox/actions/get_balance.sh '.$dongle.' '.$imsi.')  >>/tmp/exec_php.log 2>>/tmp/exec_php.err &');
}


}

if(preg_match("/Ваш баланс меньше нуля/",$text,$res))
{
$group=trim(file_get_contents("/var/svistok/sim/settings/$imsi.group"));
print_r($res);
echo "$dongle>$imsi>";



if ($group==235)
{
    system ('/usr/sbin/asterisk -rx "dongle setgroupimsi '.$imsi.' 335"');
    system ('(/bin/sleep 60 && /usr/simbox/actions/get_balance.sh '.$dongle.' '.$imsi.')  >>/tmp/exec_php.log 2>>/tmp/exec_php.err &');
}

if ($group==245)
{
    system ('/usr/sbin/asterisk -rx "dongle setgroupimsi '.$imsi.' 337"');
    system ('(/bin/sleep 60 && /usr/simbox/actions/get_balance.sh '.$dongle.' '.$imsi.')  >>/tmp/exec_php.log 2>>/tmp/exec_php.err &');
}


}

if(preg_match("/Баланс менее 30 руб/",$text,$res))
{
$group=trim(file_get_contents("/var/svistok/sim/settings/$imsi.group"));
print_r($res);
echo "$dongle>$imsi>";



if ($group==235)
{
    system ('/bin/sleep 1000 && /usr/sbin/asterisk -rx "dongle setgroupimsi '.$imsi.' 245" &');
    system ('(/bin/sleep 1060 && /usr/simbox/actions/get_balance.sh '.$dongle.' '.$imsi.')  >>/tmp/exec_php.log 2>>/tmp/exec_php.err &');
}


}


?>