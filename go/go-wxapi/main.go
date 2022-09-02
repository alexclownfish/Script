package main

import (
	"github.com/robfig/cron"
	"go-wxapi/util/tools"
	"go-wxapi/weather"
	"log"
	"time"
)

func main() {
	tools.ViperConfigFile()
	times := time.Now().Format("2006-01-02 15:04:05")
	log.Printf("启动时间: %v", times)
	spec := "0/1 * * * * *" // 每天早上七点
	c := cron.New()
	c.AddFunc(spec, weather.Weather)
	c.Start()
	log.Println("定时任务已开启....")
	select {}
}
