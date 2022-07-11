#!/bin/bash
#author: ywz
echo -e "\e[1;42mGet Disk Params!!!!!\e[0m"
Disk=/dev/vda
#Get the number of existing disks
Total=`fdisk -l | grep "/dev/vda" | awk {'print $1'} | wc -l`
NeedCount=`expr ${Total} - 1`
DiskNum=`expr ${NeedCount} + 1`
DiskName="$Disk$DiskNum"
GenDiskName=`df -hT | grep root | awk {'print $1'}`
echo -e "\e[1;42mStep2: Parting the disks....\e[0m"
echo "
     n
     p



     t

     8e
     w" | fdisk $Disk &> /dev/null
partprobe &> /dev/null
echo -e "\e[1;32mPart finished!!!!\e[0m"
sleep 3
echo -e "\e[1;42mStep3: Formating disks....\e[0m"
pvcreate $DiskName &> /dev/null
vgextend centos $DiskName &> /dev/null
lvextend $GenDiskName $DiskName &> /dev/null
xfs_growfs $GenDiskName &> /dev/null
echo -e "\e[1;32mFormat finished!!!!\e[0m"
