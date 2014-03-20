#!/usr/bin/php
<?
echo("=== Parsing tele2\n");
include("/usr/simbox/nabor/tele2_spb/parse/parsebalance.php");
include("/usr/simbox/nabor/tele2_spb/parse/parsenumber.php");
include("/usr/simbox/nabor/tele2_spb/parse/parsetarif.php");
include("/usr/simbox/nabor/tele2_spb/parse/parseminutes.php");
include("/usr/simbox/nabor/tele2_spb/parse/parsepopolnenie.php");
include("/usr/simbox/nabor/tele2_spb/parse/parselow.php");
include("/usr/simbox/nabor/tele2_spb/parse/parsedover.php");

include("/usr/simbox/nabor/tele2_spb/parse/parseoptions.php");

?>