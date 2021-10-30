
# docker container networks

	共享容器网络，容器启动时加上 --net=container:<NAME> 参数，<NAME>为另一个运行中的容器名称
	
	容器共享另一个容器的网卡，网络状况决定于另一个容器启用的网络模式

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

	运行一个使用 bridge 网络的 centos 容器，输入命令：
		
		docker pull centos
		
		docker run -it -d --name centos1 centos /usr/sbin/init
		
		docker ps
		
	再运行一个使用 host 网络的 centos 容器，输入命令：
	
		docker run -it -d --net=host --name centos2 centos /usr/sbin/init
		
		docker ps
	
	运行两个使用 container 网络的 centos 容器，分别共享上面两个容器网卡，输入命令：
		
		docker run -it -d --net=container:centos1 --name centos3 centos /usr/sbin/init
		
		docker run -it -d --net=container:centos2 --name centos4 centos /usr/sbin/init
		
		docker ps
	
	查看四个容器的网络信息，输入命令：
		
		docker exec -it centos1 ip addr
		
		->
			eth0@if28: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP group default 
			 link/ether 02:42:ac:11:00:02 brd ff:ff:ff:ff:ff:ff link-netnsid 0
			inet 172.17.0.2/16 brd 172.17.255.255 scope global eth0
			 valid_lft forever preferred_lft forever
			
		docker exec -it centos2 ip addr
		
		->
			ens33: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UP group default qlen 1000
			  link/ether 00:0c:29:92:0a:f0 brd ff:ff:ff:ff:ff:ff
			inet 192.168.140.201/24 brd 192.168.140.255 scope global dynamic noprefixroute ens33
			  valid_lft 1064sec preferred_lft 1064sec
			inet6 fe80::3f70:c3dc:1b42:62c/64 scope link noprefixroute 
			  valid_lft forever preferred_lft forever
			
			docker0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP group default 
			  link/ether 02:42:0e:15:fa:40 brd ff:ff:ff:ff:ff:ff
			inet 172.17.0.1/16 brd 172.17.255.255 scope global docker0
			  valid_lft forever preferred_lft forever
			inet6 fe80::42:eff:fe15:fa40/64 scope link 
			  valid_lft forever preferred_lft forever
			
			veth4cd7e0d@if27: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue master docker0 state UP group default 
			  link/ether 86:6f:59:cf:29:9b brd ff:ff:ff:ff:ff:ff link-netnsid 0
			inet6 fe80::846f:59ff:fecf:299b/64 scope link 
			  valid_lft forever preferred_lft forever
			
		docker exec -it centos3 ip addr
		
		->
			eth0@if28: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP group default 
			 link/ether 02:42:ac:11:00:02 brd ff:ff:ff:ff:ff:ff link-netnsid 0
			inet 172.17.0.2/16 brd 172.17.255.255 scope global eth0
			 valid_lft forever preferred_lft forever
			
		docker exec -it centos4 ip addr
		
		->
			ens33: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UP group default qlen 1000
			  link/ether 00:0c:29:92:0a:f0 brd ff:ff:ff:ff:ff:ff
			inet 192.168.140.201/24 brd 192.168.140.255 scope global dynamic noprefixroute ens33
			  valid_lft 1633sec preferred_lft 1633sec
			inet6 fe80::3f70:c3dc:1b42:62c/64 scope link noprefixroute 
			  valid_lft forever preferred_lft forever
			
			docker0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP group default 
			  link/ether 02:42:0e:15:fa:40 brd ff:ff:ff:ff:ff:ff
			inet 172.17.0.1/16 brd 172.17.255.255 scope global docker0
			  valid_lft forever preferred_lft forever
			inet6 fe80::42:eff:fe15:fa40/64 scope link 
			  valid_lft forever preferred_lft forever
			
			veth4cd7e0d@if27: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue master docker0 state UP group default 
			  link/ether 86:6f:59:cf:29:9b brd ff:ff:ff:ff:ff:ff link-netnsid 0
			inet6 fe80::846f:59ff:fecf:299b/64 scope link 
			  valid_lft forever preferred_lft forever
	
	可以看到 centos3 共享了 centos1 网络，centos4 共享了 centos2 网络

#### 容器ping

	与共享容器的网络模式对应，这里不做测试

