#-*-coding:utf8-*-

import subprocess

def execute_command(cmd):
#   print ('start execting cmd...')
   s = subprocess.Popen(args=cmd, stderr=subprocess.STDOUT,stdout=subprocess.PIPE, shell=True,close_fds=True)
   #s.communicate()
   s.wait()

cmd = '/midware/wls12.1.3/script/start-AdminServer.sh'
result = execute_command(cmd)
#print ('result:--->',result)
