#!/bin/bash
#author: ywz
#"---------"包括这部分是unmount操作可以注释掉，如果不需要交互则将disk取消注释，Step3以上全部注释即可
Disk=/dev/vda
Total=`fdisk -l | grep "/dev/vda" | awk {'print $1'} | wc -l`
NeedCount=`expr ${Total} - 1`
DiskNum=`expr ${NeedCount} + 1`
DiskName="$Disk$DiskNum"
echo -e "\e[1;42mDisk partion scripts!!!!!\e[0m"
echo -e "\e[1;32mDisk list:\e[0m"
fdisk -l | grep -o "Disk /dev/[a-z]d[a-z]"
read -p "choose disk:" disk
if [ $Disk == q ]; then
	echo "quiting..."
	sleep 1
	echo "quited!!"
	exit 1
fi
#------------------------------------unmount已有磁盘（根据需求选择）----------------------------------
until fdisk -l | grep -o "Disk /dev/[a-z]d[a-z]" | grep "^Disk $Disk$" &> /dev/null;do
	fdisk -l | grep -o "Disk /dev/[a-z]d[a-z]"
	read -p "unknown option,choose again:" disk
done

echo -e "\e[1;31mWarning!!!\e[0m"
echo -e "\e[1;31mThe followed action may destroy the whole disk !!!!\e[0m"
read -p "Do you still want to Continue(y|n):" des
until [ $des == "y" -o $des == "n" ];do
	read -p "Choose y or n :" des
done
if [ $des == "n" ];then
        echo "quiting..."
        sleep 1
        echo "quited!!"
        exit 1
fi

echo -e "\e[1;42mStep1: Checking the umounting th mounted disks....\e[0m"
for I in `mount | grep "$Disk" | awk -F " " '{print $1}'`;do
	fuser -km  $I
	umount $I
done
echo -e "\e[1;32mUnmount finished!!!\e[0m"
sleep 1
echo -e "\e[1;42mStep2: Initialing the disks....\e[0m"
dd if=/dev/zero of=$Disk bs=512 count=1
sync
sleep 3
echo -e "\e[1;32mInitial finished!!!!\e[0m"
sleep 1
#------------------------------------------------------------------------------------------------------
echo -e "\e[1;42mStep3: Parting the disks....\e[0m"
echo "
     n
     p
      
      
      
     t
      
     8e
     w" | fdisk $Disk &> /dev/null
partprobe &> /dev/null
echo -e "\e[1;32mPart finished!!!!\e[0m"
sleep 3
echo -e "\e[1;42mStep4: Formating disks....\e[0m"
pvcreate $DiskName &> /dev/null
vgextend centos $DiskName &> /dev/null
lvextend /dev/centos/root $DiskName &> /dev/null
xfs_growfs /dev/centos/root &> /dev/null
echo -e "\e[1;32mFormat finished!!!!\e[0m"
