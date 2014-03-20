#!/usr/bin/php
<?

if(preg_match("/OCTATOK MEHEE 10p/",$text,$res))
{
$group=trim(file_get_contents("/var/svistok/sim/settings/$imsi.group"));
print_r($res);
echo "$dongle>$imsi>";



if ($group==210)
{
#    system ('/usr/sbin/asterisk -rx "dongle setgroupimsi '.$imsi.' 209"');
#    system ('(/bin/sleep 60 && /usr/simbox/actions/get_balance.sh '.$dongle.' '.$imsi.')  >>/tmp/exec_php.log 2>>/tmp/exec_php.err &');
}


}

?>