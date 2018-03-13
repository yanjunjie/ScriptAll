#!/bin/sh
#
#自定义
WL_HOME="/midware/wls12.1.3"
JAVA_HOME="/midware/jdk1.7.0_80"
DOMAIN_HOME='/midware/wls12.1.3/user_projects/domains'
CLASS_PATH="$WL_HOME/wlserver/server/lib/weblogic.jar"
ADMIN_IP=$1
ADMIN_PORT=$2
APP_NAME=$3
TARGET=$4
username=$5
password=$6
DOMAIN_NAME=$(echo $APP_NAME |sed -e 's/-//g' |sed 's/$/_domain/')

#注册应用
function register(){
   $JAVA_HOME/bin/java -cp $CLASS_PATH weblogic.Deployer -adminurl t3://$ADMIN_IP:$ADMIN_PORT  -user $username -password  $password  -name ${APP_NAME}  -targets ${TARGET} -remote /midware/wls12.1.3/applications/$APP_NAME


  grep -q ${APP_NAME} $DOMAIN_HOME/${DOMAIN_NAME}/config/config.xml
  if [ "$?" -eq "0" ]; then
      echo "1"
  else
      echo "0"
  fi
}

usage()
{
  echo ""
  echo 'Usage: ./register.sh 10.0.0.0 8010 web-crc-manage AdminServer weblogic wlspass' 
  echo ""
  exit 1
}


if [ ${#} = 0 ]; then
 usage
fi

register

