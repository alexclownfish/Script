#!/bin/bash
export LANG=en_US.UTF-8
filedate=$(date +%y%m%d)
AllBackDir=/opt/mysql_bak/sqlbackup/allbinlog
BackDir=/opt/mysql_bak/sqlbackup/incremental/$filedate   #备份bin-log文件路径
LogFile=$BackDir/binlog.log      #日志文件路径
BinDir=/var/lib/mysql    #bin-log文件所在目录
BinFile=/var/lib/mysql/binlog.index     #bin-log索引文件
#mysqladmin=/usr/local/mysql/bin/mysqladmin              #mysqladmin命令绝对路径
if [ ! -d $BackDir  ];then
 mkdir -p $BackDir
fi
mysqladmin  flush-logs -pywz0207.        #这个是用于产生新的mysql-bin.00000*文件，开始导出之前刷新日志。请注意：假如一次导出多个数据库(使用选项–databases或者–all-databases)，将会逐个数据库刷新日志写入binlog
Counter=`wc -l $BinFile |awk '{print $1}'`      #统计bin-log索引文件mysql-bin.index内bin-log文件个数
NextNum=0
#这个for循环用于比对$Counter,$NextNum这两个值来确定文件是不是存在或最新的。
for file in `cat $BinFile`
do
    base=`basename $file`       #basename用于截取mysql-bin.00000*文件名，去掉./mysql-bin.000005前面的./
    NextNum=`expr $NextNum + 1`
    if [ $NextNum -eq $Counter ]
    then
        echo $base skip! >> $LogFile
    else
        dest=$BackDir/$base
        if test -e $dest
        #test -e用于检测目标文件是否存在，存在就写exist!到$LogFile去。
        then
            echo $base exist! >> $LogFile
        else
            cp $BinDir/$base $BackDir
            cp $BinDir/$base $AllBackDir
            echo $base copying >> $LogFile
        fi
    fi
done
echo `date +"%Y年%m月%d日 %H:%M:%S"` Bakup succ! >> $LogFile
sleep 5
