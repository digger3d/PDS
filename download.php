 <?php

require_once("header.php");
require_once("config.php");

if (!$_POST["submit"]) {
echo "<table bgcolor=\"honeydew\"><tr><td><form method=\"POST\">\n";
$i=1;
$out="";
$handle=opendir("$LOCALWWWROOT/");
while ($file = readdir($handle)) {
	if (!( $file=="." or $file==".." or $file=="cgi-bin" or $file=="apache2-default" )) {
		$out .= "$file \n";
		$hostdir[$i]=$file;
		$ipnr=$LOCALHOSTIPSHIFT+$i;
		$hostline[$i]="\n<tr><td><a href=\"http://$file\">$file</a> $LOCALHOSTIPBASE $ipnr"."</td>\n<td>Download files<input type=\"checkbox\" name=\""."$i"."_fil\" value=\"filedownload\"></td>\n<td> Download database<input type=\"checkbox\" name=\""."$i"."_db\" value=\"dbdownload\"></td></tr>\n";
		echo $hostline[$i];
		$newhosts.="$hostline[$i]\n";
		$i++;
	}
}
closedir($handle);


echo "</td></tr><tr><td><input type=\"submit\" name=\"submit\" value=\"Submit\"></form></td></tr></table><h2>WARNING!!! If you are using MySQL version below 5 the software will not synchronize the database, it will replace it instead</h2>";
} 
else
{
	echo "<table bgcolor=\"honeydew\"><tr><td>";
	$i=1;
	$out="";
	$file="";
	$handle=opendir("$LOCALWWWROOT/");
	while ($file = readdir($handle)) {
	if (!( $file=="." or $file==".." or $file=="cgi-bin" or $file=="apache2-default" )) {
		echo "<br><h4>Scanning $file</h4><br>";
		$bd="$i"."_db";
		$fln="$i"."_fil";
 		if ( $_POST["$fln"] == 'filedownload' ) {
		echo "<br>Downloading $file files<br>\n";
		$deployconf=getmyfile("$file".".conf.php");
		$deployconf = str_replace(";", "", "$deployconf");
		$deployconf = str_replace("$", "", "$deployconf");
		putmyfile("deploy.conf", $deployconf);
		require_once("$file.dbdown.php");
		}
		if ( $_POST["$bd"] == 'dbdownload' ) {
		echo "<br>Downloading $file database<br>\n";
		$deployconf=getmyfile("$file".".conf.php");
		$deployconf = str_replace(";", "", "$deployconf");
		$deployconf = str_replace("$", "", "$deployconf");
		putmyfile("deploy.conf", $deployconf);
		require_once("$file.dbdown.php");
		}
	$i++;
	}
	}
	closedir($handle);
	echo "</td></tr></table>";
}
require_once("footer.php");

?>
