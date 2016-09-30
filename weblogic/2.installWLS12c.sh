#!/bin/sh
output=`id`
UserID=`echo $output | cut -f1 -d ' ' | cut -f2 -d '=' | cut -f2 -d '(' | cut -f1 -d ')'`
if [ "$UserID" != "weblogic" ]; then
   echo "This script must be executed as weblogic"
   exit 1
fi

echo '==============start the installation of weblogici====================='
if [ ! -f "config.ini" ];then
   echo "config.ini is not found!"
   exit
fi
java_home=`cat config.ini  |grep JAVA_HOME |cut -d "=" -f 2`
wls_home=`cat config.ini  |grep WLS_HOME |cut -d "=" -f 2`
$java_home/bin/java -jar /midware/fmw_12.1.3.0.0_wls.jar -silent -responseFile /midware/script/wls12c.resp  -invPtrLoc /midware/script/oraInst.loc

#echo ' ==============start to create pcs_domain============================='
#sh $wls_home/common/bin/wlst.sh -i createdomain.py

#echo ' ==============start to create managerServer============================='
#sh $WLS_HOME/wlserver_10.3/common/bin/wlst.sh -i createServer.py

