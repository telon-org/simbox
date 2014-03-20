#!/usr/bin/php
<?

/*
$dir = "/var/simbox/sim/state/";
$files = scandir($dir);
array_shift($files);
array_shift($files);
for($i=0; $i<sizeof($files); $i++)
{
if (strstr($files[$i],".balance")!=FALSE)
{
$imsi=str_replace(".balance","",$files[$i]);
echo($imsi."\n");
$bal[$]
}
}
*/


/*

list=`ls /var/simbox/sim/state/ | grep ".balance" | sed 's/.balance//g'`

for imsi in $list
do
balance=`cat /var/simbox/sim/state/$imsi.balance`
bal_last=`cat /var/simbox/sim/state/$imsi.bal_last`

bal_diff=`echo "($balance-1+1)-($bal_last-1+1)" | bc`

if [ $bal_diff -gt "0" ] ; then
bal_plus=`cat /var/simbox/sim/state/$imsi.bal_plus`
#echo "$bal_plus-1+1+$bal_diff"
bal_plus=`echo "$bal_plus-1+1+$bal_diff" | bc`
#exit
echo "$bal_plus" > /var/simbox/sim/state/$imsi.bal_plus
fi

if [ "0" -gt $bal_diff ] ; then
bal_minus=`cat /var/simbox/sim/state/$imsi.bal_minus`
#echo "$bal_minus-1+1-($bal_diff)" | bc
bal_minus=`echo "$bal_minus-1+1-($bal_diff)" | bc`
#exit
echo "$bal_minus" > /var/simbox/sim/state/$imsi.bal_minus
fi

cp /var/simbox/sim/state/$imsi.balance /var/simbox/sim/state/$imsi.bal_last

done
*/

?>