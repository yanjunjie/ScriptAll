cd /tmp
#jdk1.7 install
if [ ! -f "jdk-7u80-linux-x64.gz" ];then
echo "jdk-7u80-linux-x64.gz not found!"
exit 1
fi
tar -zxvf jdk-7u80-linux-x64.gz
cp -R jdk1.7.0_80 /opt/jdk1.7.0_80

