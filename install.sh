#!/bin/bash
#PDS install on *buntu script

userid=${USER}
if [ $userid = "root" ]; then
    echo "You have to run installer not as root and you have to have sudo configured."
    exit
fi

     
# 1. create authorization realm (passwordless ssh)
 if [ ! -e ~/.ssh ]
 then
	mkdir ~/.ssh
 fi
  if [ ! -e ~/.ssh/id_rsa.pub ]       # Check if file exists.
  then
    echo "~/.ssh/id_rsa.pub does not exist. Creating authorization realm"; echo 
	ssh-keygen -t rsa 	
echo "Now you have to add your local /.ssh/id_rsa.pub to the remote ~/.ssh/authorized_keys and try again"
exit
fi

	#ssh $REMOTESSHUSER:$REMOTESSHPASSWORD@$REMOTESSHHOST mkdir ~/.ssh/keys

#	scp ~/.ssh/id_rsa.pub $REMOTESSHUSER@$REMOTESHHOST:~/ && ssh $REMOTESSHUSER@$REMOTESSHHOST cat ~/id_dsa.pub >> ~/.ssh/authorized_keys ; chmod 644 ~/.ssh/authorized_keys
#        ssh $REMOTESSHUSER@$REMOTESSHHOST 
#scp -r ~/.ssh/id_rsa.pub $REMOTESSHUSER:$REMOTESSHPASSWORD@$REMOTESSHHOST:~/.ssh/keys
	#scp -r ~/.ssh/id_rsa.pub $REMOTESSHUSER:$REMOTESSHPASSWORD@$REMOTESSHHOST:.ssh/keys
	#cat .ssh/keys>>~/.ssh/authorized_keys

ssh $REMOTESSHUSER@$REMOTESSHHOST ls
if [ $? = 0 ]; then
	echo "authorization established"
else
	echo "Can't authorize, you have to manually install automatic ssh authorization."
	echo "So, this installation script failed to check automatic ssh authorization. CANCEL IT RIGHT NOW!!! by pressing Ctrl-C or it will not function proprely and may drive you insane asking your password. Follow instructions on http://digger3d.com"
read Ctrkey
fi

#ssh $REMOTESSHUSER:$REMOTESSHPASSWORD@$REMOTESSHHOST mkdir ~/.ssh
#ssh $REMOTESSHUSER:$REMOTESSHPASSWORD@$REMOTESSHHOST touch ~/.ssh/id_rsa.pub & chmod 777 ~/.ssh/id_rsa.pub 
#scp ~/.ssh/id_rsa.pub $REMOTESSHUSER@$REMOTESHHOST:~/
#ssh $REMOTESSHUSER@$REMOTESSHHOST cat ~/id_dsa.pub >> ~/.ssh/authorized_keys & chmod 644 ~/.ssh/authorized_keys

echo "PDS install on *buntu script s checking systen configuration, if it fails check system requirements at http://digger3d.com..."
echo "WARNING!!! This system is not intend to be an online control panel."
echo "This is your ultimate deploy/backup/develop *NIX/Linux system enhancement for web developers"
echo "So, if this installation script is running on a live online server - CANCEL IT RIGHT NOW!!! by pressing Ctrl-C"
read Ctrkey
echo 0 | php5
if [ $? = 0 ]; then
	echo "PHP5 is installed"
else
	echo "PHP5 is not installed, can not continue, check system requirements at digger3d.com..."
	sudo apt-get install autoconf automake1.4 autotools-dev libapache2-mod-php5 php5 php5-common php5-curl php5-dev php5-gd php-pear php5-ldap php5-mhash php5-mysql php5-mysqli php5-snmp php5-sqlite php5-xmlrpc php5-xsl php5-imap php5-mcrypt php5-pspell php5-gd
	echo 0 | php5
	if [ $? = 0 ]; then
		echo "PHP5 is installed"
	else
		echo "can not install PHP5, can not continue, check system requirements at digger3d.com..."
	fi
fi

# 2. check mysql, apache

mysql --version
if [ $? = 0 ]; then
	echo "MySQL check Complete"
else
	echo "MySQL check failed, check system requirements at digger3d.com..."
	exit
fi
#sudo apache2 force-reload
sudo apache2ctl -k stop
if [ $? = 0 ]; then
	echo "Apache2 is stopped, installing PDS..."
else
	echo "Apache2 was not running start it and try again..."

fi

sudo mkdir /var/www/pds
sudo cp -r ./* /var/www/pds
sudo cp -r /home/$userid/.ssh /root
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


echo $userid
sudo chown -R $userid /var/www/pds
chmod -R 777 /var/www/pds 


if [ $? = 0 ]; then
	echo "Permissions are applied"
else
	echo "Unknown permissions/filesystem error."
	exit
fi
#
#start apache
sudo apache2ctl -k start
if [ $? = 0 ]; then
	echo "Apache is running, point your browser to http://pds/"
else
	echo "Apache can not start, result code is $?, check system settings or check system requirements at digger3d.com..."
	exit
fi
