#!/bin/sh
#single node
export JAVA_HOME="/opt/jdk1.7.0_80"
export PATH="$JAVA_HOME/bin:$PATH"
export TOMCAT_HOME="/opt/tomcat7"
cd /tmp
tar -zxvf  apache-tomcat-7.0.68.tar.gz
cp -R apache-tomcat-7.0.68 $TOMCAT_HOME
cp dubbo-admin-2.5.4.war $TOMCAT_HOME/webapps
#start tomcat
$TOMCAT_HOME/bin/startup.sh 
#init config
#sed -i 's/dubbo.registry.address=zookeeper://127.0.0.1:2181/dubbo.registry.address=zookeeper://127.0.0.1:2181/g' /opt/tomcat7/webapps/dubbo-admin-2.5.4/WEB-INF/dubbo.properties
#restart tomcat
#/opt/tomcat7/bin/shutdown.sh
#/opt/tomcat7/bin/startup.sh

#dubbo admin url
#http://ip:8080/dubbo-admin-2.5.4/
#username:root/root
