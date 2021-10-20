
#### 防火墙常用命令

	启动防火墙： systemctl start firewalld
	
	查看防火墙状态： systemctl status firewalld 
	
	停止防火墙： systemctl stop firewalld
	
	永久停止防火墙： systemctl disable firewalld
	
	查看防火墙版本： firewall-cmd --version
	
	查看防火墙帮助： firewall-cmd --help
	
	显示防火墙状态： firewall-cmd --state

	添加防火墙白名单端口：firewall-cmd --zone=public --add-port=80/tcp --permanent
	
	重新载入防火墙配置：firewall-cmd --reload
	
	查看防火墙白名单：firewall-cmd --zone= public --query-port=80/tcp
	
	删除防火墙白名单：firewall-cmd --zone= public --remove-port=80/tcp --permanent
