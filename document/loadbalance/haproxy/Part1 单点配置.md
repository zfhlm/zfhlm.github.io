
# haproxy 单点配置

#### 下载安装包

	访问地址 https://www.haproxy.org/#down，找到Latest LTS version
	
	下载安装包：haproxy-2.4.7.tar.gz
	
	上传到服务器目录： /usr/local/software
	
	服务器IP地址：192.168.140.149

### 解压编译

	输入命令：
		
		yum install -y gcc-c++
		
		cd /usr/local/software
		
		tar -zxvf ./haproxy-2.4.7.tar.gz
		
		cd ./haproxy-2.4.7
		
		make TARGET=generic PREFIX=/usr/local/haproxy
		
		make install PREFIX=/usr/local/haproxy
		
		cd /usr/local/software
		
		rm -rf ./haproxy-2.4.7
	
### 配置监控页面并启动

	输入命令：
	
		cd /usr/local/haproxy
		
		mkdir conf
		
		cd ./conf
		
		vi ./conf/haproxy.cfg
		
		=>
			
			#全局配置
			global
			#日志配置
			log 127.0.0.1 local0 info
			#最大连接数
			maxconn 1024
			#开启为后台进程  
			daemon
			#设置进程数量
			nbproc 1
			#设置pid文件位置
			pidfile /usr/local/haproxy/conf/haproxy.pid
			
			#默认配置
			defaults
			log global
			maxconn 1024
			timeout connect 5000
			timeout client 30000
			timeout server 30000
			
			#开启监听
			listen stats
			#使用http模式
			mode http
			#绑定端口
			bind *:8080
			#启用状态
			stats enable
			#隐藏版本号
			stats hide-version
			#访问uri
			stats uri /stats
			#任务账号和密码
			stats auth admin:admin
			#开启管理功能
			stats admin if TRUE
			#统计自动刷新间隔时间
			stats  refresh  30s
		
		/usr/local/haproxy/sbin/haproxy -f /usr/local/haproxy/conf/haproxy.cfg
		
		ps -ef | grep haproxy
	
### 访问监控页面
	
	浏览器访问地址：http://192.168.140.149:8080/stats
	
	输入账号admin，密码admin，进入监控页面


