#!/bin/bash
#镜像版本变量
version=$1
#编译项目代码
mvn clean package -Dmaven.test.skip=true
#解压项目代码至新文件夹
unzip target/*.war -d target/ROOT
#编写Dockerfile
cat > Dockerfile <<EOF
FROM lizhenliang/tomcat   
LABEL maintainer alex
RUN rm -rf /usr/local/tomcat/webapps/*
COPY target/ROOT /usr/local/tomcat/webapps/ROOT 
EOF
#build镜像并推送
docker build -t 106.12.37.109/library/tomcat-java-demo:$version .
docker push 106.12.37.109/library/tomcat-java-demo:$version
