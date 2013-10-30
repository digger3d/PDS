
#!/bin/bash

EPATH=`pwd`
echo "Assuming path $EPATH, inserting  deploy.conf"
. ../cgi-bin/deploy.conf
echo "Settings are loaded = $FORCEUPLOAD"

TablesReplication () {
#uncomment to protect current changes, needed when running for the first time
#comm -23 ${tablename}_local.tmp ${tablename}_remote.tmp > ${tablename}_diff1.tmp
#comm -23 ${tablename}_remote.tmp ${tablename}_local.tmp > ${tablename}_diff2.tmp
#cat ${tablename}_diff1.tmp ${tablename}_diff2.tmp > ${tablename}_protected.sql
#end of  protection
#echo "DROP TABLE IF EXISTS \`${tablename}\`;">droptable.tmp

#what is a difference between local and remote databases
comm -23 ${tablename}_local.tmp ${tablename}_remote.tmp > ${tablename}_diff.tmp

#select database
echo "USE $REMOTEDBSELECTION;">usedb.tmp

#remove protected fields
comm -23 ${tablename}_diff.tmp ${tablename}_protected.sql > ${tablename}_upd.tmp

#insert dbselection command in the update file
cat usedb.tmp ${tablename}_upd.tmp > ${tablename}.tmp

#insert everything into the local copy of the remote database, database is synchronized at the moment
cat ${tablename}.tmp | mysql -u$LOCALMYSQLUSER -p$LOCALMYSQLPASSWORD -U -f

#rm tmp.*


}

GetLocalTables () {
index=1
for tablename in `echo 'SHOW TABLES;' | mysql -u$LOCALMYSQLUSER -p$LOCALMYSQLPASSWORD $LOCALDBSELECTION | grep -v Table`
	do
	recindex=$(( ${#records[@]} + 1 ))
	tables[${index}]=${tablename}
	sedcommand="s/),(/);:;INSERT INTO \`${tablename}\` VALUES (/g"
	echo  "Looking at ${tables[${index}]}"
	for mcommand in "`mysqldump --no-create-info -K -u$LOCALMYSQLUSER -p$LOCALMYSQLPASSWORD $LOCALDBSELECTION ${tablename} | grep INSERT | sed "${sedcommand}" | grep INSERT`"
		do
		echo $mcommand | awk '{
		i=split($mcommand, records, ":;");
         	for (j=1; j<=i; j++)
             	print ($records[j])
        	}' > ${tablename}_local.tmp
	done
TablesReplication
done
}
GetRemoteTables () {
index=1
for tablename in `echo 'SHOW TABLES;' | mysql -u$LOCALMYSQLUSER -p$LOCALMYSQLPASSWORD $REMOTEDBSELECTION | grep -v Table`
	do
	recindex=$(( ${#records[@]} + 1 ))
	tables[${index}]=${tablename}
	sedcommand="s/),(/);:;INSERT INTO \`${tablename}\` VALUES (/g"
	echo  "Looking at ${tables[${index}]}"
	for mcommand in "`mysqldump --no-create-info -K -u$LOCALMYSQLUSER -p$LOCALMYSQLPASSWORD $REMOTEDBSELECTION ${tablename} | grep INSERT | sed "${sedcommand}" | grep INSERT`"
		do
		echo $mcommand | awk '{
		i=split($mcommand, records, ":;");
         	for (j=1; j<=i; j++)
             	print ($records[j])
        	}' > ${tablename}_remote.tmp
	done
done
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
DatabaseReplication ()
{
# ned
CreateLocalTempDirs
#echo "Dumping local database"
#mysql -u$LOCALMYSQLUSER -p$LOCALMYSQLPASSWORD $LOCALDBSELECTION < $LOCALSTORAGESELECTION/db/$LOCALDBSELECTION.sql
echo "Dumping remote database"
ssh $REMOTESSHUSER:$REMOTESSHPASSWORD@$REMOTESSHHOST "mysqldump -u$REMOTEMYSQLUSER -p$REMOTEMYSQLPASSWORD -h$REMOTEMYSQLHOST --skip-set-charset --compatible=mysql323 --opt $REMOTEDBSELECTION>$REMOTESTORAGESELECTION/$REMOTEDBSELECTION.sql"
echo "Packing remote database"
ssh $REMOTESSHUSER:$REMOTESSHPASSWORD@$REMOTESSHHOST "tar -czf $REMOTESTORAGESELECTION/$REMOTEDBSELECTION.tar $REMOTESTORAGESELECTION/$REMOTEDBSELECTION.sql"
echo "Downloading remote database"
scp -r $REMOTESSHUSER:$REMOTESSHPASSWORD@$REMOTESSHHOST:$REMOTESTORAGESELECTION/$REMOTEDBSELECTION.tar $LOCALSTORAGESELECTION
echo "Unpacking the remote database"
tar -xzf $LOCALSTORAGESELECTION/$REMOTEDBSELECTION.tar $LOCALSTORAGESELECTION
#mysql -u$LOCALMYSQLUSER -p$LOCALMYSQLPASSWORD $LOCALDBSELECTION --local-infile -e"CREATE DATABASE $REMOTEDBSELECTION"
#mysql -u$LOCALMYSQLUSER -p$LOCALMYSQLPASSWORD $LOCALDBSELECTION --local-infile -e"CREATE DATABASE $REMOTEDBSELECTION"
echo "Loading remote database in the replication database\n BEWARE!!! you need to have BOTH mysql servers versions above 5 and set auto_increment_increment and offset properly, f.ex. on both auto_increment_increment=10 on local auto_icrement_offset=1 on remote auto_icrement_offset=5\n OTHERWISE YOU ARE COMPLETELY REPLACING THE DATABASE!!!"
######################################################## NEED TO HAVE JUST UPDATE TABLES
mysql -u$LOCALMYSQLUSER -p$LOCALMYSQLPASSWORD -U -f $LOCALDBSELECTION < $LOCALSTORAGESELECTION/$REMOTEDBSELECTION.sql
echo "Synchronizing databases complete"

#CompareTables

#echo "We have $index tables with $recindex records locally and"
GetRemoteTables
GetLocalTables
#echo "Locally we have $index tables with $recindex records and remotely we have $rindex tables with $recindex records"
#Tables

#dump the database
mysqldump -u$LOCALMYSQLUSER -p$LOCALMYSQLPASSWORD --compatible=mysql323 --opt $REMOTEDBSELECTION>$LOCALSTORAGESELECTION/$REMOTEDBSELECTION.sql
#create local archive (adding new database to the old remote file set)
#echo "packing $LOCALSTORAGESELECTION/$REMOTEDBSELECTION.sql in $LOCALSTORAGESELECTION/files/$REMOTEDBSELECTION.tar"
#tar -czf $LOCALSTORAGESELECTION/files/$REMOTEDBSELECTION.tar $LOCALSTORAGESELECTION/$REMOTEDBSELECTION.sql
#upload the file
echo "Uploading remote database"
scp -r $LOCALSTORAGESELECTION/$REMOTEDBSELECTION.sql $REMOTESSHUSER:$REMOTESSHPASSWORD@$REMOTESSHHOST:$REMOTESTORAGESELECTION
#untar the archive
#ssh $REMOTESSHUSER:$REMOTESSHPASSWORD@$REMOTESSHHOST tar -xzf $REMOTESTORAGESELECTION/files/$REMOTEDBSELECTION.tar $REMOTESTORAGESELECTION
#update the database
#rm -r $LOCALSTORAGESELECTION/
ssh $REMOTESSHUSER:$REMOTESSHPASSWORD@$REMOTESSHHOST "mysql -u$REMOTEMYSQLUSER -p$REMOTEMYSQLPASSWORD -h$REMOTEMYSQLHOST -U -f $REMOTEDBSELECTION < $REMOTESTORAGESELECTION/$REMOTEDBSELECTION.sql"
#Remove the temp files
#ssh $REMOTESSHUSER:$REMOTESSHPASSWORD@$REMOTESSHHOST rm -r $REMOTESTORAGESELECTION/$REMOTEDBSELECTION.sql
#ssh $REMOTESSHUSER:$REMOTESSHPASSWORD@$REMOTESSHHOST rm -r $REMOTESTORAGESELECTION/$REMOTEDBSELECTION.tar
#rm -r $LOCALSTORAGESELECTION/files
#mysqldump --opt old_db | mysql new_db
mysqldump -u$LOCALMYSQLUSER -p$LOCALMYSQLPASSWORD --opt $LOCALDBSELECTION | mysql -u$LOCALMYSQLUSER -p$LOCALMYSQLPASSWORD "${REMOTEDBSELECTION}_backup"
mysqldump -u$LOCALMYSQLUSER -p$LOCALMYSQLPASSWORD --opt $REMOTEDBSELECTION | mysql -u$LOCALMYSQLUSER -p$LOCALMYSQLPASSWORD $LOCALDBSELECTION


}

DatabaseReplication
