package tools

import (
	"fmt"
	"github.com/fsnotify/fsnotify"
	"github.com/spf13/viper"
)

func ViperConfigFile() {
	viper.AddConfigPath("./config/")
	viper.SetConfigName("config")
	viper.SetConfigType("yaml")
	err := viper.ReadInConfig() // 读取配置信息
	if err != nil {             // 读取配置信息失败
		panic(fmt.Errorf("Fatal error config.yaml file: %s \n", err))
	}
	// 第二：实时监控配置文件的变化
	viper.WatchConfig()
	viper.OnConfigChange(func(e fsnotify.Event) {
		// 配置文件发生变更之后会调用的回调函数
		fmt.Println("Config file changed:", e.Name)
	})
}
