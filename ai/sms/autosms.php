<?


while(1)
{
 $imsilist=file("/var/svistok/lists/imsi.list");

 foreach($imsilist as $k=>$imsi)
 {
    $imsi=trim($imsi);
    $group=file_get_contents("/var/svistok/sim/settings/".$imsi.".group");

    $busy=file_get_contents("/var/svistok/sim/state/$imsi.busy");
    $str_state=file_get_contents("/var/svistok/sim/state/$imsi.str_state");

    echo("\n$imsi -> $group");

  if(($busy!=1)&&($str_state=="Free"))
  {

    if(($group==285)||($group==284)||($group==210)||($group==209)||($group==208))
    //if(($group==285)||($group==284)) //|| ||($group==295)
    {
	echo(" -> group OK");
	system('/usr/simbox/ai/sms/sendsms_imsi.php "'.$imsi.'"');
	//sleep(1);
    } else 

    {
	echo(" -> group !=");
    }
  } else {
	echo(" -> not free !=");
  }
 }
echo("wait before loop\n");
sleep(10);
}


?>