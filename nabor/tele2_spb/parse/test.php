#!/usr/bin/php
<?
$text="28.12.2012 18:17 MCK: Y BAC HA HOMEPE +79522183350 OCTATOK MEHEE 10p. KAK PA3rOBAPuBATb nPu 0 HA C4ETE - Y3HAuTE HA *111#";
$dongle="dongle452";

if(preg_match("/OCTATOK MEHEE 10p/",$text,$res))
{
print_r($res);
echo "$dongle>$imsi>";

system ('/usr/sbin/asterisk -rx "dongle setgroupimsi '.$imsi.' 209"');
system ('(/bin/sleep 60 && /usr/simbox/actions/get_balance.sh '.$dongle.' '.$imsi.')  >>/tmp/exec_php.log 2>>/tmp/exec_php.err');
}

?>