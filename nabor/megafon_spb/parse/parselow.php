#!/usr/bin/php
<?

if(preg_match("/((Исходящие вызовы блокированы. Пополните баланс)|(Недостаточно средств на счете для совершения вызова))/",$text,$res))
{
print_r($res);
echo "$dongle>$imsi>";
$group=trim(file_get_contents("/var/svistok/sim/settings/$imsi.group"));

if($group==101)
{
    system ('/usr/sbin/asterisk -rx "dongle setgroupimsi '.$imsi.' 335"');
    system ('(/bin/sleep 76 && /usr/simbox/actions/get_balance.sh '.$dongle.' '.$imsi.')  >>/tmp/exec_php.log 2>>/tmp/exec_php.err &');
}
}

?>