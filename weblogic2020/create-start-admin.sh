#!/bin/sh
#DATE=$(date "+%Y%m%d")
DOMAIN_NAME=$1
DOMAIN_HOME=$2
CURRENT_HOME=$3
SERVERNAME=AdminServer
SOURCE=boot.properties
TARGETDIR=$DOMAIN_HOME/servers/$SERVERNAME/security
if [ ! -f $TARGETDIR/boot.properties ]; then
  mkdir -p $TARGETDIR
  cp -f $CURRENT_HOME/$SOURCE $TARGETDIR
  echo "INFO: copied boot.properties to $SERVERNAME"
else
  rm -rf $TARGETDIR/boot.properties
  echo "rm: the boot.properties files."
  cp -f $CURRENT_HOME/$SOURCE $TARGETDIR
  echo "INFO: copied boot.properties to $SERVERNAME"
fi



cat >> start-$SERVERNAME.sh <<EOF
#!/bin/sh
#
# weblogic Server shell script version.
#
DOMAIN_HOME=$DOMAIN_HOME 

if [ "\`whoami\`" = "pbcc" ];then
    USER_MEM_ARGS="-Xms512m -Xmx512m -XX:PermSize=128m -XX:MaxPermSize=256m"
    export USER_MEM_ARGS

    JAVA_OPTIONS="-Djava.security.egd=file:/dev/zero -Dfile.encoding=UTF-8"
    export JAVA_OPTIONS

    nohup \$DOMAIN_HOME/bin/startWebLogic.sh 2>&1 |/usr/local/sbin/cronolog \$DOMAIN_HOME/logs/admin-%Y%m%d.log &
    #sleep 2
    #tail -f \$DOMAIN_HOME/logs/admin-\$(date "+%Y%m%d").log

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

echo "stopping weblogic AdminServer..."
sh \$DOMAIN_HOME/bin/stopWebLogic.sh >"\${DOMAIN_HOME}/AdminServerShutdown.log" 2>&1

echo "weblogic Adminserver stopped."

EOF

script_dir="/midware/wls12.1.3/script"
if [ ! -d $script_dir ];then
   mkdir -p $script_dir
fi
cp start-$SERVERNAME.sh  $script_dir
cp stop-$SERVERNAME.sh  $script_dir

echo "
alias cdbin='cd /midware/wls12.1.3/script'
alias cdlog='cd /midware/wls12.1.3/user_projects/domains/$DOMAIN_NAME/logs' " >> ~/.bash_profile


echo "INFO: copied start-$SERVERNAME.sh to $script_dir"
echo "INFO: copied stop-$SERVERNAME.sh to $script_dir"
echo "启停脚本已成功复制到 $script_dir"
chown -R pbcc:mw $script_dir
chmod 755  $script_dir/start-$SERVERNAME.sh
chmod 755  $script_dir/stop-$SERVERNAME.sh
chown -R pbcc:mw $script_dir

rm -rf start-$SERVERNAME.sh
rm -rf stop-$SERVERNAME.sh

#sh $script_dir/start-$SERVERNAME.sh
