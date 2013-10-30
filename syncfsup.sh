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


echo "Synchronizing file tree from $LOCALWWWROOT/ to $REMOTESSHHOST:$REMOTWWWROOT"
rsync -av -e ssh $LOCALWWWROOT/ $REMOTESSHHOST:$REMOTEWWWROOT
if [ $? = 0 ]; then
	echo "synchronization is completed"
else
	echo "synchronization is failed"
fi

