#!/bin/bash

echo "PDS uninstall on *buntu script s checking systen configuration..."
sudo apache2ctl -k stop
if [ $? = 0 ]; then
	echo "Apache2 is stopped, deinstalling PDS..."
else
	echo "Apache2 was not running, deinstalling PDS..."
fi

sudo php5</var/www/pds/uninstall.php
if [ $? = 0 ]; then
	echo "apache start script, hosts and directories are up to date."
else
	echo "hosts write error, result code is $?, check system settings, file permissions or hardware or check system requirements at digger3d.com..."
	exit
fi

#start apache
sudo cp /etc/init.d/apache2.backup /etc/init.d/apache2
sudo cp /etc/hosts.backup /etc/hosts

sudo rm -r /var/www/pds
if [ $? = 0 ]; then
	echo "PDS root directory deinstallation complete. Starting the Apache ..."
else
	echo "PDS root directory installation error, check system settings, file permissions, hardware or check system requirements at digger3d.com..."
	exit
fi

#

sudo apache2ctl -k start
if [ $? = 0 ]; then
	echo "Apache is running"
else
	echo "Apache can not start, result code is $?, check system settings or check system requirements at digger3d.com..."
	exit
fi