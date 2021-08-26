/*
Author：yangwenzhe
Email：wenzheyang58@gmail.com
Site：https://blog.alexcld.com https://vue.alexcld.com
date：2021/8/26
*/

package main

import (
	"fmt"
	"os"
	"os/exec"
	"time"
)

func init() {

	fmt.Println("------BMI指数计算器------")
	fmt.Println("-------------------------")
	fmt.Println("偏瘦	<= 18.4")
	fmt.Println("正常	18.5 ~ 23.9")
	fmt.Println("过重	24.0 ~ 27.9")
	fmt.Println("肥胖	>= 28.0")
	fmt.Println("-------------------------")

	var sg float32
	var name string
	var tz float32
	var bmi float32
	if true {
		fmt.Println("Please enter the following options：")
		time.Sleep(time.Duration(1) * time.Second)
		fmt.Printf("name：")
		fmt.Scan(&name)
		fmt.Printf("身高(m)：")
		fmt.Scan(&sg)
		fmt.Printf("体重(kg)：")
		fmt.Scan(&tz)
		ma := map[string]float32{"sgs": sg, "tzs": tz}
		if true {
			bmi = tz / (sg * sg)
			fmt.Println("经计算bmi指数为：", bmi)
			if bmi <= 18.4 {
				fmt.Println("经bmi指数对比你过瘦\n", "姓名：", name, "身高：", ma["sgs"], "体重：", ma["tzs"], "bmi指数：", bmi)
			} else if bmi <= 23.9 && bmi >= 18.5 {
				fmt.Println("经bmi指数对比你正常\n", "姓名：", name, "身高：", ma["sgs"], "体重：", ma["tzs"], "bmi指数：", bmi)
			} else if bmi <= 27.9 && bmi >= 24.0 {
				fmt.Println("经bmi指数对比你过重\n", "姓名：", name, "身高：", ma["sgs"], "体重：", ma["tzs"], "bmi指数：", bmi)
			} else if bmi >= 28.0 {
				fmt.Println("经bmi指数对比你过于肥胖\n", "姓名：", name, "身高：", ma["sgs"], "体重：", ma["tzs"], "bmi指数：", bmi)
			} else {
				fmt.Println("请正确输入参数：")
			}
		}
	}
	time.Sleep(time.Duration(2) * time.Second)
	fmt.Println("---3s后进入下一个网站选择---")
}

func main() {
	var press int
	sites := map[int]string{1: "https://blog.alexcld.com", 2: "https://vue.alexcld.com"}

	fmt.Println("------------author's sites------------")
	fmt.Println("--------1：由Hexo驱动托管github---------")
	fmt.Println("----2：由Vue驱动托管阿里云轻量级服务器----")
	if true {
		fmt.Printf("输入1 or 2，将打开1，2网站：")
		fmt.Scan(&press)
		if press == 1 {
			exec.Command(`cmd`, `/c`, `start`, sites[1]).Start()
		} else if press == 2 {
			exec.Command(`cmd`, `/c`, `start`, sites[2]).Start()
		} else {
			fmt.Print("---输入错误程序退出---")
			os.Exit(1)
		}
	}
	fmt.Println("---程序将在3s后退出---")
	time.Sleep(time.Duration(3) * time.Second)
	os.Exit(1)
}
