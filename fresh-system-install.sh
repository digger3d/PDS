#!/bin/bash
#PDS install on *buntu script

userid=${USER}
if [$userid = "root" ]; then
    echo "You have to run installer not as root any you have to have sudo configured."
    exit
fi    
# 1. create authorization realm (passwordless ssh)
#ssh-keygen -t rsa ~/.ssh/id_rsa.pub
#scp ~/.ssh/id_rsa.pub $REMOTESSHUSER@$REMOTESHHHOST:.ssh/keys
#cat .ssh/keys>>~/.ssh/authorized_keys
echo "PDS install on *buntu script s checking systen configuration, if it fails check system requirements at http://digger3d.com..."
echo "WARNING!!! This system is not intend to be an online control panel."
echo "This is your ultimate deploy/backup/develop *NIX/Linux system enhancement for web developers"
echo "So, if this installation script is running on a live online server - CANCEL IT RIGHT NOW!!! by pressing Ctrl-C"
echo 0 | php5
if [ $? = 0 ]; then
	echo "PHP5 is installed"
else
	echo "PHP5 is not installed,  trying to install, after it is installed and working try to install PDS again"
	sudo apt-get install autoconf automake1.4 autotools-dev libapache2-mod-php5 php5 php5-common php5-curl php5-dev  php5-gd php-pear php5-ldap php5-mhash php5-mysql php5-mysqli php5-snmp php5-sqlite php5-xmlrpc php5-xsl php5-imap php5-mcrypt php5-pspell php5-gd
	exit
fi

# 2. check mysql, apache

mysql --version
if [ $? = 0 ]; then
	echo "MySQL check Complete"
else
	echo "MySQL check failed, check system requirements at digger3d.com..."
	echo "mysql5 is not installed,  trying to install, after it is installed and working try to install PDS again"
	sudo apt-get install mysql5
	exit
fi
sudo apache2 force-reload
sudo apache2ctl -k stop
if [ $? = 0 ]; then
	echo "Apache2 is stopped, installing PDS..."
else
	echo "Apache2 error, start it and try again or check system requirements at digger3d.com..."
	echo "Can't continue without Apache2"
	fi



fi

#update hosts
# 3. list local hosts
#ls -D1 /var/www>hostlist
#ready on php

# 4. add ./vhosts to apache httpd.conf
#cat template>>httpd.conf
#ready on php

# 5. add hosts to /etc/hosts
#cat /etc/hosts>>./vhosts
#cp ./hostlist /etc/hosts
#ready on php
# 6. copy all to the localhost www root
sudo mkdir /var/www/pds
sudo cp -r ./* /var/www/pds
if [ $? = 0 ]; then
	echo "PDS root directory installation complete. Patching the Apache start file..."
else
	echo "PDS root directory installation error, check system settings, file permissions, hardware or check system requirements at digger3d.com..."
	exit
fi
cd /var/www/pds
sudo php5</var/www/pds/install.php
if [ $? = 0 ]; then
	echo "apache start script, hosts and directories are up to date."
else
	echo "hosts write error, result code is $?, check system settings, file permissions or hardware or check system requirements at digger3d.com..."
	exit
fi

#start apache
sudo apache2ctl -k start
if [ $? = 0 ]; then
	echo "Apache is running"
else
	echo "Apache can not start, result code is $?, check system settings or check system requirements at digger3d.com..."

fi
echo $userid
sudo chown -R $userid /var/www/pds

if [ $? = 0 ]; then
	echo "Permissions are applied"
else
	echo "Unknown filesystem error."
	exit
fi
#

