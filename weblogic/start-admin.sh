#!/bin/sh

#Author:Eian
domain=base_domain
if [ "`whoami`" = "weblogic" ];then
USER_MEM_ARGS="-Xms512m -Xmx512m -XX:PermSize=128m -XX:MaxPermSize=256m"
export USER_MEM_ARGS

JAVA_OPTIONS="-Djava.security.egd=file:/dev/zero -Dfile.encoding=UTF-8"
export JAVA_OPTIONS

/midware/wls12.1.3/user_projects/domains/$domain/bin/startWebLogic.sh 2>&1 |/usr/local/sbin/cronolog /midware/wls12.1.3/user_projects/domains/$domain/logs/admin-%Y%m%d.log &
else
echo "ERROR,startup is wrong,you must use weblogic user!"
fi

