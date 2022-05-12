# 1，前言。
当数据库文件以及量级不大的时候，我们可以采用全量备份的策略来进行备份。但是当数据库文件有一定量级的时候，再使用全量备份，就显得有些笨拙了。

内网数据虽然没有特别重要，但是备份也是不可或缺的一个环节，朱子有言：“宜未雨而筹谋，勿临渴而掘井”，这句话放在备份领域简直就是无法颠破的真理。

因此，在内网的数据，我们也做了全量备份，今天就来整理一下备份的脚本以及备份的策略以及备份的灾备恢复。

增量备份的成立依赖于 mysql 的 bin-log 原理，我们在数据库中的每一步增删改查操作都会记录在 binlog 日志当中，那么通过先对数据库进行一次全量备份，备份同时将 binlog 日志刷新，在这次备份之后的所有操作都会记录在新增的 binlog 日志当中，在增量备份当中我们只需要对增加的 binlog 进行备份，就实现了对不断增加内容的数据库的完美备份了。

当数据库出现异常的时候，我们可以先恢复最近一次的全量备份，接着将增量备份的文件一个一个按顺序恢复即可实现原来数据库的恢复。

# 2，备份。
## 1，开启 bin-log 记录。
执行增量备份的前提条件是 MySQL 打开binlog日志功能，在my.cnf中加入；我这里测试使用的是mysql8.0.22单机版默认已开启bin-log
```
log-bin=/data/mysql/mysql-bin  #“log-bin=”后的字符串为日志记载目录，如果不指定位置的话，默认在mysql的data目录下。
```
## 2，首先是全量备份的脚本。
```
#!/bin/bash
dumpdate=$(date +%H%M%S)        #备份sql文件日期（时分秒）及文件名
filedate=$(date +%y%m%d)        #所生成备份目录的日期（年月日）
#mysqldump=/usr/local/mysql/bin/mysqldump        #mysqldump工具所在绝对路径
mulu=/opt/mysql_bak/sqlbackup/whole/$filedate          #生成备份目录路径
#判断备份目录是否存在，存在则执行mysqldump，不存在则创建目录
if [ ! -d $mulu  ];then
 mkdir -p $mulu
fi
#执行备份命令
mysqldump -pywz0207. --quick --events --all-databases --flush-logs --delete-master-logs --single-transaction > ${mulu}/whole-${dumpdate}.sql
sleep 5
```
参数：

--quick，-q

该选项在导出大表时很有用，它强制 MySQLdump 从服务器查询取得记录直接输出而不是取得所有记录后将它们缓存到内存中。

--events, -E

导出事件

--all-databases , -A

导出全部数据库。

--flush-logs

开始导出之前刷新日志，这一项必须带上。

请注意：假如一次导出多个数据库 (使用选项—databases 或者—all-databases)，将会逐个数据库刷新日志。除使用—lock-all-tables 或者—master-data 外。在这种情况下，日志将会被刷新一次，相应的所以表同时被锁定。因此，如果打算同时导出和刷新日志应该使用—lock-all-tables 或者—master-data 和—flush-logs。

--delete-master-logs

master 备份后删除日志. 这个参数将自动激活—master-data。

--single-transaction

该选项在导出数据之前提交一个 BEGIN SQL 语句，BEGIN 不会阻塞任何应用程序且能保证导出时数据库的一致性状态。它只适用于多版本存储引擎，仅 InnoDB。本选项和—lock-tables 选项是互斥的，因 LOCK TABLES 会使任何挂起的事务隐含提交。要想导出大表的话，应结合使用—quick 选项。

image

## 3，接着是增量备份的脚本。
```
#!/bin/bash
export LANG=en_US.UTF-8
filedate=$(date +%y%m%d)
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
            echo $base copying >> $LogFile
        fi
    fi
done
echo `date +"%Y年%m月%d日 %H:%M:%S"` Bakup succ! >> $LogFile
sleep 5
```
针对 binlog 的增量备份。

## 4，通过定时执行两个脚本来实现备份策略。
| 方式	| 定时任务	| 备注 |
| ---- | ---- | ---- |
| 全量备份	| 0 3 1 * * /bin/bash /opt/mysql_sh/whole_backup.sh |	每月一日凌晨3点全量备份 |
| 全量备份滚动删除 | 0 4 1 * * /bin/bash /opt/mysql_sh/whole_clean.sh | 每月一日凌晨4点清理最老数据 |
| 增量备份	| 0 3 1-6 /bin/bash /opt/mysql_sh/incremental_backup.sh	| 每周一到周六凌晨三点增量备份 |
 
这样就实现了数据库的增量备份。其中全量备份则使用 mysqldump 将所有的数据库导出，每周日凌晨三点执行，并会删除上周留下的 binlog（mysql-bin.00000*）。增量备份会在每周一到周六的凌晨三点执行，执行的动作是将一周生成的 binlog 复制到指定的目录。

# 3，恢复。
关于灾备恢复。

一旦出现问题，恢复的顺序应该是先恢复最近一次的全量备份，让数据库追溯到最近一次的完整状态。 然后按顺序将增量备份一个一个恢复起来。（注意：这个地方要注意的是，由于脚本当中没有对旧备份的 binlog 进行处理，所以当需要恢复增量备份的时候，要结合全量备份的日期，与 binlog 备份中的日期，恢复的时候只用从全量备份那一天之后的 binlog 进行恢复即可！）

具体恢复命令如下：

## 1， 恢复安全备份。
mysql -uroot -p123456  < all104528.sql
## 2， 恢复增量备份。
mysqlbinlog master-bin.000007 | mysql -uroot -p123456
mysqlbinlog master-bin.000008 | mysql -uroot -p123456
mysqlbinlog master-bin.000009 | mysql -uroot -p123456
注：当执行恢复操作的时候，由于数据量较大，可以暂时关闭 binlog 的记录。

# 4，优化。
突然想，为何不优化一下呢？

说干就干。

优化思路就是把旧的 binlog 保存在 oldbinlog 目录当中。

全量备份：
```
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
```
注意要创建这个目录。
oldbinlog=/opt/mysql_bak/sqlbackup/oldbinlog
allbinlog=/opt/mysql_bak/sqlbackup/allbinlog 

增量备份：
```
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
```

这样，当服务出问题的时候，直接根据 all 目录下的全量备份进行恢复，然后根据 add 目录下的增量备份进行恢复即可。
