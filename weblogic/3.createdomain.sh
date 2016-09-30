#!/bin/sh
wls_home=`cat config.ini  |grep WLS_HOME |cut -d "=" -f 2`
$wls_home/common/bin/wlst.sh -i createdomain.py
