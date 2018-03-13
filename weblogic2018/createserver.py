
if __name__ == '__main__': 
    from wlstModule import *#@UnusedWildImport
    
import os
import ConfigParser
import sys
#=======================================================================================
# This is an example of a simple WLST offline configuration script. The script creates 
# a simple WebLogic domain using the Basic WebLogic Server Domain template. The script 
#=======================================================================================
import socket
#myname = socket.getfqdn(socket.gethostname())
#adminip = socket.gethostbyname(myname)

def createserver(wlHome,domainHome,adminip,adminport,servername,listenaddress,serverport,CURRENT_HOME):
    loadProperties(CURRENT_HOME+"/boot.properties")   
    Adminport = int(adminport)
    Serverport = int(serverport)
   
    print "wlHome="+wlHome
    print "adminPort="+adminport
    print "adminIP="+adminip
    print "userName="+username
    print "adminPASS="+password
    print "domainHome="+domainHome
    print "serverport="+serverport
 


    readTemplate(wlHome + "/common/templates/wls/wls.jar")


    connect(username,password,adminip+':'+adminport)

    edit()
    startEdit()
    cd('..\..')
    managedServer = create(servername,'Server')
    managedServer.setListenPort(Serverport)
    managedServer.setListenAddress(listenaddress)
    managedServer.setStagingMode("nostage")

    save()


    #def setAttributesFor_webcrcmanage_wls01_srv01_3():
    #  cd("/Servers/webcrcmanage-wls01-srv01")
    #  print "setting attributes for mbean type Server"
    #  set("StagingMode", "nostage")

    activate(block='true')
    disconnect()
    print 'creat managedServer sucessfull!!! '
    exit()

createserver(sys.argv[1],sys.argv[2],sys.argv[3],sys.argv[4],sys.argv[5],sys.argv[6],sys.argv[7],sys.argv[8])
