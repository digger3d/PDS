EPATH=`pwd`
echo "Assuming path $EPATH, inserting  $EPATH/deploy.conf"
. deploy.conf
. $EPATH/dump1

echo "Synchronizing file tree from $LOCALWWWROOT/ to $REMOTESSHHOST:$REMOTWWWROOT"
rsync -av -e ssh $LOCALWWWROOT/ $REMOTESSHHOST:$REMOTEWWWROOT

