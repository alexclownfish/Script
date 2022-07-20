#!/bin/bash
#author: ywz
echo -e "Disk Part Script!!!!!" >> ./mount.log
Disk=`fdisk -l | awk '{if($0!="")print}' | sed -n '1,1p' | awk '{print $2}' | awk -F":" '{print $1}'`
if [ ! -n "$Disk" ] ;then
echo -e "Get target Disk name fail!" >> ./mount.log
exit 1
else
echo -e "Get target Disk name successful!" >> ./mount.log
echo -e "Target disk name is [$Disk]" >> ./mount.log
fi
#Get the number of existing disks
Total=`fdisk -l | grep "$Disk" | awk {'print $1'} | wc -l`
NeedCount=`expr ${Total} - 1`
DiskNum=`expr ${NeedCount} + 1`
DiskName="$Disk$DiskNum"
echo -e "Ready to create：$DiskName" >> ./mount.log
GenDiskName=`df -hT | grep root | awk {'print $1'}`

if [ ! -n "$GenDiskName" ] ;then
echo -e "Get target GenDiskName fail!" >> ./mount.log
exit 1
else
echo -e "Get target GenDiskName successful!" >> ./mount.log
echo -e "Target GenDiskName is [$GenDiskName]" >> ./mount.log
fi

echo -e "Ready to mount：$GenDiskName" >> ./mount.log
echo -e "-----------------------------------------------------------------------------" >> ./mount.log
echo -e "Start Partition" >> ./mount.log

echo "
     n
     p



     t

     8e
     w" | fdisk $Disk &>> ./mount.log
echo -e "-----------------------------------------------------------------------------" >> ./mount.log
echo -e "Start Mount" >> ./mount.log
partprobe &>> ./mount.log
sleep 3
pvcreate $DiskName &>> ./mount.log

if [ $? -eq 0 ]; then
    echo -e "pvcreate successful" >> ./mount.log
else
    echo -e "pvcreate fail" >> ./mount.log
    exit 1
fi
vgextend centos $DiskName &>> ./mount.log
if [ $? -eq 0 ]; then
    echo -e "vgextend successful" >> ./mount.log
else
    echo -e "vgextend fail" >> ./mount.log
    exit 1
fi
lvextend $GenDiskName $DiskName &>> ./mount.log
if [ $? -eq 0 ]; then
    echo -e "lvextend successful" >> ./mount.log
else
    echo -e "lvextend fail" >> ./mount.log
    exit 1
fi
xfs_growfs $GenDiskName &>> ./mount.log
if [ $? -eq 0 ]; then
    echo -e "xfs_growfs successful" >> ./mount.log
else
    echo -e "xfs_growfs fail" >> ./mount.log
    exit 1
fi
sed -i '/mount/d' /etc/rc.local
if [ $? -eq 0 ]; then
    echo -e "remove scripts successful" >> ./mount.log
else
    echo -e "remove boot scripts fail" >> ./mount.log
    exit 1
fi
echo -e "Disk Part Done!!!">> ./mount.log

