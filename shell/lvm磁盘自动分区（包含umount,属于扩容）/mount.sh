#!/bin/bash
#author: ywz
echo -e "Disk Part Script!!!!!" >> $LogDir
LogDir=./mount.log
Disk=`fdisk -l | awk '{if($0!="")print}' | sed -n '1,1p' | awk '{print $2}' | awk -F":" '{print $1}'`
if [ ! -n "$Disk" ] ;then
echo -e "Get target Disk name fail!" >> $LogDir
exit 1
else
echo -e "Get target Disk name successful!" >> $LogDir
echo -e "Target disk name is [$Disk]" >> $LogDir
fi
#Get the number of existing disks
Total=`fdisk -l | grep "$Disk" | awk {'print $1'} | wc -l`
NeedCount=`expr ${Total} - 1`
DiskNum=`expr ${NeedCount} + 1`
DiskName="$Disk$DiskNum"
echo -e "Ready to create：$DiskName" >> $LogDir
GenDiskName=`df -hT | grep root | awk {'print $1'}`

if [ ! -n "$GenDiskName" ] ;then
echo -e "Get target GenDiskName fail!" >> $LogDir
exit 1
else
echo -e "Get target GenDiskName successful!" >> $LogDir
echo -e "Target GenDiskName is [$GenDiskName]" >> $LogDir
fi

echo -e "Ready to mount：$GenDiskName" >> $LogDir
echo -e "-----------------------------------------------------------------------------" >> $LogDir
echo -e "Start Partition" >> $LogDir

echo "
     n
     p



     t

     8e
     w" | fdisk $Disk &>> $LogDir
echo -e "-----------------------------------------------------------------------------" >> $LogDir
echo -e "Start Mount" >> $LogDir
partprobe &>> $LogDir
sleep 3
pvcreate $DiskName &>> $LogDir

if [ $? -eq 0 ]; then
    echo -e "pvcreate successful" >> $LogDir
else
    echo -e "pvcreate fail" >> $LogDir
    exit 1
fi

vgextend centos $DiskName &>> $LogDir

if [ $? -eq 0 ]; then
    echo -e "vgextend successful" >> $LogDir
else
    echo -e "vgextend fail" >> $LogDir
    exit 1
fi

lvextend $GenDiskName $DiskName &>> $LogDir

if [ $? -eq 0 ]; then
    echo -e "lvextend successful" >> $LogDir
else
    echo -e "lvextend fail" >> $LogDir
    exit 1
fi

xfs_growfs $GenDiskName &>> $LogDir

if [ $? -eq 0 ]; then
    echo -e "xfs_growfs successful" >> $LogDir
else
    echo -e "xfs_growfs fail" >> $LogDir
    exit 1
fi

sed -i '/mount/d' /etc/rc.local

if [ $? -eq 0 ]; then
    echo -e "remove scripts successful" >> $LogDir
else
    echo -e "remove boot scripts fail" >> $LogDir
    exit 1
fi
echo -e "Disk Part Done!!!">> $LogDir

