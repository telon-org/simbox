<?
function encodePDU($in) {
$out = "";
for ($i = 0; $i < strlen($in); $i++) {
$t = $i%8+1;
if ($t == 8 )
continue;
$c = ord($in[$i])>>($i%8);
$oc = $c;
$b = ord($in[$i+1]) & ((1 << $t)-1);
$c = ($b << (8-$t)) | $c;
$out .= strtoupper(str_pad(dechex($c), 2, '0', STR_PAD_LEFT));
}
return $out;

}

echo(encodePDU("D6F01C0D1287D961F71C347FCFE9613B3B1F2ED341B3582E0792D7C5ECB2DA05"));
?>