<?
function dirsize( $d )
{
 $count = 0;  
 $dh = opendir( $d );
  while( ( $f = readdir( $dh ) ) !== false )
   {
    if ( $f != "." && $f != ".." )
     {
      $path = $d . "/" . $f;
      if( is_file( $path ) )
       {  $count++;  }
     }
   }
  closedir($dh);
  return $count;
}
dirsize("./" , 0);
?>


<h1>Прошивки</h1>

<table>
<tr class="header">
<td colspan=2>
Количество прошивок
</td></tr>
<tr><td>e173</td><td><?=dirsize("/var/svistok/firmware/173/");?></td></tr>
<tr><td>1550</td><td><?=dirsize("/var/svistok/firmware/1550/");?></td></tr>
</table>


</table>
 