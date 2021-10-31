
# docker ipvlan networks

	IPvlan模式，根据宿主机网卡创建多个虚拟网卡，所有网卡具有相同的 mac 和不同的 IP 地址，有 L2 和 L3 两种工作模式

	此模式下，需要自己手动分配各个宿主机的容器IP地址，且容器不能跨网段连接宿主机，需要配合其他模式一起使用

#### 服务器准备

	192.168.140.200

	192.168.140.201

	(两台服务器根据 Part1 配置好 docker，并且内核版本不低于4.2)

#### 容器网络

	整体网络规划：

		IPvlan网段：IP 10.1.0.0/16 Gateway 10.1.0.1

		第一台服务器网段：10.1.1.0/24

		第二台服务器网段：10.1.2.0/24

	两台服务器配置 docker ipvlan l2 模式网卡，输入命令：

		docker network  create \
			-d ipvlan \
			--subnet=10.1.0.0/16 \
			--gateway=10.1.0.1 \
			-o ipvlan_mode=l2 \
			-o parent=ens33 \
			ipvlanl2

		docker network ls

		->
		+--------------+------------------+---------+-------+
		|  NETWORK ID  |      NAME        |  DRIVER | SCOPE |
		+--------------+------------------+---------+-------+
		| 5217f2232b46 |  bridge          | bridge  | local |
		+--------------+------------------+---------+-------+
		| 1f514d9ef86b |  host            | host    | local |
		+--------------+------------------+---------+-------+
		| b020119e4d9e |  ipvlanl2        | ipvlan  | global|
		+--------------+------------------+---------+-------+
		| 7c9f12689eb8 |  none            | null    | local |
		+--------------+------------------+---------+-------+

	第一台服务器运行 centos 和 nginx 容器，输入命令：

		docker pull centos

		docker pull nginx

		docker run -d -it --net=ipvlanl2 --name centos --ip 10.1.1.1 centos /usr/sbin/init

		docker run -d -it --net=ipvlanl2 --name nginx -p 80:80 --ip 10.1.1.2 nginx

		docker ps

	第二台服务器运行 centos 和 nginx 容器，输入命令：

		docker pull centos

		docker pull nginx

		docker run -d -it --net=ipvlanl2 --name centos --ip 10.1.2.1 centos /usr/sbin/init

		docker run -d -it --net=ipvlanl2 --name nginx -p 80:80 --ip 10.1.2.2 nginx

		docker ps

	两台服务器查看容器网络，输入命令：

		docker network inspect ipvlanl2

		-> 第一台服务器输出
		+----------+------------------+-----------------+-------------------+----------------+-------------------+
		| Network  |      Subnet      |     Gateway     |     container     |   IPv4Address  |     MacAddress    |
		+----------+------------------+-----------------+-------------------+----------------+-------------------+
		|          |                  |                 |      centos       |   10.1.1.1/16  |                   |
		| ipvlanl2 |   10.1.0.0/16    |     10.1.0.1    +-------------------+----------------+-------------------+
		|          |                  |                 |       nginx       |   10.1.1.2/16  |                   |
		+----------+------------------+-----------------+-------------------+----------------+-------------------+

		-> 第二台服务器输出
		+----------+------------------+-----------------+-------------------+----------------+-------------------+
		| Network  |      Subnet      |     Gateway     |     container     |   IPv4Address  |     MacAddress    |
		+----------+------------------+-----------------+-------------------+----------------+-------------------+
		|          |                  |                 |      centos       |   10.1.2.1/16  |                   |
		| ipvlanl2 |   10.1.0.0/16    |     10.1.0.1    +-------------------+----------------+-------------------+
		|          |                  |                 |       nginx       |   10.1.2.2/16  |                   |
		+----------+------------------+-----------------+-------------------+----------------+-------------------+

	以上配置成功，四个容器的IP地址分别为：

		10.1.1.1	10.1.1.2

		10.1.2.1	10.1.2.2

#### 容器ping

	容器可以 ping 本机容器，输入命令：

		docker exec -it centos ping 10.1.1.2

		->

			64 bytes from 10.1.1.2: icmp_seq=1 ttl=64 time=0.218 ms
			64 bytes from 10.1.1.2: icmp_seq=2 ttl=64 time=0.065 ms
			64 bytes from 10.1.1.2: icmp_seq=3 ttl=64 time=0.045 ms
			3 packets transmitted, 3 received, 0% packet loss, time 2055ms

	容器可以 ping 跨主机容器，输入命令：

		docker exec -it centos ping 10.1.2.1

		->

			64 bytes from 10.1.2.1: icmp_seq=1 ttl=64 time=0.651 ms
			64 bytes from 10.1.2.1: icmp_seq=2 ttl=64 time=0.330 ms
			64 bytes from 10.1.2.1: icmp_seq=3 ttl=64 time=0.437 ms
			3 packets transmitted, 3 received, 0% packet loss, time 2038ms

	容器不能 ping 宿主机，输入命令：

		docker exec -it centos ping 192.168.140.201

		->

			From 10.1.1.1 icmp_seq=1 Destination Host Unreachable
			From 10.1.1.1 icmp_seq=2 Destination Host Unreachable
			From 10.1.1.1 icmp_seq=3 Destination Host Unreachable
			4 packets transmitted, 0 received, +3 errors, 100% packet loss, time 3070ms

	容器不能 ping 互联网，输入命令：

		docker exec -it centos ping www.baidu.com

		->
			ping: www.baidu.com: Name or service not known

	宿主机不能 ping 容器，输入命令：

		ping 10.1.1.1

		->
			46 packets transmitted, 0 received, 100% packet loss, time 46082ms

	宿主机不能访问 nginx，输入命令：

		curl http://192.168.140.200

		->
			curl: (7) Failed connect to 192.168.140.200:80; Connection refused

	以上可以发现，容器只能访问本机、跨主机容器，无法访问宿主机，外界也访问不到容器

#### 容器混合网络

	实际部署中，有些容器需要发布到互联网，比如 nginx 容器，而 centos 不需要网络

	可以参考 overlay 模式，引入 bridge 网络让 nginx 容器能与外界通信

	两台宿主机接入 bridge 网络，输入命令：

		docker network ls

		docker network connect bridge nginx

	两台宿主机查看 nginx 网络，输入命令：

		docker ps

		docker network inspect bridge

		->
		+----------+------------------+-----------------+-------------------+----------------+-------------------+
		| Network  |      Subnet      |     Gateway     |     container     |   IPv4Address  |     MacAddress    |
		+----------+------------------+-----------------+-------------------+----------------+-------------------+
		|  bridge  |   172.17.0.0/16  |    172.17.0.1   |      nginx        | 172.17.0.2/16  | 02:42:ac:11:00:02 |
		+----------+------------------+-----------------+-------------------+----------------+-------------------+

	客户端访问 nginx，输入命令：

		curl http://192.168.140.200

		curl http://192.168.140.201

		-> Welcome to nginx!

	如果需要关闭 bridge 网络，输入命令：

		docker network disconnect bridge nginx
