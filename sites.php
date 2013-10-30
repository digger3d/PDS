 <?php
 /************************************************************************/
/* Personal Deployment System 			                       	*/
/* ===========================                                        	*/
/*                                                                 	*/
/* Copyright (c) 2008 by Anton Volkonskiy                          	*/
/* http://digger3d.com							*/
/*                                                                 	*/
/* This program is free software. You can redistribute it and/or modify */
/* it under the terms of the GNU General Public License as published by */
/* the Free Software Foundation; either version 2 of the License.       */
/************************************************************************/
require_once("/var/www/pds/config.php");
/*
function getmyfile ($filename) {
$data="";
	if (!file_exists($filename)) {
		echo "Error : No such file or directory \"".$filename."\"\n";
		echo "Error : config failed\n";
		die ("Cannot read file \"".$filename."\"\n");
		return FALSE;
	}
	$fp = @fopen($filename, "r");
	if (!$fp) {
		echo "Cannot read file \"".$filename."\"\n";
		echo "Error : config failed\n";
		die ("Cannot read file \"".$filename."\"\n");
		return FALSE;
	}
	$bytes=filesize($filename);
	echo "<br>$filename is $bytes bytes big, reading ...\n";
	while ($bytes > 0) {
		$chunk  = fread($fp, $bytes);
		$data  .= $chunk;
//		echo "\nAssuming the default directory to be $LOCALWWWROOT/$hostdir[$i]/\n";	
		$bytes -= strlen($chunk);
	}
	return($data);
};

function putmyfile ($filename, $data) {
	if (!file_exists($filename)) {
		echo `touch $filename`;
		if (!file_exists($filename)) {
			echo "Error : No such file or directory \"".$filename."\"\n";
			echo "Error : Cannot create a file $filename\n";
			die ("Cannot create file \"".$filename."\"\n");
			return FALSE;
		}
	}
	$fp = @fopen($filename, "w");
	if (!$fp) {
		echo "Cannot write file \"".$filename."\"\n";
		echo "Error : write failed\n";
		die ("Cannot write file \"".$filename."\"\n");
		return FALSE;
	}
echo "\nwriting $filename ...\n";
fputs($fp, $data);
fclose($fp);
};
*/
echo "Locally detected and suggested the following /etc/hosts entries:\n";

$i=1;
$out="";
$handle=opendir("$LOCALWWWROOT/");
	
$config=explode("\n",getmyfile("setup.php"));
$confdat=explode("\n",getmyfile("config.php"));
while ($file = readdir($handle)) {
// In this cycle we are walking making a list of hosts and creating apache vhosts files on the fly
// Also creating admin interface for the existing hosts using code modification
	if (!( $file=="." or $file==".." or $file=="cgi-bin" or $file=="apache2-default" )) {

		$out .= "$file \n";
		$hostdir[$i]=$file;
		$ipnr=$LOCALHOSTIPSHIFT+$i;
		$hostline[$i]=$LOCALHOSTIPBASE."$ipnr"." $hostdir[$i]";
		$newhosts.="$hostline[$i]\n";
		if (!file_exists("$file.php")) {
			require("vhost.php");
			putmyfile("/etc/apache2/sites-enabled/000-$file",$vhost[$i]);
			$config[2]="require_once(\"$file.conf.php\");";
			$config[3]='$conffile='."\"$file.conf.php\";";
			putmyfile("/var/www/pds/$file.php", implode("\n",$config));
			$confdat[2]='$setup='."\"$file.php\";\n";
			$confdat[3]='$conffile='."\"$file.conf.php\";";
			putmyfile("/var/www/pds/$file.conf.php", implode ("\n",$confdat));
		}
// don't need it for apache2
//		$apachehosts.=$vhost[$i];
		$i++;
	}
}
closedir($handle);
echo "applying to /etc/hosts";


$host = $newhosts;
echo "\nSuggesting a new hostlist\n";

echo "\nParsing $LOCALHOSTSFILE\n";
$oldhosts=explode("\n",getmyfile($LOCALHOSTSFILE));
$l=0;
while ( $oldhosts[$l]!="127.0.0.1	localhost" ) {
	$l++;
}
while( $l != sizeof($oldhosts) ) {
$host.="$oldhosts[$l]\n";
$l++;
}
//do not need it anymore
//putmyfile("/var/www/pds/vhosts",$host);
echo "attempting to write /etc/hosts";
putmyfile("/etc/hosts",$host);

//putmyfile("/var/www/pds/apachevhosts",$apachehosts);
/*
echo "\nParsing /etc/init.d/apache2\n";
$sscript=explode("\n",getmyfile("/etc/init.d/apache2"));
$l=0;

while( $l != sizeof($sscript) ) {
	if ($sscript[$l]!='		if $APACHE2CTL start; then') {
		$newscript.="$sscript[$l]\n";
	}
	else
	{
		$newscript.="$sscript[$l]\n"."		php5</var/www/pds/sites.php\n";
	}
	$l++;
}

putmyfile("/etc/init.d/apache2",$newscript);
*/
echo "\nChmoding config.php to enable configuration change\n";
echo `chmod 777 /var/www/pds`;
echo `'chmod 777 /var/www/pds/*.conf.php'`;

echo "Refresh local hosts is completed.\n";

?>
/*
require_once("/var/www/pds/config.php");
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
	echo "<br>$filename is $bytes bytes, reading ...<br>";
	while ($bytes > 0) {
		$chunk  = fread($fp, $bytes);
		$data  .= $chunk;
//		echo "\nAssuming the default directory to be $LOCALWWWROOT/$hostdir[$i]/\n";	
		$bytes -= strlen($chunk);
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

//echo "Locally detected and suggested the following /etc/hosts entries:<pre>";
#$result = explode(" ",`ls -d1 $LOCALWWWROOT/*`);
$i=1;
$out="";
$handle=opendir("$LOCALWWWROOT/");
	
$config=explode("\n",getmyfile("setup.php"));
$confdat=explode("\n",getmyfile("config.php"));
while ($file = readdir($handle)) {
// In this cycle we are walking making a list of hosts and creating apache vhosts files on the fly
	if (!( $file=="." or $file==".." or $file=="cgi-bin" or $file=="apache2-default" )) {

		$out .= "$file \n";
		$hostdir[$i]=$file;
		$ipnr=$LOCALHOSTIPSHIFT+$i;
		$hostline[$i]=$LOCALHOSTIPBASE."$ipnr"." $hostdir[$i]";
		$newhosts.="$hostline[$i]\n";
		if (!file_exists("$file.php")) {
			require("vhost.php");
			putmyfile("/etc/apache2/sites-enabled/000-$file",$vhost[$i]);
			$config[2]="require_once(\"$file.conf.php\");";
			$config[3]='$conffile='."\"$file.conf.php\";";
			$config[99]='     echo "<tr><h1> View/edit site '.$file.' PDS configuration/settings. </h1><br>"';
			putmyfile("$file.php", implode("\n",$config));
			$confdat[2]='$setup='."\"$file.php\";\n";
			$confdat[3]='$conffile='."\"$file.conf.php\";";
			putmyfile("$file.conf.php", implode ("\n",$confdat));
		}
// don't need it for apache2
//		$apachehosts.=$vhost[$i];
		$i++;
	}
}
closedir($handle);
echo "applying to /etc/hosts";


$host = $newhosts;
echo "\nSuggesting a new hostlist\n";

echo "\nParsing $LOCALHOSTSFILE\n";
$oldhosts=explode("\n",getmyfile($LOCALHOSTSFILE));
$l=0;
while ( $oldhosts[$l]!="127.0.0.1	localhost" ) {
	$l++;
}
while( $l != sizeof($oldhosts) ) {
$host.="$oldhosts[$l]\n";
$l++;
}

echo "attempting to write /etc/hosts";
putmyfile("/etc/hosts",$host);
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
