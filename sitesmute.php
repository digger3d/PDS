 <?php
require_once("/var/www/pds/header.php");
?>
<table width="100%" border="0" cellspacing="0" cellpadding="0" valign="top" >
<?php
function getmyfile ($filename) {
$data="";
	if (!file_exists($filename)) {
		echo "Error : No such file or directory \"".$filename."\"\n";
		echo "Error : config failed\n";
		return FALSE;
	}
	$fp = @fopen($filename, "r");
	if (!$fp) {
		echo "Cannot read file \"".$filename."\"\n";
		echo "Error : config failed\n";
		return FALSE;
	}
	$bytes=filesize($filename);
	echo "<br>$filename is $bytes bytes big, reading ...<br>";
	while ($bytes > 0) {
		$chunk  = fread($fp, $bytes);
		$data  .= $chunk;
	echo "\nAssuming the default directory to be $LOCALWWWROOT/$hostdir[$i]/\n";	$bytes -= strlen($chunk);
	}
	return($data);
};

function putmyfile ($filename, $data) {
	if (!file_exists($filename)) {
		echo `touch $filename`;
		if (!file_exists($filename)) {
			echo "Error : No such file or directory \"".$filename."\"\n";
			echo "Error : Cannot create a temporary file\n";
			return FALSE;
		}
	}
	$fp = @fopen($filename, "w");
	if (!$fp) {
		echo "Cannot write file \"".$filename."\"\n";
		echo "Error : write failed\n";
		return FALSE;
	}
echo "<br>writing $filename ...<br>";
fputs($fp, $data);
fclose($fp);
#return();
};

echo "Locally detected and suggested the following /etc/hosts entries:<pre>";
#$result = explode(" ",`ls -d1 $LOCALWWWROOT/*`);
$i=1;
$out="";
$handle=opendir("$LOCALWWWROOT/");
while ($file = readdir($handle)) {
	if (!( $file=="." or $file==".." or $file=="cgi-bin" or $file=="apache2-default" )) {
		$out .= "$file <br>";
		$hostdir[$i]=$file;
		$ipnr=$LOCALHOSTIPSHIFT+$i;
		$hostline[$i]=$LOCALHOSTIPBASE."$ipnr"." $hostdir[$i]";
		$newhosts.="$hostline[$i]\n";
		require("/var/www/pds/vhost.php");
		$apachehosts.=$vhost[$i];
		$i++;
	}
}
closedir($handle);
echo "applying to /etc/hosts";
/*
 if (!file_exists($LOCALHOSTSFILE)) {
	echo "Error : No such file or directory \"".$LOCALHOSTSFILE."\"\n";
	echo "Error : config failed\n";
	return FALSE;
}
$fp = @fopen($LOCALHOSTSFILE, "r");
if (!$fp) {
	echo "Cannot read file \"".$LOCALHOSTSFILE."\"\n";
	echo "Error : config failed\n";
	return FALSE;
}
$bytes=filesize($LOCALHOSTSFILE);
echo "<br> Hosts file is $LOCALHOSTSFILE and it is $bytes bytes big, reading the file...<br>";
while ($bytes > 0) {
	$chunk  = fread($fp, $bytes);
	$data  .= $chunk;
	$bytes -= strlen($chunk);
}*/
$host = $newhosts;
echo "<Suggesting a new hostlist><pre>";

echo "</pre><br>Parsing $LOCALHOSTSFILE";
$oldhosts=explode("\n",getmyfile($LOCALHOSTSFILE));
$l=0;
while ( $oldhosts[$l]!="127.0.0.1 localhost" ) {
	$l++;
}
while( $l != sizeof($oldhosts) ) {
$host.="$oldhosts[$l]\n";
$l++;
}

echo "<br>$host<br>";
echo "If the following operation will not succeed you might need to change $LOCALHOSTSFILE manually or \`chmod 666 $LOCALHOSTSFILE\` and try again...";
putmyfile("/var/www/pds/vhosts",$host);
echo "attempting to write /etc/hosts";
putmyfile("/etc/hosts",$host);
putmyfile("/var/www/pds/apachevhosts",$apachehosts);
#echo `/var/www/pds/applyvhosts.sh /var/www/pds/vhosts $LOCALHOSTSFILE`;
#echo `/etc/init.d/apache2 -k restart`;














/*

$handle=fopen("$LOCALHOSTSFILE",'w');
if (!$handle) {
	echo "Trying to gain write access\n<br>";
	echo `chmod 666 $LOCALHOSTSFILE`;
	$handle=fopen("$LOCALHOSTSFILE",'w');
	if (!$handle) {
		echo ("Write access to $LOCALHOSTSFILE was denied, tried chmod, trying root access...");
			echo `ssh root:$LOCALSSHPASSWORD@localhost chmod 666 $LOCALHOSTSFILE`;
			$handle=fopen("$LOCALHOSTSFILE",'w');
			if (!$handle) {
				echo "Write access to $LOCALHOSTSFILE was denied, giving up ..."
				."<br> check LOCALSSHPASSWORD, it should be a root password";
			}
	}
}
	fputs($handle,$config);
	fclose($handle);

*/









/*

 echo "$i potential hosts found, checking /etc/hosts for matching...<br>";

 if (!file_exists($LOCALHOSTSFILE)) {
		echo "Error : No such file or directory \"".$LOCALHOSTSFILE."\"\n";
		echo "Error : config failed\n";
		return FALSE;
	}

	$fp = @fopen($LOCALHOSTSFILE, "r");
	if (!$fp) {
		echo "Cannot read file \"".$LOCALHOSTSFILE."\"\n";
		echo "Error : config failed\n";
		return FALSE;
	}
	$bytes=filesize($LOCALHOSTSFILE);
echo "<br> Hosts file is $LOCALHOSTSFILE and it is $bytes bytes big, reading the file...<br>";
      while ($bytes > 0) {
        $chunk  = fread($fp, $bytes);
        $data  .= $chunk;
        $bytes -= strlen($chunk);
      }
 $host = explode("\n",$data);
 $j=1;
 $k=1;
 echo "<br>About to check the hosts list for matching, if it does not match with the list above I will suggest a new $LOCALHOSTSFILE<br>";
$hostline=$LOCALHOSTIPBASE.$LOCALHOSTIPSHIFT+$j." $hostdir[$j]";
$ipnr=$LOCALHOSTIPSHIFT+$j;
$hostline=$LOCALHOSTIPBASE."$ipnr"." $hostdir[$j]";
echo "<br>The first line should be $hostline <br>";

 while ($j<$i){
	echo "<br>Examining for $hostdir[$j]<br>";
	while ($k<$i){
		$ipnr=$LOCALHOSTIPSHIFT+$j;
		$hostline=$LOCALHOSTIPBASE."$ipnr"." $hostdir[$j]";
		echo "<br> $hostline <br>";
		if ($hostline==$host[$k]){
			$newhost[$j]=$hostline;
			echo "<br>Match $host[$k] found<br> To force PDS to rebui";
		}
		$k++;
	}
	$j++;
}
 */
 ?>
</table>
<?php
require_once("footer.php");
?>
