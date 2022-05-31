## 场景
此场景是应用在openstack通过接口拉起虚机后自动启动监控agent（node_exporter）+ 此程序自动注册到consul以供promehtues监控
## 具体实现
openstack vm镜像需要提前安装好node_exporter并加入开机自启，此程序也是如此，通过平台调用openstack接口拉起vm的时候，prometheus端就可以直接监控到对应vm
## 所用到的库
