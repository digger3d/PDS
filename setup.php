 <?php
#Do not touch any lines between this comments it is for self modification to work properly
require_once("config.php");
$conffile="/var/www/pds/config.php";
#Do not touch any lines in this file this comments it is for self modification to work properly

#Do not touch this comment it is for self modification to work properly
require_once("header.php");
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

if (!$_POST["submit"]) {
echo "<table bgcolor=\"honeydew\"><tr><td>";
echo "</td><td align=\"center\">";
$i=1;
$out="";
$handle=opendir("$LOCALWWWROOT/");
while ($file = readdir($handle)) {
	if (!( $file=="." or $file==".." or $file=="cgi-bin" or $file=="apache2-default" )) {
		$out .= "$file \n";
		$hostdir[$i]=$file;
		$ipnr=$LOCALHOSTIPSHIFT+$i;
		$hostline[$i]="<tr><td><a href=\"http://$file\">$file</a> $LOCALHOSTIPBASE $ipnr"."</td><td><a href=\"".$file.".php\">Edit</a></td></tr>";
		echo $hostline[$i];
		$newhosts.="$hostline[$i]\n";
		$i++;
	}
}
closedir($handle);

echo "</td><td align=\"center\"></td></tr></table>";
}
else
{
echo "editing ";
}
 #phpinfo();
 $op=$_POST["op"];
if($_POST["op"]){
$config="<?php"."\n\n"
.'$setup="'."$setup\";\n\n"
.'$SCHEDULEDRUN="'.$_POST["SCHEDULEDRUN"].'";'."\n"
.'$REMOTEWWWROOT="'.$_POST["REMOTEWWWROOT"].'";'."\n"
.'$REMOTESSHHOST="'.$_POST["REMOTESSHHOST"].'";'."\n"
.'$REMOTESTORAGESELECTION="'.$_POST["REMOTESTORAGESELECTION"].'";'."\n"
.'$REMOTEDIRSELECTION="'.$_POST["REMOTEDIRSELECTION"].'";'."\n"
.'$REMOTEDBSELECTION="'.$_POST["REMOTEDBSELECTION"].'";'."\n"
.'$REMOTESSHUSER="'.$_POST["REMOTESSHUSER"].'";'."\n"
.'$REMOTESSHPASSWORD="'.$_POST["REMOTESSHPASSWORD"].'";'."\n"
.'$REMOTEROOTPWD="'.$_POST["REMOTEROOTPWD"].'";'."\n"
.'$REMOTEMYSQLUSER="'.$_POST["REMOTEMYSQLUSER"].'";'."\n"
.'$REMOTEMYSQLPASSWORD="'.$_POST["REMOTEMYSQLPASSWORD"].'";'."\n"
.'$REMOTEMYSQLHOST="'.$_POST["REMOTEMYSQLHOST"].'";'."\n"
.'$REMOTEMYSQLPATH="'.$_POST["REMOTEMYSQLPATH"].'";'."\n"
.'$REMOTEMEDIADIR="'.$_POST["REMOTEMEDIADIR"].'";'."\n"
.'$REMOTEMYSQLROOTPWD="'.$_POST["REMOTEMYSQLROOTPWD"].'";'."\n"
.'$LOCALDIRSELECTION="'.$_POST["LOCALDIRSELECTION"].'";'."\n"
.'$LOCALSTORAGESELECTION="'.$_POST["LOCALSTORAGESELECTION"].'";'."\n"
.'$LOCALMEDIADIR="'.$_POST["LOCALMEDIADIR"].'";'."\n"
.'$LOCALWWWROOT="'.$_POST["LOCALWWWROOT"].'";'."\n"
.'$LOCALDBSELECTION="'.$_POST["LOCALDBSELECTION"].'";'."\n"
.'$LOCALTARFILENAME="'.$_POST["LOCALTARFILENAME"].'";'."\n"
.'$LOCALMYSQLHOST="'.$_POST["LOCALMYSQLHOST"].'";'."\n"
.'$LOCALMYSQLUSER="'.$_POST["LOCALMYSQLUSER"].'";'."\n"
.'$LOCALMYSQLPASSWORD="'.$_POST["LOCALMYSQLPASSWORD"].'";'."\n"
.'$CROSSDEPLOY="'.$_POST["CROSSDEPLOY"].'";'."\n"
.'$BACKDEPLOY="'.$_POST["BACKDEPLOY"].'";'."\n"
.'$STORELOCALLY="'.$_POST["STORELOCALLY"].'";'."\n"
.'$FORCEUPLOAD="'.$_POST["FORCEUPLOAD"].'";'."\n"
.'$LOCALHOSTSFILE="'.$_POST["LOCALHOSTSFILE"].'";'."\n"
.'$LOCALHOSTIPBASE="'.$_POST["LOCALHOSTIPBASE"].'";'."\n"
.'$LOCALHOSTIPSHIFT="'.$_POST["LOCALHOSTIPSHIFT"].'";'."\n"
.'$LOCALSSHPASSWORD="'.$_POST["LOCALSSHPASSWORD"].'";'."\n"
.'$LOCALTEMPDIR="'.$_POST["LOCALTEMPDIR"].'";'."\n"
."?>";
$handle=fopen($conffile,'w');
if (!$handle) {
     echo "Trying to gain write access\n<br>";
     die("Write access was denied, go back and try again"); 
}
fputs($handle,$config);
echo "Configuration is successefully written to $conffile ...";
fclose($handle);
}
else {
?>
<table width="100%" border="0" align="left" >
<?php
# 
# the following line should be line nr. 100, otherwise it will not work
     echo "<tr><h1> View/edit GLOBAL PDS configuration/settings. Applied to newly created websites. </h1><br>"
     ." Some of the variables below are not used, they are just reflections of my intentions and shows where PDS will go..."
     ."<h2>Cron settings</h2><br> Run on CRON, if set to YES overrides local and remote cron settings<br>"
     ."simple mnemonic format h-hours, d-days, w-weeks, m-months<br>this is very important string, shows what and when to backup<br>"
     ."this default setting makes and stores 3 backups a day,store 4 daily backups<br>one weekly backup, one monthly backup and one year<br> type in NO to disable</tr>"
     ."<br><form  method=\"post\" action=\"$setup\"><br><br>Run on Cron<input type=\"text\" name=\"SCHEDULEDRUN\" size=\"3\" maxlength=\"3\" value=\"$SCHEDULEDRUN\"><br><br>"
     ."<tr>Schedule <input type=\"text\" name=\"SCHEDULE\" size=\"55\" maxlength=\"255\" value=\"$SCHEDULE\"></tr>"
     ."<br><br>"
     ."<h2>Remote Hosts Configuration</h2>"
     ."<br>NO TRAILING SLASHES!!!<br>"
     ."<br>Path to the remote www root <input type=\"text\" name=\"REMOTEWWWROOT\" size=\"80\" maxlength=\"255\" value=\"$REMOTEWWWROOT\"><br>"
     ."<br>SSH host to connect to the online server where ssh is running <input type=\"text\" name=\"REMOTESSHHOST\" size=\"55\" maxlength=\"255\" value=\"$REMOTESSHHOST\"><br>"
     ."<br>Where to store your backup remotely <input type=\"text\" name=\"REMOTESTORAGESELECTION\" size=\"55\" maxlength=\"255\" value=\"$REMOTESTORAGESELECTION\"><br>"
     ."<br>What directory to backup <input type=\"text\" name=\"REMOTEDIRSELECTION\" size=\"55\" maxlength=\"255\" value=\"$REMOTEDIRSELECTION\"><br>"
     ."<br>Remote database to backup <input type=\"text\" name=\"REMOTEDBSELECTION\" size=\"55\" maxlength=\"255\" value=\"$REMOTEDBSELECTION\"><br>"
     ."<br>Remote ssh login <input type=\"text\" name=\"REMOTESSHUSER\" size=\"55\" maxlength=\"255\" value=\"$REMOTESSHUSER\"><br>"
     ."<br>REMOTESSHPASSWORD <input type=\"text\" name=\"REMOTESSHPASSWORD\" size=\"55\" maxlength=\"255\" value=\"$REMOTESSHPASSWORD\"><br>"
     ."<br>REMOTEROOTPWD <input type=\"text\" name=\"REMOTEROOTPWD\" size=\"55\" maxlength=\"255\" value=\"$REMOTEROOTPWD\"><br>"
     ."<br>Remote MySQL user <input type=\"text\" name=\"REMOTEMYSQLUSER\" size=\"55\" maxlength=\"255\" value=\"$REMOTEMYSQLUSER\"><br>"
     ."<br>Remote MySQL password<input type=\"text\" name=\"REMOTEMYSQLPASSWORD\" size=\"55\" maxlength=\"255\" value=\"$REMOTEMYSQLPASSWORD\"><br>"
     ."<br>Remote MySQL host <input type=\"text\" name=\"REMOTEMYSQLHOST\" size=\"55\" maxlength=\"255\" value=\"$REMOTEMYSQLHOST\"><br>"
     ."<br>Absolute path to the remote MySQL directory<input type=\"text\" name=\"REMOTEMYSQLPATH\" size=\"55\" maxlength=\"255\" value=\"$REMOTEMYSQLPATH\"><br>"
     ."<br>Images/content/upload directories are suppose to be in this folder <input type=\"text\" name=\"REMOTEMEDIADIR\" size=\"55\" maxlength=\"255\" value=\"$REMOTEMEDIADIR\"><br>"
     ."<br>REMOTEMYSQLROOTPWD <input type=\"text\" name=\"REMOTEMYSQLROOTPWD\" size=\"55\" maxlength=\"255\" value=\"$REMOTEMYSQLROOTPWD\"><br>"
     ."<h2>Local Hosts Configuration</h2>"
     ."<br>Usually it is something like \"/var/www\" local directory to backup <input type=\"text\" name=\"LOCALDIRSELECTION\" size=\"80\" maxlength=\"255\" value=\"$LOCALDIRSELECTION\"><br>"
     ."<br>where to store local backups <input type=\"text\" name=\"LOCALSTORAGESELECTION\" size=\"55\" maxlength=\"255\" value=\"$LOCALSTORAGESELECTION\"><br>"
     ."<br>images/content/upload directories are suppose to be in this foldeer <input type=\"text\" name=\"LOCALMEDIADIR\" size=\"55\" maxlength=\"255\" value=\"$LOCALMEDIADIR\"><br>"
     ."<br>www root, for full backup/deployment <input type=\"text\" name=\"LOCALWWWROOT\" size=\"55\" maxlength=\"255\" value=\"$LOCALWWWROOT\"><br>"
     ."<br>what mysql database to backup <input type=\"text\" name=\"LOCALDBSELECTION\" size=\"55\" maxlength=\"255\" value=\"$LOCALDBSELECTION\"><br>"
     ."<br>filename prefix for tar file - no path <input type=\"text\" name=\"LOCALTARFILENAME\" size=\"55\" maxlength=\"255\" value=\"$LOCALTARFILENAME\"><br>"
     ."<br>local server might be in your LAN/INTERNET, not just in your computer <input type=\"text\" name=\"LOCALMYSQLHOST\" size=\"55\" maxlength=\"255\" value=\"$LOCALMYSQLHOST\"><br>"
     ."<br>MySQL login <input type=\"text\" name=\"LOCALMYSQLUSER\" size=\"55\" maxlength=\"255\" value=\"$LOCALMYSQLUSER\"><br>"
     ."<br>LOCALMYSQLPASSWORD <input type=\"text\" name=\"LOCALMYSQLPASSWORD\" size=\"55\" maxlength=\"255\" value=\"$LOCALMYSQLPASSWORD\"><br>"
     ."<br>LOCALMYSQLPATH <input type=\"text\" name=\"LOCALMYSQLPATH\" size=\"55\" maxlength=\"255\" value=\"$LOCALMYSQLPATH\"><br>"
     ."<br>LOCALMYSQLROOTPWD <input type=\"text\" name=\"LOCALMYSQLROOTPWD\" size=\"55\" maxlength=\"255\" value=\"$LOCALMYSQLROOTPWD\"><br>"
     ."<h2>PDS config</h2>"
     ."<br>CROSSDEPLOY <input type=\"text\" name=\"CROSSDEPLOY\" size=\"80\" maxlength=\"255\" value=\"$CROSSDEPLOY\"><br>"
     ."<br>BACKDEPLOY <input type=\"text\" name=\"BACKDEPLOY\" size=\"55\" maxlength=\"255\" value=\"$BACKDEPLOY\"><br>"
     ."<br>YES - keeps backups locally, NO - remotely <input type=\"text\" name=\"STORELOCALLY\" size=\"55\" maxlength=\"255\" value=\"$STORELOCALLY\"><br>"
     ."<br>FORCEUPLOAD <input type=\"text\" name=\"FORCEUPLOAD\" size=\"55\" maxlength=\"255\" value=\"$FORCEUPLOAD\"><br>"
     ."<br>LOCALHOSTSFILE <input type=\"text\" name=\"LOCALHOSTSFILE\" size=\"55\" maxlength=\"255\" value=\"$LOCALHOSTSFILE\"><br>"
     ."<br>LOCALHOSTIPBASE <input type=\"text\" name=\"LOCALHOSTIPBASE\" size=\"55\" maxlength=\"255\" value=\"$LOCALHOSTIPBASE\"><br>"
     ."<br>LOCALHOSTIPSHIFT <input type=\"text\" name=\"LOCALHOSTIPSHIFT\" size=\"55\" maxlength=\"255\" value=\"$LOCALHOSTIPSHIFT\"><br>"
     ."<br>LOCALSSHPASSWORD <input type=\"text\" name=\"LOCALSSHPASSWORD\" size=\"55\" maxlength=\"255\" value=\"$LOCALSSHPASSWORD\"><br>"
     ."<br>LOCALTEMPDIR <input type=\"text\" name=\"LOCALTEMPDIR\" size=\"55\" maxlength=\"255\" value=\"$LOCALTEMPDIR\"><br>"
     ."<br><br><input type=\"submit\" name=\"op\" value=\"Save Configuration\"></form><br><br>";
echo "</table>";
}
require_once("footer.php"); 
?>
