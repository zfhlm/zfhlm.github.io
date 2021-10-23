
# postfix

	Postfix 电子邮件服务器，可用于发送服务器端故障告警
	
	注意，必须要配置自己的域名，否则邮件服务器域名反向解析不成功，会无法发送邮件

#### 安装postfix

	使用 yum 安装，输入命令：
		
		rpm -qa | grep postfix
		
		yum install -y postfix
		
		yum install -y mailx
	
	修改配置文件，输入命令：
		
		cp /etc/postfix/main.cf /etc/postfix/main.cf.bak
		
		vi /etc/postfix/main.cf
		
	修改以下配置：
		
		myhostname = mrh.com
		
		mydomain = zfhlm.mrh.com
		
		myorigin = $mydomain
		
		inet_interfaces = all
		
		mydestination = $myhostname, localhost.$mydomain, localhost, $mydomain
	
	重启 postfox 服务，输入命令：
	
		systemctl restart postfox
		
	发送邮件，输入命令：
	
		echo "Warning, server error ...." | mail -s "Server error" 914589210@qq.com



