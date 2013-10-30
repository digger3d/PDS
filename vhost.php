<?php
echo `touch $LOCALSTORAGESELECTION/$hostdir[$i]-error.log`;
echo `touch $LOCALSTORAGESELECTION/$hostdir[$i]-access.log`;
$vhost[$i]="#PDS automated entry begin. Powered by digger3d.com \n"
."NameVirtualHost $hostdir[$i]\n"
." <VirtualHost $hostdir[$i]>\n"
."	ServerAdmin webmaster@$hostdir[$i]\n";
echo "Trying the default setting of the default directory to be $LOCALWWWROOT/$hostdir[$i]/htdocs/\n";
$handle1=opendir("$LOCALWWWROOT/$hostdir[$i]/htdocs/");
if($handle1!=0) {
	echo "\nAssuming the default directory to be $LOCALWWWROOT/$hostdir[$i]/htdocs/\n";
	$vhost[$i].="	DocumentRoot $LOCALWWWROOT/$hostdir[$i]/htdocs/\n"
	."	<Directory $LOCALWWWROOT/$hostdir[$i]/htdocs/>\n";
	closedir($handle1);
	} else {
	echo "\nAssuming the default directory to be $LOCALWWWROOT/$hostdir[$i]/\n";
	$vhost[$i].="	DocumentRoot $LOCALWWWROOT/$hostdir[$i]/\n"
	."	<Directory $LOCALWWWROOT/$hostdir[$i]/>\n";
	}
$vhost[$i].="		Options Indexes FollowSymLinks MultiViews\n"
."		AllowOverride None\n"
."		Order allow,deny\n"
."		allow from all\n"
."	</Directory>\n"
."	ScriptAlias /cgi-bin/ /usr/lib/cgi-bin/\n"
."	<Directory \"/usr/lib/cgi-bin\">\n"
."		AllowOverride None\n"
."		Options +ExecCGI -MultiViews +SymLinksIfOwnerMatch\n"
."		Order allow,deny\n"
."		Allow from all\n"
."	</Directory>\n"
."	ErrorLog $LOCALSTORAGESELECTION/$hostdir[$i]-error.log\n"
."	LogLevel debug\n"
."	CustomLog $LOCALSTORAGESELECTION/$hostdir[$i]-access.log combined\n"
."	ServerSignature On\n"
." </VirtualHost>\n"
."#Personal Deployment System - automated entry end. Powered by digger3d.com "
."If you want to protect your manually defined hosts just define them below the \"localhost\" defilition line..."
."\n\n\n"
."\n\n\n";
?>