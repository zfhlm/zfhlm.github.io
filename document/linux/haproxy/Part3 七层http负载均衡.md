
# haproxy 七层 http 负载均衡

### 环境准备
	
	192.168.140.149		#haproxy节点一，负载均衡代理端口80
	
	192.168.140.150		#haproxy节点二，负载均衡代理端口80
	
	192.168.140.149		#tomcat应用节点一，服务端口8888
	
	192.168.140.150		#tomcat应用节点二，服务端口8888
	
### 两台服务器配置tomcat应用
	
	安装jdk1.8并配置好环境变量
	
	tomcat安装包下载地址：https://tomcat.apache.org/download-10.cgi
	
	下载安装包：apache-tomcat-10.0.12.tar.gz
	
	上传到服务器目录：/usr/local/software
	
	解压配置tomcat，输入命令：
	
		cd /usr/local/software
		
		tar -zxvf ./apache-tomcat-10.0.12.tar.gz
		
		cd ./apache-tomcat-10.0.12/webapps
		
		rm -rf ./*
		
		mkdir ROOT
		
		ifconfig ens33 | grep "inet " | awk '{ print $2}' > ./ROOT/index.html
	
	更改运行端口，修改http端口为8888，输入命令：
	
		cd /usr/local/software/apache-tomcat-10.0.12
		
		vi ./conf/server.xml
	
	启动应用，输入命令：
	
		cd /usr/local/software/
		
		mv ./apache-tomcat-10.0.12 ../
		
		cd /usr/local/apache-tomcat-10.0.12/
		
		./bin/startup.sh
			
### 服务器配置haproxy
		
	编辑配置文件，输入命令：
		
		cd /usr/local/haproxy
		
		vi ./conf/haproxy.cfg
	
		=>
		
			listen websites
			bind *:80
			mode http
			log global
			maxconn 1024
			balance roundrobin
			server tomcat149 192.168.140.149:8888 check inter 2000 fall 5
			server tomcat150 192.168.140.150:8888 check inter 2000 fall 5
		
### 重启haproxy
	
		pkill haproxy
		
		/usr/local/haproxy/sbin/haproxy -f /usr/local/haproxy/conf/haproxy.cfg
		
### 访问测试
	
	浏览器输入以下地址：
	
		http://192.168.140.149/
		
		http://192.168.140.150/
	
	不停刷新地址，会轮询访问到两个tomcat


