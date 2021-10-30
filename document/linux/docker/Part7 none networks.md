
# docker host networks

	不配置网络，启动加上 --net=none 参数
	
	每个容器都只有本机回环网卡 lo，如果手动对容器进行网卡配置，无法与容器外进行网络通信

#### 宿主机网络

	宿主机查看本机网络，输入命令：
		
		ip addr
	
		-> 
			ens33: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UP group default qlen 1000
			  link/ether 00:0c:29:92:0a:f0 brd ff:ff:ff:ff:ff:ff
			inet 192.168.140.201/24 brd 192.168.140.255 scope global noprefixroute dynamic ens33
			  valid_lft 1158sec preferred_lft 1158sec
			inet6 fe80::3f70:c3dc:1b42:62c/64 scope link noprefixroute 
			  valid_lft forever preferred_lft forever
			
			docker0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP group default 
			  link/ether 02:42:8c:5b:ba:0a brd ff:ff:ff:ff:ff:ff
			inet 172.17.0.1/16 brd 172.17.255.255 scope global docker0
			  valid_lft forever preferred_lft forever
			inet6 fe80::42:8cff:fe5b:ba0a/64 scope link 
			  valid_lft forever preferred_lft forever
	
	可以看到宿主机有两个网卡，一个安装虚拟机自带的网卡 ens33，另一个安装 docker 自动配置的网卡 docker0

#### 容器网络

	运行一个 centos 容器，输入命令：
		
		docker pull centos
		
		docker run -it -d --net=none --name centos centos /usr/sbin/init
		
		docker ps
	
	宿主机查看 centos 容器网络，输入命令：
		
		docker exec -it centos ip addr
		
		-> 
			lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
			link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
		   inet 127.0.0.1/8 scope host lo
		   valid_lft forever preferred_lft forever
	
	可以看到容器内部只有一个本机回环网卡 lo

#### 容器ping

	容器不能 ping 宿主机，输入命令：
		
		docker exec -it centos ping 192.168.140.201
	
		-> 
			connect: Network is unreachable
	
	除了 ping 自己，容器在此模式下网络完全断开


