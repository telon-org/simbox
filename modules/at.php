#!/usr/bin/php
<?

function atcommand($command)
{

// return $command;
  return str_replace('"','\"',$command);
}

function exec_at_command($dongle,$command)
{
    $at=atcommand($command);
    $cmd="/usr/sbin/asterisk -rx 'dongle cmd ".$dongle." ".$at."'";
    echo ($cmd."\n");
    $res=system($cmd);

    sleep(1);
}

?>