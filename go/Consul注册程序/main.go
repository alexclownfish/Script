package main

import (
	"fmt"
	"net"
	//"os"
	"strconv"
	"time"

	"github.com/fsnotify/fsnotify"
	"github.com/spf13/viper"

	"github.com/hashicorp/consul/api"
	"github.com/wonderivan/logger"
)

// 获取本机网卡IP
func getLocalIP() (ipv4 string, err error) {
	// 获取所有网卡
	addrs, err := net.InterfaceAddrs()
	if err != nil {
		return
	}
	// 取第一个非lo的网卡IP
	for _, addr := range addrs {
		// 这个网络地址是IP地址: ipv4, ipv6
		ipNet, isIpNet := addr.(*net.IPNet)
		if isIpNet && !ipNet.IP.IsLoopback() {
			// 跳过IPV6
			if ipNet.IP.To4() != nil {
				ipv4 = ipNet.IP.String() // 192.168.1.1
				return
			}
		}
	}

	return
}

func consulRegister() (err error) {
	//获取localip localhostname
	Local_IP, _ := getLocalIP()
	//hostname, err := os.Hostname()
	if err != nil {
		logger.Error("获取hostname失败，" + err.Error())
		return
	}
	// 创建连接consul服务配置
	config := api.DefaultConfig()
	config.Address = viper.GetString("consulAddress")
	client, err := api.NewClient(config)
	if err != nil {
		fmt.Println("consul client error : ", err)
	}
	// 创建注册到consul的服务到
	registration := new(api.AgentServiceRegistration)
	registration.ID = viper.GetString("registrationID")
	registration.Name = viper.GetString("registrationName")
	registration.Port = viper.GetInt("local_port")
	registration.Tags = viper.GetStringSlice("registrationTags")
	registration.Address = Local_IP
	//判断服务是否注册成功
	//增加consul健康检查回调函数
	check := new(api.AgentServiceCheck)
	check.HTTP = fmt.Sprintf("http://%s:%d", registration.Address, registration.Port)
	check.Timeout = "5s"
	check.Interval = "5s"
	check.DeregisterCriticalServiceAfter = "30s" // 故障检查失败30s后 consul⾃动将注册服务删除
	registration.Check = check
	//注册服务到consul
	err = client.Agent().ServiceRegister(registration)
	if err != nil {
		logger.Error("注册到consul失败")
		return
	}
	Service_IP, _ := getLocalIP()
	logger.Info("registration.ID：" + registration.ID)
	logger.Info("registration.Name：" + registration.Name)
	logger.Info("registration.Port：" + strconv.Itoa(registration.Port))
	logger.Info("registration.Tags：", registration.Tags)
	logger.Info("registration.Address：" + registration.Address)
	logger.Info(Service_IP + ":" + strconv.Itoa(9100) + "已完成注册")
	return nil
}

//func Handler(w http.ResponseWriter, r *http.Request) {
//	w.Write([]byte("you are visiting health check api"))
//}
func main() {
	viper.SetConfigName("config")
	viper.SetConfigType("yaml")
	viper.AddConfigPath("./config/")
	err := viper.ReadInConfig()
	if err != nil {
		panic(fmt.Errorf("Fatal error config file: %s \n", err))
	}
	viper.WatchConfig()
	viper.OnConfigChange(func(e fsnotify.Event) {
		// 配置文件发生变更之后会调用的回调函数
		fmt.Println(time.Now(), "Config file changed:", e.Name)
	})
	consulRegister()

	//logger.Info("Server Run in " + "http://" + fmt.Sprintf(viper.GetString("web_url")+fmt.Sprintf(viper.GetString("web_prefix"))))
	//
	//http.HandleFunc(viper.GetString("web_prefix"), Handler)
	//err = http.ListenAndServe(viper.GetString("web_url"), nil)
	//if err != nil {
	//	fmt.Println("error: ", err.Error())
	//}
}
