#!/bin/bash
date=$(date +%Y-%m-%d-%H:%M)
echo -e "---------------------------------------以下为 $date 重启结果-------------------------------------------------" >> $LogDir
LogDir=./mount.log
SelinuxStatus=`cat /etc/selinux/config | grep SELINUX= | grep -v "#" | awk '{print $1}' | cut -d = -f 2`
FirewalldStatus=`systemctl status firewalld | grep Active | awk {'print $2'}`
#关闭防火墙
StopFirewalld() {
   systemctl stop firewalld
   systemctl disable firewalld
}
#关闭selinux
OffSelinux(){
  #永久关闭selinux
  sed -i 's/SELINUX=enforcing/SELINUX=disabled/' /etc/selinux/config
  #临时关闭selinux
  setenforce 0
}

if [ $FirewalldStatus == inactive ]; then
    echo -e "FirewalldStatus is Already Off" >> $LogDir
else
    StopFirewalld
    echo -e "FirewalldStatus is Off" >> $LogDir
fi


if [ $SelinuxStatus == disabled  ]; then
    echo -e "SelinuxStatus Already Off" >> $LogDir
else
    OffSelinux
    echo -e "SelinuxStatus is Off" >> $LogDir
fi

ethtool -K eth0 tx off
if [ $? -eq 0 ]; then
    echo -e "Checksum permanently closed" >> $LogDir
else
    echo -e "Checksum permanently closed failed" >> $LogDir
fi

#sed -i '/initcheck/d' /etc/rc.local
#if [ $? -eq 0 ]; then
#    echo -e "remove Init scripts successful" >> $LogDir
#else
#    echo -e "remove Init scripts fail" >> $LogDir
#    exit 1
#fi
echo -e "Init Check Done!!!">> $LogDir
