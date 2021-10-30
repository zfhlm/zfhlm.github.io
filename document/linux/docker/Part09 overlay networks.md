
# docker overlay networks

	overlay模式，使用 docker network create -d overlay <NAME> 创建docker网卡，启动时加上 --net=<NAME> 参数
	
	overlay模式可以通过 swarm 或者 consul 实现，容器之间可以跨主机互相访问

#### 服务器准备

	192.168.140.200		#docker宿主机
	
	192.168.140.201		#docker宿主机
	
	192.168.140.202		#consul服务器
	
	(三台服务器根据 Part1 配置好 docker，并且内核版本不低于3.18)

#### 配置overlay环境

	consul服务器安装启动consul，输入命令：
		
		docker pull consul
		
		docker images
		
		docker run -d -p 8500:8500 --name consul consul
		
		docker ps
	
	客户端浏览器查看consul，输入地址：
		
		http://192.168.140.202:5800/
	
	两台宿主机输入命令：
		
		vi /etc/docker/daemon.json
		
		=> #加入以下配置
			{
				"cluster-store": "consul://192.168.140.202:8500",
				"cluster-advertise": "ens33:2376"
			}
	
	两台宿主机重启 docker，输入命令：
		
		systemctl daemon-reload
		
		systemctl restart docker
	
	客户端浏览器查看 consul Key/Value 可以看到两个节点注册成功：
		
		192.168.140.201:2376
		
		192.168.140.200:2376
	
	一台宿主机创建 docker overlay network，输入命令：
	
		docker network create -d overlay my-overlay
	
	两台宿主机查看 docker network，输入命令：
	
		docker network ls
		
		-> 控制台输出以下信息
		
			NETWORK ID     NAME         DRIVER    SCOPE
			53645a395719   bridge       bridge    local
			ee8fd6692cdd   host         host      local
			b020119e4d9e   my-overlay   overlay   global
			adf9c8bdb9dc   none         null      local
	
	至此配置完成

#### 容器网络

	第一台宿主机运行  centos 容器，输入命令：
		
		docker run -d -it --net my-overlay --name centos1 centos /usr/sbin/init
		
	第二台宿主机运行 centos 容器，输入命令：
		
		docker run -d -it --net my-overlay --name centos2 centos /usr/sbin/init
		
	两台宿主机查看网络信息，输入命令：
		
		ip addr
		
		-> 第一台宿主机输出信息：
			
			ens33: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UP group default qlen 1000
			  link/ether 00:0c:29:d7:d4:c3 brd ff:ff:ff:ff:ff:ff
			inet 192.168.140.200/24 brd 192.168.140.255 scope global noprefixroute dynamic ens33
			  valid_lft 1314sec preferred_lft 1314sec
			inet6 fe80::1113:a524:482a:ad8/64 scope link noprefixroute 
			  valid_lft forever preferred_lft forever
			
			docker0: <NO-CARRIER,BROADCAST,MULTICAST,UP> mtu 1500 qdisc noqueue state DOWN group default 
			  link/ether 02:42:f5:1e:5b:5b brd ff:ff:ff:ff:ff:ff
			inet 172.17.0.1/16 brd 172.17.255.255 scope global docker0
			  valid_lft forever preferred_lft forever
			inet6 fe80::42:f5ff:fe1e:5b5b/64 scope link 
			  valid_lft forever preferred_lft forever
			
			docker_gwbridge: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP group default 
			  link/ether 02:42:34:e4:88:b4 brd ff:ff:ff:ff:ff:ff
			inet 172.18.0.1/16 brd 172.18.255.255 scope global docker_gwbridge
			  valid_lft forever preferred_lft forever
			inet6 fe80::42:34ff:fee4:88b4/64 scope link 
			  valid_lft forever preferred_lft forever
			
			vethe12d07b@if20: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue master docker_gwbridge state UP group default
			  link/ether 1a:20:c5:6f:2b:ea brd ff:ff:ff:ff:ff:ff link-netnsid 1
			inet6 fe80::1820:c5ff:fe6f:2bea/64 scope link 
			  valid_lft forever preferred_lft forever
		
		-> 第二台宿主机输出信息：
			
			ens33: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UP group default qlen 1000
			  link/ether 00:0c:29:92:0a:f0 brd ff:ff:ff:ff:ff:ff
			inet 192.168.140.201/24 brd 192.168.140.255 scope global noprefixroute dynamic ens33
			  valid_lft 1136sec preferred_lft 1136sec
			inet6 fe80::3f70:c3dc:1b42:62c/64 scope link noprefixroute 
			  valid_lft forever preferred_lft forever
			
			docker0: <NO-CARRIER,BROADCAST,MULTICAST,UP> mtu 1500 qdisc noqueue state DOWN group default 
			  link/ether 02:42:0e:15:fa:40 brd ff:ff:ff:ff:ff:ff
			inet 172.17.0.1/16 brd 172.17.255.255 scope global docker0
			  valid_lft forever preferred_lft forever
			inet6 fe80::42:eff:fe15:fa40/64 scope link 
			  valid_lft forever preferred_lft forever
			
			docker_gwbridge: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP group default 
			  link/ether 02:42:2c:8c:7a:b1 brd ff:ff:ff:ff:ff:ff
			inet 172.18.0.1/16 brd 172.18.255.255 scope global docker_gwbridge
			  valid_lft forever preferred_lft forever
			inet6 fe80::42:2cff:fe8c:7ab1/64 scope link 
			  valid_lft forever preferred_lft forever
			
			veth685f01d@if43: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue master docker_gwbridge state UP group default 
			  link/ether 76:4f:e5:19:4a:69 brd ff:ff:ff:ff:ff:ff link-netnsid 1
			inet6 fe80::744f:e5ff:fe19:4a69/64 scope link 
			  valid_lft forever preferred_lft forever
	
	两台宿主机查看 centos 容器网络，输入命令：
		
		docker exec -it centos1 ip addr
		
		-> 
			
			eth0@if19: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1450 qdisc noqueue state UP group default 
			  link/ether 02:42:0a:00:00:02 brd ff:ff:ff:ff:ff:ff link-netnsid 0
			inet 10.0.0.2/24 brd 10.0.0.255 scope global eth0
			  valid_lft forever preferred_lft forever
			
			eth1@if21: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP group default 
			  link/ether 02:42:ac:12:00:02 brd ff:ff:ff:ff:ff:ff link-netnsid 1
			inet 172.18.0.2/16 brd 172.18.255.255 scope global eth1
			  valid_lft forever preferred_lft forever
		
		docker exec -it centos2 ip addr
		
		-> 
			eth0@if42: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1450 qdisc noqueue state UP group default 
			  link/ether 02:42:0a:00:00:03 brd ff:ff:ff:ff:ff:ff link-netnsid 0
			inet 10.0.0.3/24 brd 10.0.0.255 scope global eth0
			  valid_lft forever preferred_lft forever
			
			eth1@if44: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP group default 
			  link/ether 02:42:ac:12:00:02 brd ff:ff:ff:ff:ff:ff link-netnsid 1
			inet 172.18.0.2/16 brd 172.18.255.255 scope global eth1
			  valid_lft forever preferred_lft forever
	
	两台宿主机查看 docker 网卡，输入命令：
		
		docker network ls
		
		-> 两台宿主机输出：
			
			NETWORK ID     NAME              DRIVER    SCOPE
			5217f2232b46   bridge            bridge    local
			c68a1d83cd49   docker_gwbridge   bridge    local
			1f514d9ef86b   host              host      local
			b020119e4d9e   my-overlay        overlay   global
			7c9f12689eb8   none              null      local
		
		docker network inspect my-overlay
		
		-> 两台宿主机输出：
			
			[
			    {
			        "Name": "my-overlay",
			        "Id": "b020119e4d9e684b1ba92dc761bf9ece021d9400eb01a633b03d7bf272dbe85c",
			        "Created": "2021-10-30T07:23:50.078071903-04:00",
			        "Scope": "global",
			        "Driver": "overlay",
			        "EnableIPv6": false,
			        "IPAM": {
			            "Driver": "default",
			            "Options": {},
			            "Config": [
			                {
			                    "Subnet": "10.0.0.0/24",
			                    "Gateway": "10.0.0.1"
			                }
			            ]
			        },
			        "Internal": false,
			        "Attachable": false,
			        "Ingress": false,
			        "ConfigFrom": {
			            "Network": ""
			        },
			        "ConfigOnly": false,
			        "Containers": {
			            "b64361394841565dfa4dd2b30fd08650dcff74d3542d1436c03f15e95d75fd85": {
			                "Name": "centos1",
			                "EndpointID": "fb9f5cf54399ce2dd6ee5d19c9b9d8981b17c5fbff73e8d78bf850039714e8b7",
			                "MacAddress": "02:42:0a:00:00:02",
			                "IPv4Address": "10.0.0.2/24",
			                "IPv6Address": ""
			            },
			            "ep-5ea2e4b969a3653c21759554eec3444b3ec6077d3eefd53aa7dad510d2846041": {
			                "Name": "centos2",
			                "EndpointID": "5ea2e4b969a3653c21759554eec3444b3ec6077d3eefd53aa7dad510d2846041",
			                "MacAddress": "02:42:0a:00:00:03",
			                "IPv4Address": "10.0.0.3/24",
			                "IPv6Address": ""
			            }
			        },
			        "Options": {},
			        "Labels": {}
			    }
			]
		
		docker network inspect docker_gwbridge
		
		-> 第一台宿主机输出：
			
			[
			    {
			        "Name": "docker_gwbridge",
			        "Id": "0ebea263029d9663462fa82a84b8e5808ab8f3b924cef85ac2a49f4778c6d354",
			        "Created": "2021-10-30T07:38:44.239034937-04:00",
			        "Scope": "local",
			        "Driver": "bridge",
			        "EnableIPv6": false,
			        "IPAM": {
			            "Driver": "default",
			            "Options": null,
			            "Config": [
			                {
			                    "Subnet": "172.18.0.0/16",
			                    "Gateway": "172.18.0.1"
			                }
			            ]
			        },
			        "Internal": false,
			        "Attachable": false,
			        "Ingress": false,
			        "ConfigFrom": {
			            "Network": ""
			        },
			        "ConfigOnly": false,
			        "Containers": {
			            "b64361394841565dfa4dd2b30fd08650dcff74d3542d1436c03f15e95d75fd85": {
			                "Name": "gateway_6f153690709d",
			                "EndpointID": "475104deeca5deeec12081cc02e0ab7dae56add639efde980c459f62f6703f05",
			                "MacAddress": "02:42:ac:12:00:02",
			                "IPv4Address": "172.18.0.2/16",
			                "IPv6Address": ""
			            }
			        },
			        "Options": {
			            "com.docker.network.bridge.enable_icc": "false",
			            "com.docker.network.bridge.enable_ip_masquerade": "true",
			            "com.docker.network.bridge.name": "docker_gwbridge"
			        },
			        "Labels": {}
			    }
			]
			
		-> 第二台宿主机输出：
			
			[
			    {
			        "Name": "docker_gwbridge",
			        "Id": "c68a1d83cd4951f97a47a1e789e97ac40710310e5bc708a6276801f18d627805",
			        "Created": "2021-10-30T07:37:03.742928267-04:00",
			        "Scope": "local",
			        "Driver": "bridge",
			        "EnableIPv6": false,
			        "IPAM": {
			            "Driver": "default",
			            "Options": null,
			            "Config": [
			                {
			                    "Subnet": "172.18.0.0/16",
			                    "Gateway": "172.18.0.1"
			                }
			            ]
			        },
			        "Internal": false,
			        "Attachable": false,
			        "Ingress": false,
			        "ConfigFrom": {
			            "Network": ""
			        },
			        "ConfigOnly": false,
			        "Containers": {
			            "9e8c9323349bb980b18a67f99f6797fbd93cd8006ce810fc2cf321930d04fcdb": {
			                "Name": "gateway_381d8255c34d",
			                "EndpointID": "bad7133476db308497f887ada3851a358e484a23461a1510d209ca60c5a86949",
			                "MacAddress": "02:42:ac:12:00:02",
			                "IPv4Address": "172.18.0.2/16",
			                "IPv6Address": ""
			            }
			        },
			        "Options": {
			            "com.docker.network.bridge.enable_icc": "false",
			            "com.docker.network.bridge.enable_ip_masquerade": "true",
			            "com.docker.network.bridge.name": "docker_gwbridge"
			        },
			        "Labels": {}
			    }
			]
	
	从以上输出信息中可以提取出以下信息：
		
		docker_gwbridge(172.18.0.1)  <->  vethe12d07b@if20(forward)  <->  eth1@if21(172.18.0.2)
		docker_gwbridge(172.18.0.1)  <->  veth685f01d@if43(forward)  <->  eth1@if44(172.18.0.2)
		
		my-overlay(10.0.0.1)  <->  eth0@if19(10.0.0.2)
		my-overlay(10.0.0.1)  <->  eth0@if42(10.0.0.3)
	
	容器 overlay 网络配置成功，两个容器的 overlay 网络 IP 地址分别为：10.0.0.2、10.0.0.3

#### 容器ping

	容器可以 ping 宿主机，输入命令：
		
		docker exec -it centos1 ping 192.168.140.200
		
		-> 
			PING 192.168.140.200 (192.168.140.200) 56(84) bytes of data.
			64 bytes from 192.168.140.200: icmp_seq=1 ttl=64 time=0.162 ms
			64 bytes from 192.168.140.200: icmp_seq=2 ttl=64 time=0.047 ms
			64 bytes from 192.168.140.200: icmp_seq=3 ttl=64 time=0.061 ms
			--- 192.168.140.200 ping statistics ---
			3 packets transmitted, 3 received, 0% packet loss, time 2001ms
	
	容器可以 ping 与宿主机同一局域网的主机，输入命令：
		
		docker exec -it centos1 ping 192.168.140.201
		
		-> 
			PING 192.168.140.201 (192.168.140.201) 56(84) bytes of data.
			64 bytes from 192.168.140.201: icmp_seq=1 ttl=63 time=0.775 ms
			64 bytes from 192.168.140.201: icmp_seq=2 ttl=63 time=0.297 ms
			64 bytes from 192.168.140.201: icmp_seq=3 ttl=63 time=0.476 ms
			--- 192.168.140.201 ping statistics ---
			3 packets transmitted, 3 received, 0% packet loss, time 2001ms
	
	容器可以 ping 宿主机能访问的互联网，输入命令：
		
		docker exec -it centos1 ping www.baidu.com
		
		-> 
			PING www.baidu.com (14.215.177.38) 56(84) bytes of data.
			64 bytes from 14.215.177.38 (14.215.177.38): icmp_seq=1 ttl=127 time=12.9 ms
			64 bytes from 14.215.177.38 (14.215.177.38): icmp_seq=2 ttl=127 time=13.2 ms
			64 bytes from 14.215.177.38 (14.215.177.38): icmp_seq=3 ttl=127 time=9.26 ms
			--- www.baidu.com ping statistics ---
			3 packets transmitted, 3 received, 0% packet loss, time 2004ms
	
	容器可以 ping 跨主机容器，输入命令：
		
		docker exec -it centos1 ping 10.0.0.3
		
		-> 
			PING 10.0.0.3 (10.0.0.3) 56(84) bytes of data.
			64 bytes from 10.0.0.3: icmp_seq=1 ttl=64 time=0.417 ms
			64 bytes from 10.0.0.3: icmp_seq=2 ttl=64 time=0.457 ms
			64 bytes from 10.0.0.3: icmp_seq=3 ttl=64 time=0.304 ms
			--- 10.0.0.3 ping statistics ---
			3 packets transmitted, 3 received, 0% packet loss, time 2007ms


