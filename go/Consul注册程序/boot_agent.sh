#!/bin/bash

while :
    do
        # 访问exporter，获取http状态码
        exporter=`curl -I -m 10 -o /dev/null -s -w %{http_code}  http://127.0.0.1:9100/metrics`
        # 判断状态码为200
        if [[ $exporter -eq 200 ]]; then
            # 输出绿色文字，并跳出循环
            echo -e "\033[42;34m node-exporter is ok \033[0m" >> ./boot_agent.log
            break
        else
            # 暂停1秒
            sleep 1
            echo -e "\033[41;37m node-exporter is not ok,正在尝试重启…… \033[0m" >> ./boot_agent.log
            systemctl restart node_exporter
        fi
    done

# while结束时，也就是node-exporter启动完成后，执行容器中的run.sh。
cd /opt/consul_reg
./consulreg >> ./consulreg.log

