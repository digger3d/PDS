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

#Phase one, prepare files
#Creates archives of MySQL dumps and selected directories
LocalDBDump () {
echo "dumping the selected database"
touch $LOCALSTORAGESELECTION/db/$LOCALDBSELECTION.sql
mysqldump -u$LOCALMYSQLUSER -p$LOCALMYSQLPASSWORD $LOCALDBSELECTION > $LOCALSTORAGESELECTION/db/$LOCALDBSELECTION.sql
echo "dumping is done"
}

PackLocalFiles() {
echo "packing directory $LOCALSTORAGESELECTION/db and $LOCALWWWROOT in $LOCALSTORAGESELECTION/$LOCALTARFILENAME.tar"
tar -czf $LOCALSTORAGESELECTION/files/$LOCALTARFILENAME.tar $LOCALSTORAGESELECTION/db $LOCALWWWROOT
echo "Local DB and files are packed... "
}
PackLocalDB() {
echo "packing directory $LOCALSTORAGESELECTION/db and $LOCALWWWROOT in $LOCALSTORAGESELECTION/$LOCALTARFILENAME.tar"
tar -czf $LOCALSTORAGESELECTION/files/$LOCALTARFILENAME.tar $LOCALSTORAGESELECTION/db
echo "Local DB and files are packed... "
}
RemoveLocalTempDirs () {
  echo "removing temporary directories"
  rm -r $LOCALSTORAGESELECTION/db
  rm -r $LOCALSTORAGESELECTION/files
  echo "removing temporary dirs done..."
}

CreateLocalTempDirs () {
  echo "creating temporary directories"
  mkdir $LOCALSTORAGESELECTION/files
  mkdir $LOCALSTORAGESELECTION/db
  echo "creating temporary dirs done..."
}
CreateRemoteTempDirs () {
  echo "creating temporary dirs"
ssh $REMOTESSHUSER@$REMOTESSHHOST mkdir $REMOTESTORAGESELECTION/files
ssh $REMOTESSHUSER@$REMOTESSHHOST mkdir $REMOTESTORAGESELECTION/db
  echo "creating temporary dirs done..."

}

RemoveRemoteTempDirs () {
  echo "removing temporary dirs"
ssh $REMOTESSHUSER@$REMOTESSHHOST rm -r $REMOTESTORAGESELECTION/files
ssh $REMOTESSHUSER@$REMOTESSHHOST rm -r $REMOTESTORAGESELECTION/db

  echo "removing temporary dirs done..."

}

LocalBackup () {
echo "Local backup is starting"
CreateLocalTempDirs
LocalDBDump
PackLocalFiles
RemoveLocalTempDirs
echo "Local backup done"
}

LocalRestore ()
{
echo "Local from local restore is starting"
echo "Creating directories"
echo "Extracting backup"
tar -xzf $LOCALSTORAGESELECTION/all/$LOCALTARFILENAME.tar -C /
# -C $LOCALSTORAGESELECTION
echo "Restoring database"
mysql -u$LOCALMYSQLUSER -p$LOCALMYSQLPASSWORD $LOCALDBSELECTION < $LOCALSTORAGESELECTION/db/$LOCALDBSELECTION.sql
echo "Extracting files"
tar -xzf $LOCALSTORAGESELECTION/files/$LOCALTARFILENAME.tar -C /
# -C $LOCALDIRSELECTION
echo "Removing temp files"
RemoveLocalTempFiles
#rm -r $LOCALSTORAGESELECTION/home
echo "Local restore is done"



CreateRemoteTempDirs
echo "Extracting remotely"
ssh $REMOTESSHUSER@$REMOTESSHHOST $TAR -xf $REMOTESTORAGESELECTION/all/$REMOTETARFILENAME.tar $REMOTESTORAGESELECTION
echo "copying remotely"
ssh $REMOTESSHUSER@$REMOTESSHHOST mv  $REMOTESTORAGESELECTION/files $REMOTEDIRSELECTION
echo "deleting the database"
ssh $REMOTESSHUSER@$REMOTESSHHOST mysql -u$REMOTEMYSQLUSER -p$REMOTEMYSQLPASSWORD DROP DATABASE $REMOTEDBSELECTION
ssh $REMOTESSHUSER@$REMOTESSHHOST mysql -u$REMOTEMYSQLUSER -p$REMOTEMYSQLPASSWORD CREATE DATABASE $REMOTEDBSELECTION
echo "restoring the database"
ssh $REMOTESSHUSER@$REMOTESSHHOST mysql -u$REMOTEMYSQLUSER -p$REMOTEMYSQLPASSWORD $REMOTEDBSELECTION <  $REMOTESTORAGESELECTION/db/$REMOTEDBSELECTION.sql
}

CrossRestore ()
{
}

#LocalBackup
#CrossRestore
Download ()
{
# ned
CreateRemoteTempDirs
CreateLocalTempDirs
echo "Dumping the remote database"
echo "Dumping remote database"
ssh $REMOTESSHUSER@$REMOTESSHHOST "mysqldump -u$REMOTEMYSQLUSER -p$REMOTEMYSQLPASSWORD $REMOTEDBSELECTION>$REMOTESTORAGESELECTION/db/$REMOTEDBSELECTION.sql"
echo "Packing the remote database"
ssh $REMOTESSHUSER@$REMOTESSHHOST "tar -czf $REMOTESTORAGESELECTION/$LOCALTARFILENAME.tar $REMOTESTORAGESELECTION/db/$REMOTEDBSELECTION.sql"
echo "Downloading the remote database"
scp -r $REMOTESSHUSER@$REMOTESSHHOST:$REMOTESTORAGESELECTION/$REMOTEDBSELECTION.sql $LOCALSTORAGESELECTION
echo "Unacking the remote database locally"
tar -xzf $REMOTESTORAGESELECTION/$LOCALTARFILENAME.tar -C $REMOTESTORAGESELECTION/
echo "Updating the local $REMOTESSHHOST database"
mysql -u$LOCALMYSQLUSER -p$LOCALMYSQLPASSWORD $LOCALDBSELECTION <  $LOCALSTORAGESELECTION/db/$REMOTEDBSELECTION.sql
echo "Synchronizing local file tree $LOCALWWWROOT/ from $REMOTESSHHOST:$REMOTWWWROOT"
rsync -av -e ssh  $REMOTESSHHOST:$REMOTEWWWROOT/ $LOCALWWWROOT

}


CheckConfiguration () {
	#check we got the right info
	if [ -z $REMOTESSHHOST ]
		then
		echo "No SSH host specified... visit http://digger3d.com for support"
		exit 2
	fi

	if [ -z $REMOTESSHUSER ]
		then
		echo "no username specified... visit http://digger3d.com for support"
		exit 2
	fi

	if [ -z $REMOTEWWWROOT ]
		then
		echo "no WWW root specified ... visit http://digger3d.com for support"
		exit 2
	fi
	}
ProtectString () {
    echo $'\x27'$@$'\x27'
}
UnprotectString () {
    eval echo $@
}

#CheckConfiguration
Download