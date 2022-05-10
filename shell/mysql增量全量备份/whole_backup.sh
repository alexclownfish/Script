#!/bin/bash
dumpdate=$(date +%H%M%S)        #备份sql文件日期（时分秒）及文件名
filedate=$(date +%y%m%d)        #所生成备份目录的日期（年月日）
#mysqldump=/usr/local/mysql/bin/mysqldump        #mysqldump工具所在绝对路径
mulu=/opt/mysql_bak/sqlbackup/whole/$filedate          #生成备份目录路径
oldbinlog=/opt/mysql_bak/sqlbackup/oldbinlog
allbinlog=/opt/mysql_bak/sqlbackup/allbinlog
#判断备份目录是否存在，存在则执行mysqldump，不存在则创建目录
if [ ! -d $mulu  ];then
 mkdir -p $mulu
fi
#执行备份命令
mysqldump -pywz0207. --quick --events --all-databases --flush-logs --delete-master-logs --single-transaction > ${mulu}/whole-${dumpdate}.sql
sleep 5
cd $allbinlog
mv binlog.0000* $oldbinlog
