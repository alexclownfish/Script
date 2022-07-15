#!/bin/bash
echo "=====验证升级前openssl版本：====="
openssl version
sleep 2
#备份老的openssl:
mv /usr/bin/openssl /usr/bin/openssl.old
cd /usr/local/src
echo "=====下载openssl-1.1.1h.tar.gz并解压====="
wget --no-check-certificate https://www.openssl.org/source/openssl-1.1.1h.tar.gz
tar -xf openssl-1.1.1h.tar.gz && cd openssl-1.1.1h
echo "=====编译安装openssl-1.1.1h====="
./config --prefix=/opt/openssl --openssldir=/usr/local/ssl &> /dev/null
if [ $? -eq 0 ]; then
  echo "======预编译完成======"
else
  echo "======预编译失败======"
  exit 1
fi
make &> /dev/null
if [ $? -eq 0 ]; then
  echo "======编译完成======"
else
  echo "======编译失败======"
  exit 1
fi
make install &> /dev/null
if [ $? -eq 0 ]; then
  echo "======编译安装完成======"
else
  echo "======编译安装失败======"
  exit 1
fi

#替换原有旧openssl文件：
ln -sf /opt/openssl/bin/openssl /usr/bin/openssl
ln -sf /opt/openssl/include/openssl/ /usr/include/
#替换以下库文件：
ln -sf /opt/openssl/lib/libcrypto.so.1.1 /usr/lib64/libcrypto.so.1.1
ln -sf /opt/openssl/lib/libssl.so.1.1 /usr/lib64/libssl.so.1.1
sleep 1
echo "验证升级后openssl版本："
openssl version

