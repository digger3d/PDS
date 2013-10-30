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
	echo "<!DOCTYPE HTML PUBLIC \"-//W3C//DTD HTML 4.01 Transitional//EN\">\n";
	echo "<html>\n";
	echo "<head>\n";
	echo "<title>PDS - Personal Deployment System - the fastest way to administer, deploy and backup several CMSs at once</title>\n";
	echo "\n\n\n</head>\n\n";
	echo "<BODY link=\"#FF0000\" bgColor=\"#ffffff\" topmargin=\"0\" leftmargin=\"20\">\n"
    ."<table border=\"0\" bgcolor=\"#ffffff\"cellpadding=\"0\" width=\"100%\" link=\"#FF0000\"><tr>\n"
    ."<td align=\"left\" width=\"90\" link=\"#FF0000\"><a link=\"#FF0000\" href=\"https://www.paypal.com/row/mrb/pal=2HDVR7G5XAWZS\" target=\"_new\">Free PayPal Account</a><br/>\n";
//Link3
    echo "<a href=\"https://www.e-gold.com/newacct/newaccount.asp?cid=2036288\" target=\"_new\">Free E-gold account</a><br/>\n"
//Link4
    ."<a href=\"http://digger3d.reseller.hop.clickbank.net\" target=\"_new\">Free Clickbank account</a><br/>\n";
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
	echo "<br>$filename is $bytes bytes long, reading ...\n";
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
?><br>
<table width="100%" border="0" cellspacing="0" cellpadding="0" align="center" valign="top" >
<td align="center"  width="12%" height="16"><a href="index.php">PDS</a></td>
<td align="center" width="12%" height="16"><a href="download.php">Update local content</a></td>
<td align="center" width="12%" height="16"><a href="upload.php">Update remote content</a></td>
<td align="center" width="12%" height="16"><a href="deploy.php">Deploy/Synchronize</a></td>
<td align="center" width="12%" height="16"><a href="apache.php">Rescan hosts/Restart apache</a></td>
<td align="center" width="12%" height="16"><a href="setup.php">Global Configuration</a></td>
<td align="center" width="12%" height="16"><a href="faq.php">FAQ</a></td>
<td align="center" width="12%" height="16"><a href="http://www.digger3d.com">Online Support</a></td>
</table>
<table width="100%" border="0" cellspacing="0" cellpadding="0" valign="top" >

</table>
