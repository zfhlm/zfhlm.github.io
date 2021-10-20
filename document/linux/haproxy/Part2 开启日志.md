
# haproxy 开启日志

	haproxy日志记录，需要配合rsyslog日志服务使用

### 创建日志目录

	输入命令：
	
		mkdir /var/log/haproxy
		
		chmod a+x /var/log/haproxy
	
### 开启 rsyslog 记录 haproxy 日志功能

	开启UDP监听，并指定日志存放位置
	
	输入命令：
	
		vim /etc/rsyslog.conf
	
		=>
			
			# Provides UDP syslog reception
			$ModLoad imudp
			$UDPServerRun 514
			
			# Save haproxy log
			local0.* /var/log/haproxy/haproxy.log
	
### 配置日志处理参数
	
	输入命令：
	
		vim /etc/sysconfig/rsyslog
		
		=> 
		
			# Options for rsyslogd
			# Syslogd options are deprecated since rsyslog v3.
			# If you want to use them, switch to compatibility mode 2 by "-c 2"
			# See rsyslogd(8) for more details
			SYSLOGD_OPTIONS="-r -m 0 -c 2"
	
### 添加haproxy日志配置
	
	输入命令：
	
		cd /usr/local/haproxy
		
		vi ./conf/haproxy.cfg
		
		=> 在global下面添加以下配置(日志级别：emerg alert crit err warning notice info debug )：
		
			log 127.0.0.1 local0 info
	
### 重启日志服务和haproxy服务
		
	pkill haproxy
	
	/usr/local/haproxy/sbin/haproxy -f /usr/local/haproxy/conf/haproxy.cfg
	
	systemctl restart rsyslog
		
### 查看输出日志
	
	输入命令： 
	
		tail -f /var/log/haproxy/haproxy.log


