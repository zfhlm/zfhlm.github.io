
# docker bridge networks

	桥接网络是容器默认的网络模式，容器启动加上参数 --net=bridge 或者不指定 --net 参数
	
	注意，使用 docker network create -d bridge <NAME> 命令创建的网卡，也属于桥接网络
	
	每个容器都有一个 docker 分配的 IP地址，此模式下容器不能跨主机访问，只适合单机运行多个 docker 容器

#### 服务器准备

	192.168.140.201
	
	192.168.140.202
	
	(两台虚拟机根据 Part1 配置好 docker)

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

	宿主机运行两个 centos 容器，输入命令：
		
		docker pull centos
		
		docker run -it -d --name centos1 centos /usr/sbin/init
		
		docker run -it -d --name centos1 centos /usr/sbin/init
		
		docker ps
	
	宿主机查看 centos 容器网络，输入命令：
		
		docker exec -it centos1 ip addr
		
		-> 
			eth0@if9: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP group default 
			  link/ether 02:42:ac:11:00:02 brd ff:ff:ff:ff:ff:ff link-netnsid 0
			inet 172.17.0.2/16 brd 172.17.255.255 scope global eth0
			  valid_lft forever preferred_lft forever
		
		docker exec -it centos2 ip addr
		
		-> 
			eth0@if11: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP group default 
			  link/ether 02:42:ac:11:00:03 brd ff:ff:ff:ff:ff:ff link-netnsid 0
			inet 172.17.0.3/16 brd 172.17.255.255 scope global eth0
			  valid_lft forever preferred_lft forever
	
	宿主机查看本机网络，输入命令：
		
		ip addr
		
		-> 
			docker0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP group default 
			link/ether 02:42:0e:15:fa:40 brd ff:ff:ff:ff:ff:ff
			inet 172.17.0.1/16 brd 172.17.255.255 scope global docker0
			valid_lft forever preferred_lft forever
		 	inet6 fe80::42:eff:fe15:fa40/64 scope link 
			valid_lft forever preferred_lft forever
		       
			veth04acfbc@if8: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue master docker0 state UP group default 
			link/ether f6:4f:32:53:5a:ac brd ff:ff:ff:ff:ff:ff link-netnsid 0
			inet6 fe80::f44f:32ff:fe53:5aac/64 scope link 
			valid_lft forever preferred_lft forever
		       
			vethade2d2e@if10: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue master docker0 state UP group default 
			link/ether 82:d6:96:ee:1c:d9 brd ff:ff:ff:ff:ff:ff link-netnsid 1
			inet6 fe80::80d6:96ff:feee:1cd9/64 scope link 
			valid_lft forever preferred_lft forever
	
	对比宿主机和容器的网络，可以看到：
	
		宿主机多了两个网卡 veth04acfbc@if8、vethade2d2e@if10，并且两个网卡的 master 都是 docker0
		
		容器的网卡分别是 eth0@if9、eth0@if11
	
	此模式下 docker 使用了虚拟网络设备 veth-pair 技术处理容器的网络连接，容器与宿主机的网络关系如下：
		
		宿主机网卡     宿主机 veth虚拟网卡     容器veth虚拟网卡
		
		docker0  <->  veth04acfbc@if8   <->  eth0@if9
		
		docker0  <->  vethade2d2e@if10  <->  eth0@if11
	
	容器通过自身的 veth 虚拟网卡，与配对的宿主机 veth 虚拟网卡进行网络通信，宿主机 veth 虚拟网卡再将网络通信转发给 master 网卡 docker0

#### 容器ping

	容器可以 ping 宿主机，输入命令：
		
		docker exec -it centos2 ping 192.168.140.201
		
		->
			64 bytes from 192.168.140.201: icmp_seq=1 ttl=64 time=0.205 ms
			64 bytes from 192.168.140.201: icmp_seq=2 ttl=64 time=0.050 ms
			64 bytes from 192.168.140.201: icmp_seq=3 ttl=64 time=0.045 ms
			--- 192.168.140.201 ping statistics ---
			3 packets transmitted, 3 received, 0% packet loss, time 2000ms
	
	容器可以 ping 与宿主机同一局域网的主机，输入命令：
		
		docker exec -it centos2 ping 192.168.140.202
		
		->
			64 bytes from 192.168.140.202: icmp_seq=1 ttl=63 time=0.981 ms
			64 bytes from 192.168.140.202: icmp_seq=2 ttl=63 time=0.308 ms
			64 bytes from 192.168.140.202: icmp_seq=3 ttl=63 time=0.283 ms
			--- 192.168.140.202 ping statistics ---
			3 packets transmitted, 3 received, 0% packet loss, time 2002ms
	
	容器可以 ping 宿主机能访问的互联网，输入命令：
		
		docker exec -it centos2 ping www.baidu.com
		
		-> 
			64 bytes from 14.215.177.38 (14.215.177.38): icmp_seq=1 ttl=127 time=11.7 ms
			64 bytes from 14.215.177.38 (14.215.177.38): icmp_seq=2 ttl=127 time=10.3 ms
			64 bytes from 14.215.177.38 (14.215.177.38): icmp_seq=3 ttl=127 time=11.0 ms
			--- www.baidu.com ping statistics ---
			3 packets transmitted, 3 received, 0% packet loss, time 2004ms
	
	容器可以 ping 同一宿主机的其他容器，输入命令：
		
		docker exec -it centos2 ping 172.17.0.2
		
		->
			64 bytes from 172.17.0.2: icmp_seq=1 ttl=64 time=0.171 ms
			64 bytes from 172.17.0.2: icmp_seq=2 ttl=64 time=0.052 ms
			64 bytes from 172.17.0.2: icmp_seq=3 ttl=64 time=0.052 ms
			--- 172.17.0.2 ping statistics ---
			3 packets transmitted, 3 received, 0% packet loss, time 2000ms
	
	容器不能 ping 另一台宿主机的容器，输入命令：
	
		(注：在另一台宿主机运行三个 centos 容器，其中一个 IP 地址为 172.17.0.3)
		
		docker exec -it centos ping 172.17.0.3
		
		->
			PING 172.17.0.3 (172.17.0.3) 56(84) bytes of data.
			From 172.17.0.2 icmp_seq=1 Destination Host Unreachable
			From 172.17.0.2 icmp_seq=2 Destination Host Unreachable
			From 172.17.0.2 icmp_seq=3 Destination Host Unreachable
			From 172.17.0.2 icmp_seq=4 Destination Host Unreachable
			--- 172.17.0.3 ping statistics ---
			4 packets transmitted, 0 received, +4 errors, 100% packet loss, time 3000ms

#### 容器IP
	
	宿主机查看容器 centos2 网络，输入命令：
		
		docker exec -it centos2 ip addr
		
		-> 
			eth0@if15: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP group default 
			link/ether 02:42:ac:11:00:03 brd ff:ff:ff:ff:ff:ff link-netnsid 0
			inet 172.17.0.3/16 brd 172.17.255.255 scope global eth0
			valid_lft forever preferred_lft forever
			
	宿主机关闭容器 centos2，运行新的容器 centos3，再启动容器 centos2，输入命令：
		
		docker stop centos2
		
		docker run -it -d --name centos3 centos /usr/sbin/init
		
		docker start centos2
		
	宿主机查看容器 centos2、centos3 网络，输入命令：
		
		docker exec -it centos2 ip addr
		
		->	
			eth0@if17: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP group default 
			link/ether 02:42:ac:11:00:04 brd ff:ff:ff:ff:ff:ff link-netnsid 0
			inet 172.17.0.4/16 brd 172.17.255.255 scope global eth0
			valid_lft forever preferred_lft forever
		
		docker exec -it centos3 ip addr
		
		-> 
			eth0@if15: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP group default 
			link/ether 02:42:ac:11:00:03 brd ff:ff:ff:ff:ff:ff link-netnsid 0
			inet 172.17.0.3/16 brd 172.17.255.255 scope global eth0
			valid_lft forever preferred_lft forever
	
	以上可以看出，容器 IP 不是固定的，每次重启都可能会发生变化


