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

RemoveLocalTempDirs () {
  echo "removing temporary directories"
  rm -r $LOCALSTORAGESELECTION/db
  rm -r $LOCALSTORAGESELECTION/files
  echo "removing temporary dirs done..."
}

CreateLocalTempDirs () {
  echo "creating temporary directories"
  rm -r $LOCALSTORAGESELECTION/files
  rm -r $LOCALSTORAGESELECTION/db
  mkdir $LOCALSTORAGESELECTION/files
  mkdir $LOCALSTORAGESELECTION/db
  echo "creating temporary dirs done..."
}
CreateRemoteTempDirs () {
  echo "creating temporary dirs"
ssh $REMOTESSHUSER@$REMOTESSHHOST rm -r $REMOTESTORAGESELECTION/files
ssh $REMOTESSHUSER@$REMOTESSHHOST rm -r $REMOTESTORAGESELECTION/db
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



echo "Dumping remote database at $REMOTESSHUSER@$REMOTESSHHOST"
ssh $REMOTESSHUSER@$REMOTESSHHOST mysqldump -u$REMOTEMYSQLUSER -p$REMOTEMYSQLPASSWORD --no-create-db --create-options='FALSE' --no-create-info --compact $REMOTEDBSELECTION -r$REMOTEDBSELECTION.sql
echo "Packing remote database at $REMOTESSHUSER@$REMOTESSHHOST in $LOCALTARFILENAME.tar database $REMOTEDBSELECTION.sql"
ssh $REMOTESSHUSER@$REMOTESSHHOST tar -czf $LOCALTARFILENAME.tar $REMOTEDBSELECTION.sql
echo "Downloading remote database"
scp $REMOTESSHUSER@$REMOTESSHHOST:$LOCALTARFILENAME.tar $LOCALSTORAGESELECTION/
echo "Unpacking downloaded database: tar -xvf $LOCALSTORAGESELECTION/$LOCALTARFILENAME.tar"
#(cd /$LOCALSTORAGESELECTION; tar cf - $LOCALSTORAGESELECTION/) | (cd $LOCALSTORAGESELECTION; tar xf - )
tar -xvf $LOCALSTORAGESELECTION/$LOCALTARFILENAME.tar
echo "Loading remote database in the local database \n sed 's/^INSERT INTO /REPLACE /' $REMOTEDBSELECTION.sql > ~/$LOCALDBSELECTION.sql.1"
sed 's/^INSERT INTO /REPLACE INTO /' $REMOTEDBSELECTION.sql > ~/$LOCALDBSELECTION.sql.1
mysql -u$LOCALMYSQLUSER -p$LOCALMYSQLPASSWORD $LOCALDBSELECTION < ~/$LOCALDBSELECTION.sql.1
echo "Synchronizing local database completed"


