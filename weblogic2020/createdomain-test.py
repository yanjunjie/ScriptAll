if __name__ == '__main__':
    from wlstModule import *#@UnusedWildImport
import sys
import os
import ConfigParser

loadProperties("boot.properties")
def createdomain(wlHome,domainHome,adminip,adminport):
    print "wlHome="+wlHome
    print "adminPort="+adminport
    print "adminIP="+adminip
    print "domainHome="+domainHome
    readTemplate(wlHome + "/common/templates/wls/wls.jar")
    Adminport = int(adminport)
     
    cd('Servers/AdminServer')
    set('ListenAddress',adminip)
    set('ListenPort',Adminport)
    set("StagingMode", "nostage")
    create('AdminServer','SSL')
    cd('SSL/AdminServer')
    set('Enabled', 'false')

    #=======================================================================================
    # Define the user password for weblogic.
    #=======================================================================================

    cd('/')
    cmo=cd('Security/base_domain/User/weblogic')
    # Please set password here before using this script, e.g. cmo.setPassword('value')
    cmo.setPassword(password)
    #set('StagingMode','Production')
    #=======================================================================================
    # Write the domain and close the domain template.
    #=======================================================================================
    #Boolean value,whether to allow an existing domain to be overwritten,defaults to false
    setOption('OverwriteDomain', 'true')
    #Used in the mode ,dev or prod,the option defaults to dev
    setOption('ServerStartMode', 'prod')


    #writeDomain(beaHome + '/user_projects/domains/pcs_domain')
    writeDomain(domainHome)
    closeTemplate()
    print "script returns SUCCESS"

    #=======================================================================================
    # Exit WLST.
    #=======================================================================================

    exit()

createdomain(sys.argv[1],sys.argv[2],sys.argv[3],sys.argv[4])
