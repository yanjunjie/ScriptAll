#!/bin/sh
# copy the boot.properties  to the ManagerServer.
#
#LOCALIP=$(ifconfig |grep "inet addr" |head -1 |awk '{print $2}'|awk -F':' '{print $2}')
ADMIN_IP=$1
ADMINPORT=$2
DOMAIN_HOME=$3
DOMAIN_NAME=$4
SERVERNAME=$5
CURRENT_HOME=$6
TARGETDIR=$DOMAIN_HOME/servers/$SERVERNAME/security

if [ ! -f $TARGETDIR/boot.properties ]; then
  mkdir -p $TARGETDIR
  cp -f $CURRENT_HOME/boot.properties $TARGETDIR
  echo "INFO: copied boot.properties to $SERVERNAME"
else
  echo "ERROR: the boot.properties already exists. "
fi


cat >> start-$SERVERNAME.sh <<EOF
#!/bin/sh
#
# weblogic Server shell script version.
#

DOMAIN_HOME=$DOMAIN_HOME
SERVER_NAME=$SERVERNAME
ADMIN_IP=$ADMIN_IP
ADMIN_PORT=$ADMINPORT

if [ "\`whoami\`" = "pbcc" ];then
    USER_MEM_ARGS="-Xms2048m -Xmx2048m -XX:PermSize=256m -XX:MaxPermSize=512m"
    export USER_MEM_ARGS

    JAVA_OPTIONS="-Djava.security.egd=file:/dev/zero -Dfile.encoding=UTF-8 -Dweblogic.threadpool.MinPoolSize=200 -Dweblogic.threadpool.MaxPoolSize=200"
    export JAVA_OPTIONS

    nohup \$DOMAIN_HOME/bin/startManagedWebLogic.sh \$SERVER_NAME http://\$ADMIN_IP:\$ADMIN_PORT  2>&1 |/usr/local/sbin/cronolog \$DOMAIN_HOME/logs/\$SERVER_NAME-%Y%m%d.log &

else
    echo "ERROR,startup is wrong,you must use pbcc user!"
fi

EOF


cat >> stop-$SERVERNAME.sh <<EOF
#!/bin/sh
#
# weblogic Server shell script version.
#

DOMAIN_HOME=$DOMAIN_HOME
SERVER_NAME=$SERVERNAME
ADMIN_IP=$ADMIN_IP
ADMIN_PORT=$ADMINPORT
echo "stopping weblogic ManagedServer \$SERVER_NAME..."
\$DOMAIN_HOME/bin/stopManagedWebLogic.sh \$SERVER_NAME t3://\$ADMIN_IP:\$ADMIN_PORT >> "\${DOMAIN_HOME}/AdminServerShutdown.log" 2>&1

echo "weblogic ManagedServer[\$SERVER_NAME] stopped."


EOF


script_dir=/midware/wls12.1.3/script
if [ ! -d $script_dir ];then
   mkdir -p $script_dir
fi
cp start-$SERVERNAME.sh  $script_dir
cp stop-$SERVERNAME.sh  $script_dir
echo "INFO: copied start-$SERVERNAME.sh to $script_dir"
echo "INFO: copied stop-$SERVERNAME.sh to $script_dir"
echo "启停脚本已成功复制到 $script_dir"
chown -R pbcc:mw $script_dir
chmod 755 $script_dir/start-$SERVERNAME.sh
chmod 755 $script_dir/stop-$SERVERNAME.sh

rm -rf start-$SERVERNAME.sh
rm -rf stop-$SERVERNAME.sh
