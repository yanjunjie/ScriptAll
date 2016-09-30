#!/bin/sh

#Author:Eian
USER_MEM_ARGS="-Xms1024m -Xmx1024m -XX:PermSize=256m -XX:MaxPermSize=512m"
export USER_MEM_ARGS

JAVA_OPTIONS="-Djava.security.egd=file:/dev/zero -Dfile.encoding=UTF-8"
export JAVA_OPTIONS
export SERVER_NAME=fileacptsrv01
/midware/wls12.1.3/user_projects/domains/fileacpt_domain/bin/startManagedWebLogic.sh $SERVER_NAME http://68.168.150.3:8000 2>&1 |/usr/local/sbin/cronolog /midware/wls12.1.3/user_projects/domains/fileacpt_domain/logs/$SERVER_NAME-%Y%m%d.log &

