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
echo "Settings are loaded = $FORCEUPLOAD"

#Phase one, prepare files
#Creates archives of MySQL dumps and selected directories
 Phase1Local () {
#
#
echo "dumping the selected database"
#echo "with the following settings"
#echo "file $LOCALSTORAGESELECTION/db/$LOCALDBSELECTION.sql"
#echo "db $LOCALDBSELECTION"
#echo "user $LOCALMYSQLUSER"
#echo "password $LOCALMYSQLPASSWORD"
touch $LOCALSTORAGESELECTION/db/$LOCALDBSELECTION.sql
mysqldump -u$LOCALMYSQLUSER -p$LOCALMYSQLPASSWORD --compatible=mysql323 $LOCALDBSELECTION > $LOCALSTORAGESELECTION/db/$LOCALDBSELECTION.sql
echo "dumping is done"
}
PackLocalFiles() {
echo "packing directory $LOCALDIRSELECTION in $LOCALSTORAGESELECTION/files/$LOCALTARFILENAME.tar"
tar -czf $LOCALSTORAGESELECTION/files/$LOCALTARFILENAME.tar $LOCALDIRSELECTION
echo "packing all at once"
tar -czf $LOCALSTORAGESELECTION/all$LOCALTARFILENAME.tar $LOCALSTORAGESELECTION
echo "Phase1local is done... "

}
RemoveLocalTempFiles () {
  echo "removing temporary files"
  rm -r $LOCALSTORAGESELECTION/db
  rm -r $LOCALSTORAGESELECTION/files
  echo "removing temporary done..."
}
CreateLocalTempDirs () {
  echo "creating temporary dirs"
  mkdir $LOCALSTORAGESELECTION/files
  mkdir $LOCALSTORAGESELECTION/db
  echo "creating temporary dirs done..."
}

LocalBackup () {
echo "Local backup is starting"
CreateLocalTempDirs
Phase1Local
PackLocalFiles
RemoveLocalTempFiles
echo "Local backup done"
}

LocalRestore ()
{
echo "Local from local restore is starting"
echo "Creating directories"
echo "Extracting backup"
tar -xzf $LOCALSTORAGESELECTION/all$LOCALTARFILENAME.tar -C /
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
echo "Emptying remotely"
ssh $REMOTESSHUSER@$REMOTESSHHOST rm -r $REMOTEDIRSELECTION
ssh $REMOTESSHUSER@$REMOTESSHHOST mkdir $REMOTEDIRSELECTION
echo "Extracting remotely"
ssh $REMOTESSHUSER@$REMOTESSHHOST $TAR -xf $REMOTESTORAGESELECTION/all$REMOTETARFILENAME-$DM.tar $REMOTESTORAGESELECTION
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
DatabaseReplication ()
{
# ned
CreateLocalTempDirs
#echo "Dumping local database"
#mysql -u$LOCALMYSQLUSER -p$LOCALMYSQLPASSWORD $LOCALDBSELECTION < $LOCALSTORAGESELECTION/db/$LOCALDBSELECTION.sql
echo "Dumping remote database"
##ssh $REMOTESSHUSER@$REMOTESSHHOST "mysqldump -u$REMOTEMYSQLUSER -p$REMOTEMYSQLPASSWORD $REMOTEDBSELECTION>$REMOTESTORAGESELECTION/$REMOTEDBSELECTION.sql"
echo "Downloading remote database"
##scp -r $REMOTESSHUSER@$REMOTESSHHOST:$REMOTESTORAGESELECTION/$REMOTEDBSELECTION.sql $LOCALSTORAGESELECTION
echo "Creating replication database"
##mysql -u$LOCALMYSQLUSER -p$LOCALMYSQLPASSWORD $LOCALDBSELECTION --local-infile -e"CREATE DATABASE $REMOTEDBSELECTION"
echo "Loading remote database in the replication database"
##mysql -u$LOCALMYSQLUSER -p$LOCALMYSQLPASSWORD $REMOTEDBSELECTION<$LOCALSTORAGESELECTION/$REMOTEDBSELECTION.sql
echo "Synchronizing databases"
#CompareTables
GetLocalTables
#echo "We have $index tables with $recindex records locally and"
#GetRemoteTables
echo "Locally we have $index tables with $recindex records and remotely we have $rindex tables with $recindex records"
#TablesReplication
}
FilesReplication ()
{
#echo synchronize files
echo "Not implemented yet"
}
TablesReplication () {
#Local tables getting new information to the end
#countindex - sequent local tables counter
#internalindex - search records counter
#index - total amounts of tables
#
# Remote records in total
ramount=${#rrecords[@]}
# Local records in total
amount=${#records[@]}
#select the biggest counter so we dont skip anything
if [ $amount -lt $ramount ]
	then
#local table have less records then remote
	recordsamount=$ramount
	else
#remote have less, setting amount of records to count
	recordsamount=$amount
fi
echo "We need to compare $amount records"
countindex=1
while [ "${countindex}" -lt "${recordsamount}" ]
#while internal
do
	echo -n "-"
#	echo  ${records[${countindex}]}
#	echo  ${rrecords[${countindex}]}
	if [ "${records[${countindex}]}" != "${rrecords[${countindex}]}"  ]
#table records mismatch, possible new record from the remote database
		then
#reset internal records counter
		internalindex=0
#search if we have the same record already but in the other place
		while [ "$internalindex" != "$recordsamount" ]
#check while we have records or found the match
		do
		echo -n "+"
		echo "TTTTTTTTTTTTTTTTTT $((${records[$internalindex]}))"
			if [ "${records[$internalindex]}" = "${rrecords[$countindex]}" ]
#database records match
				then
#exiting the internal loop, setting found flag
				internalindex=$recordsamount
				found="TRUE"
				echo "$found"
				else
#next record
				internalindex=`expr $internalindex + 1`
				found="FALSE"
				echo "$found"
			fi
		done
		if [ "${found}" = "FALSE" ]
#not found
		then
#append the new record to the local database
			echo "Record not found, adding record to the database ${rrecords[${countindex}]} "
			mysql -u$LOCALMYSQLUSER -p$LOCALMYSQLPASSWORD $LOCALDBSELECTION --local-infile -e"${rrecords[${countindex}]}"
		else
			echo "Record found, not adding"
		fi
	fi
#go to the next table
  		countindex=`expr $countindex + 1`
  		 #countindex=$(($countindex+1))
done
}




GetLocalTables () {
#suck local tables in the array as SQL commands to compare
        index=1
 #       index - table counter
 #
		for tablename in `echo 'SHOW TABLES;' | mysql -u$LOCALMYSQLUSER -p$LOCALMYSQLPASSWORD $LOCALDBSELECTION | grep -v Table`
# scan every table to assign all the the records to the array
			do
				tables[${index}]=${tablename}
#assign all records to the array record where recindex - records in the table counter
				echo -n "Looking at ${tables[${index}]}"

				for record in ProtectString "`mysqldump -K -u$LOCALMYSQLUSER -p$LOCALMYSQLPASSWORD $REMOTEDBSELECTION ${tablename} | grep INSERT`"
					do
# assign the record
					records[${recindex}]= ProtectString "${record}"
					echo " ${records[${recindex}]} internal local record counter $recindex"
					recindex=$(( $recindex + 1 ))
					echo -n .
					done
# point the recindex to the last record
			#echo ${counters[$index]=$(( $recindex - 1 ))}
# array counters is to count how many records are in each table

#"Local table ${tables[${index}]} aquired in total ${recindex} records"
			index=$(( $index + 1 ))
			done
		index=$(( $index - 1 ))

}


GetRemoteTables () {
#pointer to the first free element and amount of elements at the same time
#rindex=$(( ${#rtables[@]} + 1 ))
#rcounter=$(( ${#rcounters[@]} + 1 ))
#suck local tables in the array as SQL commands to compare
        rindex=1
 #       index - table counter
 #
		for rtablename in `echo 'SHOW TABLES;' | mysql -u$LOCALMYSQLUSER -p$LOCALMYSQLPASSWORD $REMOTEDBSELECTION | grep -v Table`
# scan every table to assign all the the records to the array
			do
				rtables[${rindex}]=${rtablename}

#assign all records to the array record where recindex - records in the table counter
#				echo -n "Looking at ${rtables[${rindex}]}"

				for rrecord in `mysqldump -K -u$LOCALMYSQLUSER -p$LOCALMYSQLPASSWORD $REMOTEDBSELECTION ${rtablename} | grep INSERT`
					do
# assign the record
					rrecords[${rrecindex}]=${rrecord}
					#echo " ${records[${recindex}]} internal local record counter $recindex"
					rrecindex=$(( $rrecindex + 1 ))
#					echo -n .
					done
# point the rrecindex to the last record
			rcounters[$rindex]=$(( $rrecindex - 1 ))
# array counters is to count how many records are in each table

#"Remote table ${rtables[${rindex}]} aquired in total ${rrecindex} records"
			rindex=$(( $rindex + 1 ))
			done
		rindex=$(( $rindex - 1 ))
}


CompareTables () {
#suck local tables in the array as SQL commands to compare
        index=1
 #       index - table counter
 #
		for tablename in `echo 'SHOW TABLES;' | mysql -u$LOCALMYSQLUSER -p$LOCALMYSQLPASSWORD $LOCALDBSELECTION | grep -v Table`
# scan every table to assign all the the records to the array
			do
				tables[${index}]=${tablename}

#assign all records to the array record where recindex - records in the table counter
				echo -n "Looking at ${tables[${index}]}"

				for record in `mysqldump -K -u$LOCALMYSQLUSER -p$LOCALMYSQLPASSWORD $REMOTEDBSELECTION ${tablename} | grep INSERT`
					do
# assign the record
					records[${recindex}]=${record}
					#echo " ${records[${recindex}]} internal local record counter $recindex"
					recindex=$(( $recindex + 1 ))
					echo -n .
					done
# point the recindex to the last record
			echo ${counters[$index]=$(( $recindex - 1 ))}
# array counters is to count how many records are in each table

#"Local table ${tables[${index}]} aquired in total ${recindex} records"
			index=$(( $index + 1 ))
			done
		index=$(( $index - 1 ))

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
	if [ -z $dbhost ]
		then
		echo "No DB host specified... Edit me"
		exit 2
	fi

	if [ -z $username ]
		then
		echo "no username specified... Edit me"
		exit 2
	fi

	if [ -z $password ]
		then
		echo "no password specified ... Edit me"
		exit 2
	fi
	}
ProtectString () {
    echo $'\x27'$@$'\x27'           # ��������� � "�������" �������
}
UnprotectString () {
    eval echo $@                    # �������������� �������������.
}



DatabaseReplication