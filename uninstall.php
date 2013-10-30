 <?php
/************************************************************************/
/* Personal Deployment System 	27-05-2008		                       	*/
/* ===========================  Release                                      	*/
/*                                                                 	*/
/* Copyright (c) 2008 by Anton Volkonskiy                          	*/
/* http://digger3d.com							*/
/*                                                                 	*/
/* This program is free software. You can redistribute it and/or modify */
/* it under the terms of the GNU General Public License as published by */
/* the Free Software Foundation; either version 2 of the License.       */
/************************************************************************/
require_once("/var/www/pds/config.php");

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

echo "Removing not default vhosts from /etc/apache2/sites-enabled/";
$handle=opendir("/etc/apache2/sites-enabled/");
while ($file = readdir($handle)) {
	if (!( $file=="." or $file==".." or $file=="cgi-bin" or $file=="000-default" )) {
		unlink("/etc/apache2/sites-enabled/$file");
		if (file_exists("/etc/apache2/sites-enabled/$file")) { 
			echo "Can't delete $file, probably need root privileges, trying shell...";
			echo `rm /etc/apache2/sites-enabled/$file`; 
		}
		echo "/etc/apache2/sites-enabled/$file deleted";
	}
}
closedir($handle);

echo "Cleaning $LOCALHOSTSFILE";

$oldhosts=explode("\n",getmyfile($LOCALHOSTSFILE));
$l=0;
while ( $oldhosts[$l]!="127.0.0.1	localhost" ) {
	$l++;
}
while( $l != sizeof($oldhosts) ) {
$host.="$oldhosts[$l]\n";
$l++;
}
echo "attempting to write a clean /etc/hosts";
putmyfile("/etc/hosts",$host);

echo "\nParsing /etc/init.d/apache2\n";
$sscript=explode("\n",getmyfile("/etc/init.d/apache2"));
$l=0;
while( $l != sizeof($sscript) ) {
	if ($sscript[$l]!='		php5</var/www/pds/sites.php') {
		$newscript.="$sscript[$l]\n";
	}
	$l++;
}
putmyfile("/etc/init.d/apache2",$newscript);

echo "Deinstallation completed.\n";
echo "You can delete /var/www/pds directory now.\n";
echo "Or reinstall it by executing /var/www/pds/install.sh \n";

?>
