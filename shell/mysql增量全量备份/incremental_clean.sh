#!/bin/bash
ReservedNum=30  #保留文件数
FileDir=/opt/mysql_bak/sqlbackup/incremental
date=$(date "+%Y%m%d-%H%M%S")

cd $FileDir   #进入备份目录
FileNum=$(ls -l | grep '^d' | wc -l)   #当前有几个文件夹，即几个备份

while(( $FileNum > $ReservedNum))
do
    OldFile=$(ls -rt | head -1)         #获取最旧的那个备份文件夹
    echo  $date "Delete File:"$OldFile
    rm -rf $FileDir/$OldFile
    let "FileNum--"
done
