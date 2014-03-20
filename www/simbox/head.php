<?
header('Content-Type: text/html; charset=utf-8');

include("modules/html.php");


//wh = svistok || simbox
/*
function getfileis(wh,devtype, fileitem, filetype, value)
{

}

function getfileis_def(wh,devtype, fileitem, filetype, value)
{

}

function putfileis(wh,devtype, fileitem, filetype, value)
{

}
*/

function acd($sec, $cnt)
{
 if($cnt==0) return 0;
 return $sec/$cnt;
}

function minsec($sec)
{
    return round(($sec/60),2);
}

function file_get_contents_def($filename,$def)
{
$res=@file_get_contents($filename);
if($res=="")
    {
        file_put_contents($filename,$def);
        $res=$def;
    }
    return $res;
}


function file_get_contents_def2($filename,$def)
{
$res=@file_get_contents($filename);
$res=trim($res);
if($res=="")
    {
        $res=$def;
    }
    return $res;
}

function exec_s($cmd)
{
//    $cmd=mysql_real_escape_string($cmd);
    $return=system("sudo ".$cmd);
}


function exec_fon($cmd)
{
//    $cmd=mysql_real_escape_string($cmd);
    $return=system("sudo ".$cmd." >/dev/null & >/dev/null");
}

function exec_delay($cmd)
{
//echo(@$_POST['delay_rnd']);
//die();
//echo ("12355");
    if(@$_POST['delay_rnd']>0)
    {
        $rnd=(rand()%@$_POST['delay_rnd'])+@$_POST['delay_min'];
        if ($rnd<=0) $rnd=1;
        
	    str_replace($cmd,'"','\"'); 
	    //>> /tmp/exec_delay.log
	    $cmd="( /bin/sleep $rnd && sudo $cmd ) >>/tmp/exec.log 2>>/tmp/exec.err &";
//	    $cmd="( sleep $rnd && sudo $cmd > /dev/null ) & >/dev/null 2>/dev/null";
	    //echo($cmd);
	    //$return=exec($cmd);
	    //echo $return;
	    exec_br($cmd);
	    return "";
    } else
    {
//	echo $cmd;
//        $return=system("sudo ".$cmd);
//	echo $return;
	$cmd="sudo $cmd";
	exec_br($cmd);

	return "";
    }
}


function exec_br($cmd)
{
    echo($cmd."<hr>\n");
    exec ($cmd,$res);
    foreach($res as $key=>$line) echo($line."<br>\n");
    echo("<hr><br>\n");
}

        
        
        
?>
<head>
<?
if(@$_GET['p']=="diagmode")
{
?>
<META HTTP-EQUIV="REFRESH" CONTENT="5">
<?
}
//
?>
<link rel="SHORTCUT ICON" HREF="favicon.ico">
<style>
table{
	border:1px solid blue;
	border-collapse:collapse;
}
td{
	padding:3px;
	white-space:nowrap;
}
.header{
	background-color:#eeeeff;
}
.zebra{
	background-color:#eeeeff;
}


#tooltip {

    padding: 4px;

    background-color: #eee;

    border: 1px solid #000;

    text-align: center;

    font-size: 13px;

    z-index:999}






</style>

<script src="jq/jquery-1.7.2.min.js"></script>
<script src="jq/bootstrap-tooltip.js"></script>


<script type='text/javascript'>
jQuery(function(){
$(function(){
$('.tooltip_file').each(function(){
  var elem = $(this);
  var local_path=elem.attr('data-local');
  $.get(local_path,{},function(data){
    elem.attr('title',data);
  });
});
$('.tooltip_file').tooltip();
});
});
</script>


<script type='text/javascript'>
function SelAll(elem) {
    var objall=elem
        var obj=document.getElementsByTagName("INPUT")
    for (i=0; i<obj.length; i++) {
    if(obj[i].className.indexOf('id') != -1)
    {
        obj[i].checked=objall.checked;
    }
    }
    }
    </script>


<SCRIPT LANGUAGE="JavaScript">

<!--




var x=0;

var y=0;

var xx = 12;

var yy =  10;

var thetooltip = 0;

var t;



function e(i){ 

        var d = document.createElement('div'); 

        d.id = i;     

        d.style.display = 'none';

        d.style.position = 'absolute';

        d.innerHTML = ""; 

        document.body.appendChild(d);}



function wherecursor(e){

        t = document.getElementById('tooltip');

	if (!e) var e = window.event;

	if (e.pageX){x = e.pageX;y = e.pageY;}

	else if (e.clientX){x = e.clientX + document.body.scrollLeft;y = e.clientY + document.body.scrollTop;}

        t.style.left = (x+xx) + 'px';

        t.style.top = (y+yy) + 'px';}



function tooltip(thetooltip){

    if(!document.getElementById('tooltip')) e('tooltip');

    t = document.getElementById('tooltip');

    Ajax(thetooltip);

    t.style.display = 'block';

    t.style.left = '-1999px';

    document.onmousemove = wherecursor;}


function tooltip2(thetooltip){

    if(!document.getElementById('tooltip')) e('tooltip');

    t = document.getElementById('tooltip');

    Ajax2(thetooltip);

    t.style.display = 'block';

    t.style.left = '-1999px';

    document.onmousemove = wherecursor;}

function tooltip3(thetooltip){

    if(!document.getElementById('tooltip')) e('tooltip');

    t = document.getElementById('tooltip');

    Ajax3(thetooltip);

    t.style.display = 'block';

    t.style.left = '-1999px';

    document.onmousemove = wherecursor;}




function Ajax(thetooltip){

var tm = new Date().getTime();

if (window.XMLHttpRequest){ // code for IE7+, Firefox, Chrome, Opera, Safari

xmlhttp=new XMLHttpRequest();

}else{ // code for IE6, IE5

xmlhttp=new ActiveXObject("Microsoft.XMLHTTP");}

xmlhttp.onreadystatechange=function(){

if (xmlhttp.readyState==4 && xmlhttp.status==200){

t.innerHTML=xmlhttp.responseText;}}

xmlhttp.open("GET","showlog_cut.php?imsi="+thetooltip+"&tm="+tm,true);

xmlhttp.send();}


function Ajax2(thetooltip){

var tm = new Date().getTime();

if (window.XMLHttpRequest){ // code for IE7+, Firefox, Chrome, Opera, Safari

xmlhttp=new XMLHttpRequest();

}else{ // code for IE6, IE5

xmlhttp=new ActiveXObject("Microsoft.XMLHTTP");}

xmlhttp.onreadystatechange=function(){

if (xmlhttp.readyState==4 && xmlhttp.status==200){

t.innerHTML=xmlhttp.responseText;}}

xmlhttp.open("GET","showlog_cut.php?imsi="+thetooltip+"&calls=1&tm="+tm,true);

xmlhttp.send();}


function Ajax3(thetooltip){

var tm = new Date().getTime();

if (window.XMLHttpRequest){ // code for IE7+, Firefox, Chrome, Opera, Safari

xmlhttp=new XMLHttpRequest();

}else{ // code for IE6, IE5

xmlhttp=new ActiveXObject("Microsoft.XMLHTTP");}

xmlhttp.onreadystatechange=function(){

if (xmlhttp.readyState==4 && xmlhttp.status==200){

t.innerHTML=xmlhttp.responseText;}}

xmlhttp.open("GET","showlog_cut.php?dongle="+thetooltip+"&mode=laccell&tm="+tm,true);

xmlhttp.send();}



function bye(){document.getElementById('tooltip').style.display = 'none';}



// -->

</script>



</head>
<body>



SimServer <?=$_SERVER['SERVER_NAME']?> <?=date("H:i:s d.m.y")?>
<br><br>
<a href="?p=sim">Симки</a> :: 
<a href="?p=dongle">Свистки (nm)</a> :: 
<a href="?p=diagmode">Свистки (um)</a> :: 
<a href="?p=readers">Ридеры</a> :: 
<a href="?p=adapters">Адаптеры</a> :: 
<a href="?p=hubs">Хабы</a> :: 
<a href="?p=calls">Звонки</a> :: 
<a href="?p=qos">Качество</a> :: 

<a href="?p=multisim">Мульти-сим</a> :: 
<a href="?p=bs">Вышки</a> :: 
<a href="?p=nabor">Наборы команд</a> :: 
<a href="?p=plan">Планы</a> :: 
<a href="?p=nagruz">Нагрузка</a> :: 
<a href="?p=proc">Процессы</a> :: 
<a href="?p=upgrade">Обновление</a> :: 
<a href="?p=firmware">Перепрошивка</a> :: 
<a href="?p=bablo">Биллинг</a> :: 
<a href="?p=settings">Настройка</a> :: 
<a href="?p=version">Версия</a> :: 
<a href="?p=debug">Debug</a>
<hr>
<?
$path0='/var/log/asterisk';

$path_svistok='/var/svistok/';
$path_svistok_dongles='/var/svistok/dongles/';
$path_svistok_dongles_state='/var/svistok/dongles/state/';

$path_svistok_bs='/var/svistok/bs/';
$path_svistok_bs_state='/var/svistok/bs/state/';
$path_svistok_bs_settings='/var/svistok/bs/settings/';

$path_svistok_sim='/var/svistok/sim/';
$path_svistok_sim_settings='/var/svistok/sim/settings/';
$path_svistok_sim_state='/var/svistok/sim/state/';
$path_svistok_sim_statistics='/var/svistok/sim/statistics/';
$path_svistok_sim_limits='/var/svistok/sim/limits/';

$path_simbox='/var/simbox/';
$path_simbox_sim='/var/simbox/sim/';
$path_simbox_sim_settings='/var/simbox/sim/settings/';
$path_simbox_sim_state='/var/simbox/sim/state/';
$path_simbox_sim_statistics='/var/simbox/sim/statistics/';
$path_simbox_plan='/var/simbox/plan/';

$file_naborlist='/usr/simbox/nabor/nabor.list';



?>
<center>
