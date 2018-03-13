import paramiko
import sys

def getfiles(username,password,hostname,domain_home):
  try:
    t=paramiko.Transport((hostname,22))
    t.connect(username=username,password=password)
    sftp=paramiko.SFTPClient.from_transport(t)

    sftp.get(domain_home+"/security/SerializedSystemIni.dat",domain_home+"/security/SerializedSystemIni.dat")

    t.close()
  except Exception,e:
    print str(e)
getfiles(sys.argv[1],sys.argv[2],sys.argv[3],sys.argv[4])
