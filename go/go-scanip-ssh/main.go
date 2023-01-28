package main

import (
	"fmt"
	"golang.org/x/crypto/ssh"
	"net"
	"os/exec"
	"strings"
	"time"
)

func main() {
	GetIp := GetLocalIp()
	parts := strings.Split(GetIp, ".")
	prefixIP := fmt.Sprintf(strings.Join(parts[:3], "."))
	ParseCIDR := prefixIP + ".0/24"
	ip, ipnet, _ := net.ParseCIDR(ParseCIDR)
	var sip []string
	for ip := ip.Mask(ipnet.Mask); ipnet.Contains(ip); inc(ip) {
		if checkIPAlive(ip) {
			//fmt.Println(ip, "is alive")
			//host := fmt.Sprintf("%s", ip)
			sip = append(sip, ip.String())
		}
	}
	config := &ssh.ClientConfig{
		User: "root",
		Auth: []ssh.AuthMethod{
			ssh.Password("Sttri189!"),
		},
		Timeout: 30 * time.Second,
		HostKeyCallback: func(hostname string, remote net.Addr, key ssh.PublicKey) error {
			return nil
		},
	}

	fmt.Printf("数据内容：%s\n,数据大小：%d\n", sip, len(sip))

	for _, v := range sip {

		client, err := ssh.Dial("tcp", v+":22", config)
		if err != nil {
			fmt.Println("Failed to dial:", err)
			continue
		}
		defer client.Close()

		session, err := client.NewSession()
		if err != nil {
			fmt.Println("Failed to create session:", err)
			continue
		}
		defer session.Close()

		output, err := session.CombinedOutput("cat /etc/hostname")
		if err != nil {
			fmt.Println("Failed to run command: ", err)
			return
		}
		fmt.Println("主机名：" + string(output) + "IP:" + v)
	}
}

func checkIPAlive(ip net.IP) bool {
	// ping the IP address
	output, err := exec.Command("ping", "-c 1", "-W 1", ip.String()).Output()
	if err != nil {
		return false
	}
	// check if the output contains "1 packets transmitted, 1 received"
	if strings.Contains(string(output), "1 packets transmitted, 1 received") {
		return true
	}
	return false
}

func inc(ip net.IP) {
	for j := len(ip) - 1; j >= 0; j-- {
		ip[j]++
		if ip[j] > 0 {
			break
		}
	}
}

func GetLocalIp() (localip string) {
	interfaces, _ := net.Interfaces()
	for _, i := range interfaces {
		if i.Name == "eth0" {
			addrs, _ := i.Addrs()
			for _, addr := range addrs {
				var ip net.IP
				switch v := addr.(type) {
				case *net.IPNet:
					ip = v.IP
				case *net.IPAddr:
					ip = v.IP
				}
				if ip.To4() != nil {
					localip = fmt.Sprintf("%s", ip)
				}
			}
		}
	}
	return localip
}
