#-*-coding:utf8-*-
import sys
import subprocess

def execute_command(cmd):
   #print ('start execting cmd...')
   s = subprocess.Popen(args=cmd, stderr=subprocess.STDOUT,stdout=subprocess.PIPE, shell=True,close_fds=True)
   #s.communicate()
   s.wait()
   #print()
   #print ('finish executing cmd....')
   
   #return s.returncode,s.poll()
result = execute_command(sys.argv[1])
#print ('result:--->',result
