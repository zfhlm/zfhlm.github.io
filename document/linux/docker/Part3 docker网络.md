
# docker

#### docker 网络

	每台安装了 docker 的宿主机都会生成一个虚拟桥接网卡 docker0，宿主机查看网卡信息，输入命令：
		
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
	
	docker 启动容器有五种网络模式：
	
		bridge			#容器启动使用 --net=bridge 参数，不指定参数时默认使用此模式，为每个容器分配一个本机可识别的 IP 地址
		
		host			#容器启动使用 --net=host 参数，容器直接使用宿主机的网卡地址
		
		none			#容器启动使用 --net=none 参数，docker 不会给容器做任何网络配置
		
		container		#容器启动使用 --net=container:<container> 参数，容器与指定的另一个容器共享网络
		
		network		#容器启动使用 --net=<name> 参数，<name>使用自己创建的 bridge 或 overlay 类型网卡名称

#### docker 网络bridge模式

	宿主机启动两个 centos 容器，并查看容器的网卡信息，输入命令：
		
		docker pull centos
		
		docker run -it -d --name centos1 centos /usr/sbin/init
		
		docker run -it -d --name centos2 centos /usr/sbin/init
		
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
	
	再次查看宿主机网卡信息，输入命令：
		
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
	
	此模式下 docker 使用了 linux 虚拟网络设备 veth-pair 技术处理容器的网络连接，两个容器网络状态如下：
		
		宿主机网卡     宿主机 veth虚拟网卡     容器veth虚拟网卡
		
		docker0  <->  veth04acfbc@if8   <->  eth0@if9
		
		docker0  <->  vethade2d2e@if10  <->  eth0@if11
		
	此模式下 docker 使用 veth-pair 技术，容器可以与宿主机、宿主机网络可达主机、本机的其他容器进行通信，检测容器网络可达状况，输入命令：
		
		docker exec -it centos2 ping 172.17.0.2
		
		->
			64 bytes from 172.17.0.2: icmp_seq=1 ttl=64 time=0.171 ms
			64 bytes from 172.17.0.2: icmp_seq=2 ttl=64 time=0.052 ms
			64 bytes from 172.17.0.2: icmp_seq=3 ttl=64 time=0.052 ms
			--- 172.17.0.2 ping statistics ---
			3 packets transmitted, 3 received, 0% packet loss, time 2000ms
		
		docker exec -it centos2 ping 172.17.0.3
		
		->
			64 bytes from 172.17.0.3: icmp_seq=1 ttl=64 time=0.056 ms
			64 bytes from 172.17.0.3: icmp_seq=2 ttl=64 time=0.070 ms
			64 bytes from 172.17.0.3: icmp_seq=3 ttl=64 time=0.034 ms
			--- 172.17.0.3 ping statistics ---
			3 packets transmitted, 3 received, 0% packet loss, time 2000ms
		
		docker exec -it centos2 ping 192.168.140.201
		
		->
			64 bytes from 192.168.140.201: icmp_seq=1 ttl=64 time=0.205 ms
			64 bytes from 192.168.140.201: icmp_seq=2 ttl=64 time=0.050 ms
			64 bytes from 192.168.140.201: icmp_seq=3 ttl=64 time=0.045 ms
			--- 192.168.140.201 ping statistics ---
			3 packets transmitted, 3 received, 0% packet loss, time 2000ms
		
		docker exec -it centos2 ping 192.168.140.202
		
		->
			64 bytes from 192.168.140.202: icmp_seq=1 ttl=63 time=0.981 ms
			64 bytes from 192.168.140.202: icmp_seq=2 ttl=63 time=0.308 ms
			64 bytes from 192.168.140.202: icmp_seq=3 ttl=63 time=0.283 ms
			--- 192.168.140.202 ping statistics ---
			3 packets transmitted, 3 received, 0% packet loss, time 2002ms
		
		docker exec -it centos2 ping www.baidu.com
		
		-> 
			64 bytes from 14.215.177.38 (14.215.177.38): icmp_seq=1 ttl=127 time=11.7 ms
			64 bytes from 14.215.177.38 (14.215.177.38): icmp_seq=2 ttl=127 time=10.3 ms
			64 bytes from 14.215.177.38 (14.215.177.38): icmp_seq=3 ttl=127 time=11.0 ms
			--- www.baidu.com ping statistics ---
			3 packets transmitted, 3 received, 0% packet loss, time 2004ms
	
	docker 分配给容器的 IP 地址是不固定的，以下操作可以看出，输入命令：
		
		docker stop centos2
		
		docker run -it -d --name centos3 centos /usr/sbin/init
		
		docker exec -it centos3 ip addr
		
		-> 
			eth0@if15: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP group default 
			link/ether 02:42:ac:11:00:03 brd ff:ff:ff:ff:ff:ff link-netnsid 0
			inet 172.17.0.3/16 brd 172.17.255.255 scope global eth0
			valid_lft forever preferred_lft forever
		
		docker start centos2
		
		docker exec -it centos2 ip addr
		
		->	
			eth0@if17: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP group default 
			link/ether 02:42:ac:11:00:04 brd ff:ff:ff:ff:ff:ff link-netnsid 0
			inet 172.17.0.4/16 brd 172.17.255.255 scope global eth0
			valid_lft forever preferred_lft forever
	
	docker 分配给容器 IP，相当于在本机构建了一个 172.17.0.1/16 网段局域网，容器的IP地址对外是无法访问的，另一台主机输入命令：
	
		docker pull centos
		
		docker run -it -d --name centos centos /usr/sbin/init
		
		docker exec -it centos ping 172.17.0.3
		
		->
			PING 172.17.0.3 (172.17.0.3) 56(84) bytes of data.
			From 172.17.0.2 icmp_seq=1 Destination Host Unreachable
			From 172.17.0.2 icmp_seq=2 Destination Host Unreachable
			From 172.17.0.2 icmp_seq=3 Destination Host Unreachable
			From 172.17.0.2 icmp_seq=4 Destination Host Unreachable
			--- 172.17.0.3 ping statistics ---
			4 packets transmitted, 0 received, +4 errors, 100% packet loss, time 3000ms

#### docker 网络host模式
	
	启动 centos 容器，查看网卡信息，输入命令：
		
		docker pull centos
		
		docker run -it -d --net=host --name centos centos /usr/sbin/init
		
		docker exec -it centos ip addr
		
		->
			ens33: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UP group default qlen 1000
			link/ether 00:0c:29:92:0a:f0 brd ff:ff:ff:ff:ff:ff
			inet 192.168.140.201/24 brd 192.168.140.255 scope global dynamic noprefixroute ens33
			valid_lft 1067sec preferred_lft 1067sec
			inet6 fe80::3f70:c3dc:1b42:62c/64 scope link noprefixroute 
			valid_lft forever preferred_lft forever
       	
			docker0: <NO-CARRIER,BROADCAST,MULTICAST,UP> mtu 1500 qdisc noqueue state DOWN group default 
			link/ether 02:42:0e:15:fa:40 brd ff:ff:ff:ff:ff:ff
			inet 172.17.0.1/16 brd 172.17.255.255 scope global docker0
			valid_lft forever preferred_lft forever
			inet6 fe80::42:eff:fe15:fa40/64 scope link 
			valid_lft forever preferred_lft forever

#### docker 网络none模式
	
	启动 centos 容器，查看网卡信息，只有一个本机回环网卡lo，输入命令：
		
		docker pull centos
		
		docker run -it -d --net=none --name centos centos /usr/sbin/init
		
		docker exec -it centos ip addr
		
		-> 
			lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
		   link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
		   inet 127.0.0.1/8 scope host lo
		   valid_lft forever preferred_lft forever

#### docker 网络container模式
	
	使用 bridge 模式启动一个 centos 容器，输入命令：
		
		docker pull centos
		
		docker run -it -d --name centos1 centos /usr/sbin/init
		
		docker exec -it centos1 ip addr
		
		->
			eth0@if19: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP group default 
			link/ether 02:42:ac:11:00:02 brd ff:ff:ff:ff:ff:ff link-netnsid 0
			inet 172.17.0.2/16 brd 172.17.255.255 scope global eth0
			valid_lft forever preferred_lft forever
	
	使用 container 模式启动第二个 centos 容器，输入命令：
		
		docker run -it -d --net=container:centos1 --name centos2 centos /usr/sbin/init
		
		docker exec -it centos2 ip addr
		
		-> 
			eth0@if19: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP group default 
			link/ether 02:42:ac:11:00:02 brd ff:ff:ff:ff:ff:ff link-netnsid 0
			inet 172.17.0.2/16 brd 172.17.255.255 scope global eth0
			valid_lft forever preferred_lft forever

#### docker 网络network-bridge模式

	宿主机创建 bridge 网卡，输入命令：
		
		docker network ls
		
		docker network create -d bridge net-bridge
		
		docker network ls
		
	宿主机查看网卡信息，可以看到多了一个 172.18.0.1/16 网段网卡：
		
		ip addr
		
		->
			ens33: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UP group default qlen 1000
			link/ether 00:0c:29:92:0a:f0 brd ff:ff:ff:ff:ff:ff
			inet 192.168.140.201/24 brd 192.168.140.255 scope global noprefixroute dynamic ens33
			valid_lft 1780sec preferred_lft 1780sec
			inet6 fe80::3f70:c3dc:1b42:62c/64 scope link noprefixroute 
			valid_lft forever preferred_lft forever
			
			docker0: <NO-CARRIER,BROADCAST,MULTICAST,UP> mtu 1500 qdisc noqueue state DOWN group default 
			link/ether 02:42:0e:15:fa:40 brd ff:ff:ff:ff:ff:ff
			inet 172.17.0.1/16 brd 172.17.255.255 scope global docker0
			valid_lft forever preferred_lft forever
			inet6 fe80::42:eff:fe15:fa40/64 scope link 
			valid_lft forever preferred_lft forever
			
			br-ef16dc03f3d3: <NO-CARRIER,BROADCAST,MULTICAST,UP> mtu 1500 qdisc noqueue state DOWN group default 
			link/ether 02:42:d4:0d:f1:f0 brd ff:ff:ff:ff:ff:ff
			inet 172.18.0.1/16 brd 172.18.255.255 scope global br-ef16dc03f3d3
			valid_lft forever preferred_lft forever
			inet6 fe80::42:d4ff:fe0d:f1f0/64 scope link 
			valid_lft forever preferred_lft forever
	
	使用创建的网卡启动一个 centos 容器，查看网卡信息，输入命令：
		
		docker pull centos
		
		docker run -it -d --net=net-bridge --name centos centos /usr/sbin/init
		
		docker exec -it centos ip addr
		
		->
			eth0@if26: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP group default 
			link/ether 02:42:ac:12:00:02 brd ff:ff:ff:ff:ff:ff link-netnsid 0
			inet 172.18.0.2/16 brd 172.18.255.255 scope global eth0
			valid_lft forever preferred_lft forever
	
	宿主机再次查看网卡信息，输入命令：
		
		ip addr
		
		->
			ens33: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UP group default qlen 1000
			link/ether 00:0c:29:92:0a:f0 brd ff:ff:ff:ff:ff:ff
			inet 192.168.140.201/24 brd 192.168.140.255 scope global noprefixroute dynamic ens33
			valid_lft 1780sec preferred_lft 1780sec
			inet6 fe80::3f70:c3dc:1b42:62c/64 scope link noprefixroute 
			valid_lft forever preferred_lft forever
			
			docker0: <NO-CARRIER,BROADCAST,MULTICAST,UP> mtu 1500 qdisc noqueue state DOWN group default 
			link/ether 02:42:0e:15:fa:40 brd ff:ff:ff:ff:ff:ff
			inet 172.17.0.1/16 brd 172.17.255.255 scope global docker0
			valid_lft forever preferred_lft forever
			inet6 fe80::42:eff:fe15:fa40/64 scope link 
			valid_lft forever preferred_lft forever
			
			br-ef16dc03f3d3: <NO-CARRIER,BROADCAST,MULTICAST,UP> mtu 1500 qdisc noqueue state DOWN group default 
			link/ether 02:42:d4:0d:f1:f0 brd ff:ff:ff:ff:ff:ff
			inet 172.18.0.1/16 brd 172.18.255.255 scope global br-ef16dc03f3d3
			valid_lft forever preferred_lft forever
			inet6 fe80::42:d4ff:fe0d:f1f0/64 scope link 
			valid_lft forever preferred_lft forever
			
			vethc3998f4@if25: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue master br-ef16dc03f3d3 state UP group default 
			link/ether fe:db:c1:0c:5e:b9 brd ff:ff:ff:ff:ff:ff link-netnsid 0
			inet6 fe80::fcdb:c1ff:fe0c:5eb9/64 scope link 
			valid_lft forever preferred_lft forever
	
	宿主机多了个 veth 虚拟网卡，创建的 docker network bridge 网卡和 docker bridge 网卡是一样的，除了网段不一样

#### docker 网络network-overlay模式

	

