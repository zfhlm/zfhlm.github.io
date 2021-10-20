
#### tcpdump

	1，yum 安装 tcpdump，输入命令：
	
		yum -y install  tcpdump
	
	2，抓包80端口，输入命令：
	
		tcpdump tcp port 80 -nn
		
		tcpdump tcp port 80 -nn -i ens33

