from java.util import *
from javax.management import *
import javax.management.Attribute
import sys

def initConfigRun(adminServerListenAddress,adminServerListenPort,CURRENT_HOME):
  loadProperties(CURRENT_HOME+"/boot.properties")

  try:
      URL="t3://"+adminServerListenAddress+":"+adminServerListenPort
      connect(username, password, URL)

  except WLSTException:
      print 'No server is running at '+URL+', the script will start a new server'


def startTransaction():
  edit()
  startEdit()

def endTransaction():
  startEdit()
  save()
  activate(block="true")

def endOfConfigToScriptRun():
    #Save the changes you have made
    # shutdown the server you have started
    disconnect()
    exit()
    print 'Done executing the script.'


def create_Cluster(clusterName,serverName):
  cd("/")
  try:
    print "creating mbean of type Cluster ... "
    theBean = cmo.lookupCluster(clusterName)
    if theBean == None:
      cmo.createCluster(clusterName)
      cd("/Servers/"+serverName)
      print "setting attributes for mbean type Server"
      bean = getMBean("/Clusters/"+clusterName)
      cmo.setCluster(bean)
    else:
      cd("/Servers/"+serverName)
      print "setting attributes for mbean type Server"
      bean = getMBean("/Clusters/"+clusterName)
      cmo.setCluster(bean)
  except java.lang.UnsupportedOperationException, usoe:
    pass
  except weblogic.descriptor.BeanAlreadyExistsException,bae:
    pass
  except java.lang.reflect.UndeclaredThrowableException,udt:
    pass


try:
  initConfigRun(sys.argv[1],sys.argv[2],sys.argv[5])
  startTransaction()
  create_Cluster(sys.argv[3],sys.argv[4])
  endTransaction()

finally:
  endOfConfigToScriptRun()

