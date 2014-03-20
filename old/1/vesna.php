<?
for($i=0;$i<1000;$i++)
{
$a=file_get_contents('http://vesna.yandex.ru/literature.xml');
preg_match('|<\/h1>(.*)<\/div>|isU',$a,$r);
$txt=explode('.',str_replace(array("\r","\n"),'',trim(strip_tags($r[1]))));
foreach($txt as $i=>$v){
 $l=mb_strlen($v);

 if($l<20)unset($txt[$i]);
 if($l>70){
  $txt[$i]=ltrim($txt[$i]);
  list($txt[$i])=explode(',',$v);
  if(mb_strlen($txt[$i])<20)unset($txt[$i]);
 }
 #else $txt[$i]=$v;
}
$txt=implode("\n",$txt);
file_put_contents('test.txt',$txt,FILE_APPEND | LOCK_EX);

//sleep(2);
}
?>