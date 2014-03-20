#!/usr/bin/php
<?
//$text="BHECEHA CYMMA 30"

if(preg_match("/BHECEHA CYMMA ([0-9]*)/",$text,$res))
{
print_r($res);
$pop=(int)$res[1];
echo "$dongle>$imsi>+$pop";

    if($pop>399)
    {
	system ('/usr/sbin/asterisk -rx "dongle setgroupimsi '.$imsi.' 80"');
	sleep(3);
	system ('(/bin/sleep 79 && /usr/simbox/actions/get_balance.sh '.$dongle.' '.$imsi.')  >>/tmp/exec_php.log 2>>/tmp/exec_php.err &');
    } else {
	system ('(/bin/sleep 107 && /usr/simbox/actions/get_balance.sh '.$dongle.' '.$imsi.')  >>/tmp/exec_php.log 2>>/tmp/exec_php.err &');
	system ('(/bin/sleep 169 && /usr/simbox/actions/get_minutes.sh '.$dongle.' '.$imsi.')  >>/tmp/exec_php.log 2>>/tmp/exec_php.err &');
    }

    //$group=file_get_contents("/var/simbox/sim/settings/$imsi.group");
    //if($group=="210")
    //{
    //	system ('/usr/sbin/asterisk -rx "dongle setgroupimsi '.$imsi.' 109"');
    //}
}

?>