#/************************************************************************/
#/* Personal Deployment System 			                       	 */
#/* ===========================                                        	 */
#/*                                                                 	 */
#/* Copyright (c) 2008 by Anton Volkonskiy                          	 */
#/* http://digger3d.com							 */
#/*                                                                 	 */
#/* This program is free software. You can redistribute it and/or modify */
#/* it under the terms of the GNU General Public License as published by */
#/* the Free Software Foundation; either version 2 of the License.       */
#/************************************************************************/
EPATH=`pwd`
echo "Assuming path $EPATH, inserting  $EPATH/deploy.conf"
. deploy.conf
. $EPATH/dump1

echo "creating temporary dirs"
ssh $REMOTESSHUSER@$REMOTESSHHOST rm -r $REMOTESTORAGESELECTION/files ; rm -r $REMOTESTORAGESELECTION/db ; mkdir $REMOTESTORAGESELECTION/files ; mkdir $REMOTESTORAGESELECTION/db
rm -r $LOCALSTORAGESELECTION/files
rm -r $LOCALSTORAGESELECTION/db
mkdir $LOCALSTORAGESELECTION/files
mkdir $LOCALSTORAGESELECTION/db
echo "creating temporary dirs done..."
echo "Dumping local database"
touch $LOCALSTORAGESELECTION/db/$LOCALDBSELECTION.sql
mysqldump -u$LOCALMYSQLUSER -p$LOCALMYSQLPASSWORD $LOCALDBSELECTION > $LOCALSTORAGESELECTION/db/$LOCALDBSELECTION.sql
echo "dumping is done"
echo "packing directory $LOCALSTORAGESELECTION/db in $LOCALSTORAGESELECTION/$LOCALTARFILENAME.tar"
tar -czf $LOCALSTORAGESELECTION/files/$LOCALTARFILENAME.tar $LOCALSTORAGESELECTION/db/$LOCALDBSELECTION.sql
echo "Local DB is packed... "
echo "Uploading database for host $REMOTESSHHOST"
scp -r  $LOCALSTORAGESELECTION/files/$LOCALTARFILENAME.tar $REMOTESSHUSER@$REMOTESSHHOST:$REMOTESTORAGESELECTION/
echo "Unpacking database for the remote host $REMOTESTORAGESELECTION/$LOCALTARFILENAME.tar "
ssh $REMOTESSHUSER@$REMOTESSHHOST "tar -xzf $REMOTESTORAGESELECTION/$LOCALTARFILENAME.tar -C $REMOTESTORAGESELECTION/"
echo "Updating remote $REMOTESSHHOST database"
ssh $REMOTESSHUSER@$REMOTESSHHOST mysql -u$REMOTEMYSQLUSER -p$REMOTEMYSQLPASSWORD $REMOTEDBSELECTION <  $REMOTESTORAGESELECTION/db/$REMOTEDBSELECTION.sql
echo "removing temporary directories"
rm -r $LOCALSTORAGESELECTION/db
rm -r $LOCALSTORAGESELECTION/files
ssh $REMOTESSHUSER@$REMOTESSHHOST rm -r $REMOTESTORAGESELECTION/files
ssh $REMOTESSHUSER@$REMOTESSHHOST rm -r $REMOTESTORAGESELECTION/db
echo "removing temporary dirs done..."
