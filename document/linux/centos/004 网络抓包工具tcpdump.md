
#### 安装配置

	使用yum安装，输入命令：
	
		yum -y install  tcpdump
	
	抓包命令：
	
		tcpdump tcp port 80 -nn
	
	如果有多个网卡，需要指定网卡，输入命令：
	
		tcpdump tcp port 80 -nn -i ens33

