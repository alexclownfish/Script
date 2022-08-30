package main

import (
	"encoding/json"
	"fmt"
	"github.com/robfig/cron"
	"github.com/tidwall/gjson"
	"io/ioutil"
	"log"
	"net/http"
	"strings"
	"time"
)

var (
	APPID          = "wxec760af73489c070"
	APPSECRET      = "08109283b680436fb9af185a677fb28c"
	UserAppID      = "18518286"
	UserAppSecret  = "Em8MNKmw"
	WeatTemplateID = "QpPIrx2LCPB0oxSnseYvf7mx-TSeibhjcgL65QmdtLg" //天气模板ID，替换成自己的
	WeatherVersion = "v1"
)

type token struct {
	AccessToken string `json:"access_token"`
	ExpiresIn   int    `json:"expires_in"`
}

//获取微信accesstoken
func GetAccessToken() string {
	url := fmt.Sprintf("https://api.weixin.qq.com/cgi-bin/token?grant_type=client_credential&appid=%v&secret=%v", APPID, APPSECRET)
	resp, err := http.Get(url)
	if err != nil {
		log.Printf("获取微信token失败：%s\n", err)
		return ""
	}
	defer resp.Body.Close()
	body, err := ioutil.ReadAll(resp.Body)
	if err != nil {
		log.Printf("获取微信token失败：%s\n", err)
		return ""
	}

	token := token{}
	err = json.Unmarshal(body, &token)
	if err != nil {
		log.Printf("微信token解析json失败：%s\n", err)
		return ""
	}

	return token.AccessToken
}

func GetWeather(city string) (string, string, string, string, string, error) {
	url := fmt.Sprintf("https://www.tianqiapi.com/api?version=%s&city=%s&appid=%v&appsecret=%v", WeatherVersion, city, UserAppID, UserAppSecret)
	resp, err := http.Get(url)
	if err != nil {
		log.Printf("读取内容失败：%s\n", err)
		return "", "", "", "", "", err
	}
	defer resp.Body.Close()
	body, err := ioutil.ReadAll(resp.Body)
	if err != nil {
		log.Printf("读取内容失败：%s\n", err)
		return "", "", "", "", "", err
	}
	data := gjson.Get(string(body), "data").Array()
	thisday := data[0].String()
	day := gjson.Get(thisday, "day").Str           //日期
	wea := gjson.Get(thisday, "wea").Str           //天气
	tem := gjson.Get(thisday, "tem").Str           //平均气温
	air_tips := gjson.Get(thisday, "air_tips").Str //提示
	index := gjson.Get(thisday, "index").Array()
	iop := index[4].String()
	clothing_indicator := gjson.Get(iop, "desc").Str
	return day, wea, tem, air_tips, clothing_indicator, err
}

//获取关注者列表
func GetFollowersList(access_token string) []gjson.Result {
	url := "https://api.weixin.qq.com/cgi-bin/user/get?access_token=" + access_token + "&next_openid="
	resp, err := http.Get(url)
	if err != nil {
		log.Printf("获取关注列表失败：%s\n", err)
		return nil
	}
	defer resp.Body.Close()
	body, err := ioutil.ReadAll(resp.Body)
	if err != nil {
		log.Printf("读取内容失败：%s\n", err)
		return nil
	}
	flist := gjson.Get(string(body), "data.openid").Array()
	return flist
}

//发送模板消息
func templatepost(access_token string, reqdata string, fxurl string, templateid string, openid string) {
	url := "https://api.weixin.qq.com/cgi-bin/message/template/send?access_token=" + access_token

	reqbody := "{\"touser\":\"" + openid + "\", \"template_id\":\"" + templateid + "\", \"url\":\"" + fxurl + "\", \"data\": " + reqdata + "}"

	resp, err := http.Post(url,
		"application/x-www-form-urlencoded",
		strings.NewReader(string(reqbody)))
	if err != nil {
		log.Println(err)
		return
	}

	defer resp.Body.Close()
	body, err := ioutil.ReadAll(resp.Body)
	if err != nil {
		log.Println(err)
		return
	}

	log.Println(string(body))
}

//发送天气
func SendWeather(access_token, city, openid string) {
	day, wea, tem, air_tips, clothing_indicator, err := GetWeather(city)
	if err != nil {
		log.Printf("Get Weather failed：%s\n", err)
	}
	log.Println(day, wea, tem, air_tips)
	if day == "" || wea == "" || tem == "" || air_tips == "" || clothing_indicator == "" {
		log.Printf("获取天气信息失败\n")
		return
	}
	reqdata := "{\"city\":{\"value\":\"城市：" + city + "\", \"color\":\"#0000CD\"}, \"day\":{\"value\":\"" + day + "\"}, \"wea\":{\"value\":\"天气：" + wea + "\"}, \"tem1\":{\"value\":\"平均温度：" + tem + "\"},\"clothing_indicator1\":{\"value\":\"穿衣指数：" + clothing_indicator + "\"}, \"air_tips\":{\"value\":\"tips：" + air_tips + "\"}}"
	templatepost(access_token, reqdata, "https://blogtest.alexcld.com", WeatTemplateID, openid)
}

//发送天气预报
func Weather() {
	access_token := GetAccessToken()
	if access_token == "" {
		return
	}

	flist := GetFollowersList(access_token)
	if flist == nil {
		return
	}
	log.Println(flist)
	var city string
	for _, v := range flist {
		switch v.Str {
		case "oJkd76HgkEPS2jJGNJe6SiSmJRHI":
			city = "上海"
			go SendWeather(access_token, city, v.Str)
			log.Printf("发送%s天气给%s成功\n", city, v.Str)
		case "oJkd76LcSm7171NY6b50JyFw8IDQ":
			city = "伊川"
			go SendWeather(access_token, city, v.Str)
			log.Printf("发送%s天气给%s成功\n", city, v.Str)
		case "oJkd76EhSzXGZfrme2xJTwuZbt0c":
			city = "上海"
			go SendWeather(access_token, city, v.Str)
			log.Printf("发送%s天气给%s成功\n", city, v.Str)
		case "oJkd76HVlNQfE2lMHXDikWh38kqQ":
			city = "洛阳"
			go SendWeather(access_token, city, v.Str)
			log.Printf("发送%s天气给%s成功\n", city, v.Str)
		default:
			log.Println("err")
		}
	}
	log.Println("Weather is send")
}

func main() {
	times := time.Now().Format("2006-01-02 15:04:05")
	log.Printf("当前时间: %v", times)
	spec := "0 0 7 * * *" // 每天早上七点
	c := cron.New()
	c.AddFunc(spec, Weather)
	c.Start()
	log.Println("定时任务已开启....")
	select {}
	//Weather()
}
