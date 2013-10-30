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
. $EPATH/deploy.conf
echo "Settings are loaded".'$FORCEUPLOAD'." = $FORCEUPLOAD"
su $REMOTESSHUSER
RemoveLocalTempDirs () {
  echo "removing temporary files"
  rm -r $LOCALSTORAGESELECTION/db
if [ $? = 0 ]; then
	echo "$LOCALSTORAGESELECTION/db is removed"
else
	echo "Can not remove $LOCALSTORAGESELECTION/db, check system settings or check system requirements at digger3d.com..."

fi

  rm -r $LOCALSTORAGESELECTION/files
if [ $? = 0 ]; then
	echo "$LOCALSTORAGESELECTION/files is removed"
else
	echo "Can not remove $LOCALSTORAGESELECTION/files, check system settings or check system requirements at digger3d.com..."

fi

  echo "removing temporary done..."
}
CreateLocalTempDirs () {
#RemoveLocalTempDirs
  rm -r $LOCALSTORAGESELECTION/files
  echo "creating temporary dirs"
  mkdir $LOCALSTORAGESELECTION/files
if [ $? = 0 ]; then
	echo "$LOCALSTORAGESELECTION/files is created"
else
	echo "Can not create $LOCALSTORAGESELECTION/files, check system settings or check system requirements at digger3d.com..."

fi
  rm -r $LOCALSTORAGESELECTION/db
  mkdir $LOCALSTORAGESELECTION/db
if [ $? = 0 ]; then
	echo "$LOCALSTORAGESELECTION/db is created"
else
	echo "Can not create $LOCALSTORAGESELECTION/db, check system settings or check system requirements at digger3d.com..."

fi

  echo "creating temporary dirs done..."
}

RemoveRemoteTempDirs () {
ssh -x -a -q $REMOTESSHUSER@$REMOTESSHHOST rm -r $REMOTESTORAGESELECTION/db
if [ $? = 0 ]; then
	echo "$REMOTESSHUSER@$REMOTESSHHOST$REMOTESTORAGESELECTION/db is removed"
else
	echo "Can not remove $REMOTESSHUSER@$REMOTESSHHOST$REMOTESTORAGESELECTION/db, check system settings or check system requirements at digger3d.com..."
fi

ssh -x -a -q $REMOTESSHUSER@$REMOTESSHHOST rm -r $REMOTESTORAGESELECTION/files
if [ $? = 0 ]; then
	echo "$REMOTESSHUSER@$REMOTESSHHOST$REMOTESTORAGESELECTION/files is removed"
else
	echo "Can not remove $REMOTESSHUSER@$REMOTESSHHOST$REMOTESTORAGESELECTION/files, check system settings or check system requirements at digger3d.com..."
fi
}
CreateRemoteTempDirs () {
#RemoveRemoteTempDirs
ssh -x -a -q $REMOTESSHUSER@$REMOTESSHHOST rm -r $REMOTESTORAGESELECTION/files
#ssh -x -a -q -o "BatchMode=yes" $REMOTESSHUSER@$REMOTESSHHOST rm -r $REMOTESTORAGESELECTION/files
 echo "creating remote temporary dirs"
ssh -x -a -q $REMOTESSHUSER@$REMOTESSHHOST mkdir $REMOTESTORAGESELECTION/files
if [ $? = 0 ]; then
	echo "directory $REMOTESSHUSER@$REMOTESSHHOST:$REMOTESTORAGESELECTION/files  created"
else
	echo "Can not create $REMOTESSHUSER@$REMOTESSHHOST$REMOTESTORAGESELECTION/files, user ${USER}, check system settings or check system requirements at digger3d.com..."
fi

ssh $REMOTESSHUSER@$REMOTESSHHOST rm -r $REMOTESTORAGESELECTION/db
ssh $REMOTESSHUSER@$REMOTESSHHOST mkdir $REMOTESTORAGESELECTION/db
if [ $? = 0 ]; then
	echo "$REMOTESSHUSER@$REMOTESSHHOST$REMOTESTORAGESELECTION/db is created"
else
	echo "Can not create $REMOTESSHUSER@$REMOTESSHHOST:$REMOTESTORAGESELECTION/db, check system settings or check system requirements at digger3d.com..."
	echo "cleaning up..."
	RemoveLocalTempDirs
	exit
fi

  echo "CreateRemoteTempDirs is done..."
}

CreateTempDirs ()
{
CreateLocalTempDirs
CreateRemoteTempDirs
}
RemoveTempDirs ()
{
RemoveLocalTempDirs
#RemoveRemoteTempDirs
}

DatabaseReplication ()
{
# ned
CreateTempDirs
exit
echo "Dumping local database"
mysqldump -u$LOCALMYSQLUSER -p$LOCALMYSQLPASSWORD $LOCALDBSELECTION > $LOCALSTORAGESELECTION/db/$LOCALDBSELECTION.sql

if [ $? = 0 ]; then
	echo "local database $LOCALDBSELECTION is dumped"
else
	echo "Can not dump local database $LOCALDBSELECTION, check system settings or check system requirements at digger3d.com..."
	echo "cleaning up..."
	RemoveTempDirs
	exit
fi

echo "Packing local database"
tar -czf $LOCALSTORAGESELECTION/$LOCALDBSELECTION.tar $LOCALSTORAGESELECTION/db/$LOCALDBSELECTION.sql
if [ $? = 0 ]; then
	echo "local database $LOCALDBSELECTION is packed"
else
	echo "Can not pack local database $LOCALDBSELECTION, check system settings or check system requirements at digger3d.com..."
	echo "cleaning up..."
	RemoveTempDirs
	exit
fi

echo "Uploading the remote database"
scp -r $LOCALSTORAGESELECTION/$LOCALDBSELECTION.tar $REMOTESSHUSER:$REMOTESSHPASSWORD@$REMOTESSHHOST:$REMOTESTORAGESELECTION
if [ $? = 0 ]; then
	echo "packed local database $LOCALDBSELECTION is uploaded"
else
	echo "Can not upload local database $LOCALDBSELECTION.tar, check system settings or check system requirements at digger3d.com..."
	echo "cleaning up..."
	RemoveTempDirs
	exit
fi

echo "Unpacking the remote database"
ssh $REMOTESSHUSER:$REMOTESSHPASSWORD@$REMOTESSHHOST tar -xzf $REMOTESTORAGESELECTION/$LOCALBSELECTION.tar $REMOTESTORAGESELECTION\db
if [ $? = 0 ]; then
	echo " local database $LOCALDBSELECTION is unpacked"
else
	echo "Can not unpack local database $LOCALDBSELECTION.tar, check system settings or check system requirements at digger3d.com..."
	echo "cleaning up..."
	RemoveTempDirs
	exit
fi
echo "Updating the remote database"
ssh $REMOTESSHUSER@$REMOTESSHHOST mysql -u$REMOTEMYSQLUSER -p$REMOTEMYSQLPASSWORD $REMOTEDBSELECTION <  $REMOTESTORAGESELECTION/db/$LOCALDBSELECTION.sql
if [ $? = 0 ]; then
	echo "packed local database $LOCALDBSELECTION is uploaded"
else
	echo "Can not update remote database $REMOTEDBSELECTION, check system settings or check system requirements at digger3d.com..."
	echo "cleaning up..."
	RemoveTempDirs
	exit
fi
echo "If it was no errors the remote database have to be up to date, cleaning up..."
RemoveTempDirs
echo "Done upload database"
}
CheckConfiguration () {
	#check the file exists
#	if ! [ -f $dbinfofile ]
#		then
#		echo "No such file $dbinfofile"
#		exit 3
#	fi

	#file should contain host:username:password
#	dbhost=`cat $dbinfofile | awk -F: '{print $1}'`
#	username=`cat $dbinfofile | awk -F: '{print $2}'`
#	password=`cat $dbinfofile | awk -F: '{print $3}'`
 #   dbopts=`cat $dbinfofile | awk -F: '{print $4}'`

	#check we got the right info
	if [ -z $REMOTESSHHOST ]
		then
		echo "No DB/SSH host specified... Edit me"
		exit 2
	fi

	if [ -z $REMOTEMYSQLUSER ]
		then
		echo "no DB username specified... Edit me"
		exit 2
	fi

	if [ -z $REMOTEMYSQLPASSWORD ]
		then
		echo "no DB password specified ... Edit me"
		exit 2
	fi
	if [ -z $REMOTESTORAGESELECTION ]
		then
		echo "no remote directory specified ... Edit me"
		exit 2
	fi
	if [ -z $REMOTEDBSELECTION ]
		then
		echo "no remote DB specified ... Edit me"
		exit 2
	fi
	if [ -z $LOCALDBSELECTION ]
		then
		echo "no local DB specified ... Edit me"
		exit 2
	fi
	if [ -z $LOCALSTORAGESELECTION ]
		then
		echo "no local directory specified ... Edit me"
		exit 2
	fi
	if [ -z $LOCALMYSQLUSER ]
		then
		echo "no local DB user specified ... Edit me"
		exit 2
	fi
	if [ -z $LOCALMYSQLPASSWORD ]
		then
		echo "no local DB password specified ... Edit me"
		exit 2
	fi
#Has to be finished
	}
ProtectString () {
    echo $'\x27'$@$'\x27'           # ��������� � "�������" �������
}
UnprotectString () {
    eval echo $@                    # �������������� �������������.
}


CheckConfiguration
DatabaseReplication
echo "press Enter to exit"
read $rrr