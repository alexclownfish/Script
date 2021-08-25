#!/bin/bash
URL=http://106.12.189.57/root/java-demo.git #gitlab地址
Starttime=`date +"%Y-%m-%d_%H-%M-%S"`
Method=$1
Branch=$2
t1=`date +"%Y-%m-%d %H:%M:%S"`

     #代码克隆至jenkins后端
clone_code(){
    cd /root/.jenkins/workspace/jenkins_project && git clone -b $Branch ${URL}&& echo "Clone Finished"
}

 #代码打包压缩并远程推送至k8s-master-1的nginx镜像制作目录
Pack_scp(){
    cd /root/.jenkins/workspace/jenkins_project/java-demo/ && tar cvzf java-demo.tar.gz * && echo Package Finished
    cp java-demo.tar.gz /data/Dockerfile/java-demo/ && cd /data/Dockerfile/java-demo/ && tar xvf java-demo.tar.gz && rm -f java-demo.tar.gz
}

 #远程操作k8s-master-1节点，进行镜像制作并推送至harbor镜像仓库
build_iamge(){
    cd /data/Dockerfile/java-demo/ && ./build.sh ${BUILD_NUMBER} && echo 'build_image and push_harbor success!'
}

    #对k8s集群中的nginx的pod应用进行升级
app_update(){
    sed -ri 's@image: .*@image: 106.12.37.109/library/tomcat-java-demo:${BUILD_NUMBER}@g'  /data/mainfest/deployment.yaml
    kubectl set image deployment/java-demo java-demo=106.12.37.109/library/tomcat-java-demo:${BUILD_NUMBER} -n default --record=true
                t2=`date +"%Y-%m-%d %H:%M:%S"`
    start_T=`date --date="${t1}" +%s`
    end_T=`date --date="${t2}" +%s`
    total_time=$((end_T-start_T))
    echo "deploy success,it has been spent ${total_time} seconds"   
}

    #k8s集群中的pod应用进行回滚
app_rollback(){
     kubectl rollout undo deployment/java-demo  -n default
}

    #进行k8s集群自动部署的主函数
main(){
    case $Method in 
    deploy)
        clone_code
        Pack_scp
        build_iamge
        app_update
    ;;
    rollback)
        app_rollback
    ;;
    esac
}

#执行主函数命令
main $1 $2
