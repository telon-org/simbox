#!/usr/bin/php
<?

$list=file("/var/svistok/lists/imsi.list");

foreach($list as $k=>$imsi)
{
$imsi=trim($imsi);
$group=trim(@file_get_contents("/var/svistok/sim/settings/$imsi.group"));

echo("$imsi\n");

if ("$group"=="209")
{
    echo("-> FOUND 209\n");
    system ('/usr/sbin/asterisk -rx "dongle setgroupimsi '.$imsi.' 335"');

}

if ("$group"=="285")
{
    echo("-> FOUND 285\n");
    system ('/usr/sbin/asterisk -rx "dongle setgroupimsi '.$imsi.' 335"');

}

}
?>