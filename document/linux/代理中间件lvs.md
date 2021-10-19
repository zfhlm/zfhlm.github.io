
#### 安装准备

	1，下载安装包
		
		下载地址：http://www.linuxvirtualserver.org/
		
		找到 ipvsadm-1.26 release地址，下载安装包：ipvsadm-1.26.tar.gz
		
		上传到服务器目录：/usr/local/software
		
		注意：编译之前需要先确认linux服务器内核版本，阅读官方文档下载合适的版本

#### 编译安装

	1，初始化编译环境
	
		输入命令：
	
			yum install -y gcc-c++
			
			yum install -y libnl*
			
			yum install -y popt*
	
	2，编译安装ipvsadm
		
		输入命令：
		
			cd /usr/local/software
			
			tar -zxvf ./ipvsadm-1.26.tar.gz
			
			cd ./ipvsadm-1.26
			
			make && make install
		
	3，验证安装
	
		输入命令：
		
			ipvsadm
			
		安装成功提示信息：
		
			IP Virtual Server version 1.2.1 (size=4096)
			Prot LocalAddress:Port Scheduler Flags
			  -> RemoteAddress:Port           Forward Weight ActiveConn InActConn
	
	4，常用命令参数：
		
		-A --add-service			在内核的虚拟服务器表中添加一条新的虚拟服务器记录
		
		-E --edit-service			编辑内核虚拟服务器表中的一条虚拟服务器记录
		
		-D --delete-service			删除内核虚拟服务器表中的一条虚拟服务器记录
		
		-C --clear				清除内核虚拟服务器表中的所有记录
		
		-R --restore				恢复虚拟服务器规则
		
		-S --save				保存虚拟服务器规则，输出为-R 选项可读的格式
		
		-a --add-server				在内核虚拟服务器表的一条记录里添加一条新的真实服务器记录
		
		-e --edit-server			编辑一条虚拟服务器记录中的某条真实服务器记录
		
		-d --delete-server			删除一条虚拟服务器记录中的某条真实服务器记录
		
		-L|-l --list				显示内核虚拟服务器表
		
		-t --tcp-service service-address	说明虚拟服务器提供的是tcp
		
		-u --udp-service service-address	说明虚拟服务器提供的是udp
		
		-s --scheduler scheduler		使用的调度算法，有这样几个选项rr|wrr|lc|wlc|lblc|lblcr|dh|sh|sed|nq，默认使用wlc

#### NAT模式

	1，环境说明
	
		192.168.140.1			#客户端
		
		10.1.125.200			#VIP地址
		
		10.1.125.151			#centos7 LVS服务器(安装ipvsadm)
		
		10.1.125.152			#centos7 真实服务器一
		
		10.1.125.153			#centos7 真实服务器二
	
	2，LVS服务器配置VIP网卡
	
		输入命令：
		
			cd /etc/sysconfig/network-scripts/
			
			touch ifcfg-ens33:0
			
			vi ifcfg-ens33:0
		
		加入以下配置：
		
			NAME="ens33:0"
			
			DEVICE="ens33:0"
			
			IPADDR="10.1.125.200"
		
		重启网络服务，输入命令：
		
			service network restart
	
	3，LVS服务器配置IP转发
	
		输入命令：
		
			echo 1 > /proc/sys/net/ipv4/ip_forward
			
			vi /etc/sysctl.conf
		
		添加或更改以下配置，使IP转发重启不失效：
		
			net.ipv4.ip_forward=1
		
		立即启用配置，执行命令：
		
			sysctl -p
	
	4，LVS服务器配置虚拟服务记录
	
		输入命令(以下配置重启失效，一般会配置成开机自启动脚本)：
			
			ipvsadm -C
			
			ipvsadm -A -t 10.1.125.200:80 -s wrr
			
			ipvsadm -a -t 10.1.125.200:80 -r 10.1.125.152:80 -m -w 1
			
			ipvsadm -a -t 10.1.125.200:80 -r 10.1.125.153:80 -m -w 1
			
			ipvsadm -l -n
	
	5，配置真实服务器httpd
	
		输入命令：
		
			yum install -y httpd
			
			systemctl start httpd
			
			ifconfig ens33 | grep "inet " | awk '{ print $2}' > /var/www/html/index.html
		
	6，客户端测试
		
		使用浏览器访问地址，不停刷新浏览器，页面显示内容规则性变动：
		
			http://10.1.125.200
		
		如果客户端IP地址与真实服务器IP地址在同一网段访问会出错，强制更改真实服务器的路由规则，将客户端IP路由指向VIP服务器，输入命令：
			
			route add -host CIP gw 10.1.125.151 dev ens33

#### DR模式

	1，环境说明
		
		192.168.140.1			#客户端
		
		10.1.125.200			#VIP地址
		
		10.1.125.151			#centos7 LVS服务器(安装ipvsadm)
		
		10.1.125.152			#centos7 真实服务器一
		
		10.1.125.153			#centos7 真实服务器二
	
	2，LVS服务器配置VIP网卡
	
		输入命令：
		
			cd /etc/sysconfig/network-scripts/
			
			touch ifcfg-ens33:0
			
			vi ifcfg-ens33:0
		
		加入以下配置：
		
			NAME="ens33:0"
			
			DEVICE="ens33:0"
			
			IPADDR="10.1.125.200"
			
			NETMASK="255.255.255.255"
		
		重启网络服务，输入命令：
		
			service network restart
	
	3，LVS服务器配置虚拟服务记录
	
		输入命令：
			
			ipvsadm -C
			
			ipvsadm -A -t 10.1.125.200:80 -s wrr
			
			ipvsadm -a -t 10.1.125.200:80 -r 10.1.125.152:80 -m -w 1
			
			ipvsadm -a -t 10.1.125.200:80 -r 10.1.125.153:80 -m -w 1
			
			ipvsadm -l -n
	
	4，真实服务器配置httpd服务
	
		输入命令：
			
			yum install -y httpd
			
			systemctl start httpd
			
			ifconfig ens33 | grep "inet " | awk '{ print $2}' > /var/www/html/index.html
		
	5，真实服务器配置VIP网卡
	
		输入命令：
		
			cd /etc/sysconfig/network-scripts/
			
			vi ifcfg-lo:0
		
		添加以下配置到网卡：
		
			NAME="lo:0"
			
			DEVICE="lo:0"
			
			IPADDR="10.1.125.200"
			
			BROADCAST="10.1.125.200"
			
			NETMASK="255.255.255.255"
		
		重启网络服务，输入命令：
		
			service network restart
		
	6，真实服务器配置静态路由
	
		输入命令：
		
			vi /etc/sysconfig/static-routes
			
		添加以下内容：
		
			any host 10.1.125.200 dev lo:0
		
		重启网络服务，输入命令：
		
			service network restart
		
	7，真实服务器配置禁用arp
	
		输入命令：
		
			vi /etc/sysctl.conf
		
		添加以下内容：
		
			net.ipv4.conf.lo.arp_ignore=1
			net.ipv4.conf.lo.arp_announce=2
			net.ipv4.conf.ens33.arp_ignore=1
			net.ipv4.conf.ens33.arp_announce=2
			net.ipv4.conf.all.arp_ignore=1
			net.ipv4.conf.all.arp_announce=2
		
		立即启用配置，执行命令：
		
			sysctl -p
		
	8，客户端测试
	
		访问地址： http://10.1.125.200

#### lvs+keepalived

	https://www.keepalived.org/manpage.html
	
	







