#!/bin/sh
#DATE=$(date "+%Y%m%d")
DOMAIN_HOME=`cat config.ini |grep DOMAIN_HOME |cut -d "=" -f 2`
echo $DOMAIN_HOME
cp start-admin.sh  $DOMAIN_HOME/bin
chown weblogic:midware $DOMAIN_HOME/bin/start-admin.sh
chmod 755 $DOMAIN_HOME/bin/start-admin.sh
$DOMAIN_HOME/bin/start-admin.sh 
sleep 2
tail -f $DOMAIN_HOME/logs/admin-$(date "+%Y%m%d").log
