#!/bin/bash
echo "ip存活扫描脚本，不活跃的ip被输入在本目录ip_down.txt文件下"
sleep 1
echo "      author by alex"

echo "      site:https://alexcld.com"
sleep 1
echo "      Getting local network card, IP segment"
sleep 1
#获取网段：example 192.168.10
ens33=`ip a | grep ens33 | grep inet | awk '{print $2}' | cut -d . -f 1,2,3`
eth0=`ip a | grep eth0 | grep inet | awk '{print $2}' | cut -d . -f 1,2,3`
#系统不同 网卡信息不同，获取网卡信息，以此判断执行
wk_ens33=`ip a | grep ens33 | grep ens33: | awk '{print $2}' | cut -d : -f 1`
wk_eth0=`ip a | grep eth0 | grep eth0: | awk '{print $2}' | cut -d : -f 1`
#主体
if [ "$wk_eth0" == "eth0" ]
then
    echo "      Your network card is $wk_eth0"
    echo "      Network segment is $eth0."
    sleep 2
        {
        for i in $eth0.{1..254}
        do
            {
            ping -c 2 -w 2 $i &>/dev/null
            if [ $? -eq 0 ]
            then
                echo $i is active! >> ./ip_active.txt
            else
                echo $i is down! >> ./ip_down.txt
            fi
            break
        }&
        done
        }
elif [ "$wk_ens33" == "ens33" ]
then
    echo "      Your network card is $wk_ens33"
    echo "      Network segment is $ens33."
    sleep 2
        {
        for i in $ens33.{1..254}
        do
            {
            ping -c 2 -w 2 $i &>/dev/null
            if [ $? -eq 0 ]
            then
                echo $i is active! >> ./ip_active.txt
            else
                echo $i is down! >> ./ip_down.txt
            fi
            break
        }&
        done
        }
else
    echo "Your network card is neither eth0 nor ens33. Please check your network card information"
fi
echo "IP扫描完成   存活ip：./ip_active.txt || 死亡ip：./ip_down.txt"
