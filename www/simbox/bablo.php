
<h1>Биллинг</h1>


<form action="<?=$_SERVER['REQUEST_URI'];?>" method="post">
<table>
<tr class="header">
<td>Дата</td>
<td>Направление</td>
<td>Минуты</td>
<td>Деньги</td>
</tr>

<?

$total_minutes=0;
$total_dengi=0;

$files = scandir("/var/svistok/sim/statistics/billing");
array_shift($files); // удаляем из массива '.'
array_shift($files); // удаляем из массива '..'

for($i=0; $i<sizeof($files); $i++)
{
$s=split('\.',$files[$i]);
//print_r($s);
$d=$s[0];
$billing_direction=$s[1];
$m=minsec(file_get_contents_def2("/var/svistok/sim/statistics/billing/".$files[$i],"0"));
$cena=0;
if($billing_direction=="system") {$pic="<img src=imgs/state_sout.png>"; $cena=0;}


if($billing_direction=="HZ") {$pic="<img src=imgs/napravleine/hz.ico>hz"; $cena=0.015;}
if($billing_direction=="BM") {$pic="<img src=imgs/napravleine/beeline_msk.ico>"; $cena=0.02;}
if($billing_direction=="BS") {$pic="<img src=imgs/napravleine/beeline_spb.ico>"; $cena=0.02;}
if($billing_direction=="BR") {$pic="<img src=imgs/napravleine/beeline_ru.ico>"; $cena=0.02;}

if($billing_direction=="NM") {$pic="<img src=imgs/napravleine/megafon_msk.ico>"; $cena=0.015;}
if($billing_direction=="NS") {$pic="<img src=imgs/napravleine/megafon_spb.ico>"; $cena=0.015;}
if($billing_direction=="NR") {$pic="<img src=imgs/napravleine/megafon_ru.ico>"; $cena=0.015;}

if($billing_direction=="SM") {$pic="<img src=imgs/napravleine/mts_msk.ico>"; $cena=0.02;}
if($billing_direction=="SS") {$pic="<img src=imgs/napravleine/mts_spb.ico>"; $cena=0.02;}
if($billing_direction=="SR") {$pic="<img src=imgs/napravleine/mts_ru.ico>"; $cena=0.02;}
if($billing_direction=="SU") {$pic="<img src=imgs/napravleine/mts_u.ico>"; $cena=0.02;}
if($billing_direction=="SB") {$pic="<img src=imgs/napravleine/mts_by.ico>"; $cena=0.10;}

if($billing_direction=="TS") {$pic="<img src=imgs/napravleine/tele2_spb.ico>"; $cena=0.02;}

if($billing_direction=="KU") {$pic="<img src=imgs/napravleine/kievstar.ico>"; $cena=0.05;}

if($billing_direction=="VB") {$pic="<img src=imgs/napravleine/velcom_by.ico>"; $cena=0.10;}
if($billing_direction=="PB") {$pic="<img src=imgs/napravleine/proper_minsk.ico>"; $cena=0.10;}

if($billing_direction=="billing_direction") {$pic="<img src=imgs/napravleine/hz.ico>total_old"; $cena=0.015;}

$den=round($m*$cena,2);
$total_dengi+=$den;
$total_minutes+=$m;
?>
<tr <?if($i%2==0)echo 'class="zebra"';?>>
<td><?=$d;?></td>
<td><?=$pic;?></td>
<td><?=$m;?></td>
<td><?=$den;?></td>


<?
}
?>

<tr class="header">
<td>Всего</td>
<td></td>
<td><?=$total_minutes?></td>
<td><?=$total_dengi?></td>
</tr>

</table>



</form>
