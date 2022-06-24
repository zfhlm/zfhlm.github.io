
# docker host networks

    共享主机网络，启动加上 --net=host 参数

    每个容器都使用宿主机的网卡，网络隔离性弱化，不建议 docker 使用

#### 宿主机网络

    宿主机查看本机网络，输入命令：

        ip addr

        ->
        +-----------------+--------------------+-----------------+-------------------+----------------+-------------+
        |  interface      |      ipv4          |       brd       |       mac         |      scope     |    master   |
        +-----------------+--------------------+-----------------+-------------------+----------------+-------------+
        |    ens33        | 192.168.140.201/24 | 192.168.140.255 | 00:0c:29:92:0a:f0 |      global    |             |
        +-----------------+--------------------+-----------------+-------------------+----------------+-------------+
        |   docker0       |   172.17.0.1/16    | 172.17.255.255  | 02:42:8c:5b:ba:0a |      global    |             |
        +-----------------+--------------------+-----------------+-------------------+----------------+-------------+

    可以看到宿主机有两个网卡，一个安装虚拟机自带的网卡 ens33，另一个安装 docker 自动配置的网卡 docker0

#### 容器网络

    运行两个 centos 容器，输入命令：

        docker pull centos

        docker run -it -d --net=host --name centos1 centos /usr/sbin/init

        docker run -it -d --net=host --name centos2 centos /usr/sbin/init

        docker ps

    宿主机查看 centos 容器网络，输入命令：

        docker exec -it centos1 ip addr

        ->
        +-----------------+--------------------+-----------------+-------------------+----------------+-------------+
        |  interface      |      ipv4          |       brd       |       mac         |      scope     |    master   |
        +-----------------+--------------------+-----------------+-------------------+----------------+-------------+
        |    ens33        | 192.168.140.201/24 | 192.168.140.255 | 00:0c:29:92:0a:f0 |      global    |             |
        +-----------------+--------------------+-----------------+-------------------+----------------+-------------+
        |   docker0       |   172.17.0.1/16    | 172.17.255.255  | 02:42:8c:5b:ba:0a |      global    |             |
        +-----------------+--------------------+-----------------+-------------------+----------------+-------------+

        docker exec -it centos2 ip addr

        ->
        +-----------------+--------------------+-----------------+-------------------+----------------+-------------+
        |  interface      |      ipv4          |       brd       |       mac         |      scope     |    master   |
        +-----------------+--------------------+-----------------+-------------------+----------------+-------------+
        |    ens33        | 192.168.140.201/24 | 192.168.140.255 | 00:0c:29:92:0a:f0 |      global    |             |
        +-----------------+--------------------+-----------------+-------------------+----------------+-------------+
        |   docker0       |   172.17.0.1/16    | 172.17.255.255  | 02:42:8c:5b:ba:0a |      global    |             |
        +-----------------+--------------------+-----------------+-------------------+----------------+-------------+

    可以看出，容器共享了宿主机的网络

#### 容器ping

    容器可以 ping 宿主机，输入命令：

        docker exec -it centos1 ping 192.168.140.201

        ->

            64 bytes from 192.168.140.201: icmp_seq=1 ttl=64 time=0.205 ms
            64 bytes from 192.168.140.201: icmp_seq=2 ttl=64 time=0.050 ms
            64 bytes from 192.168.140.201: icmp_seq=3 ttl=64 time=0.045 ms

            3 packets transmitted, 3 received, 0% packet loss, time 2000ms

    容器可以 ping 与宿主机同一局域网的主机，输入命令：

        docker exec -it centos1 ping 192.168.140.202

        ->

            64 bytes from 192.168.140.202: icmp_seq=1 ttl=63 time=0.981 ms
            64 bytes from 192.168.140.202: icmp_seq=2 ttl=63 time=0.308 ms
            64 bytes from 192.168.140.202: icmp_seq=3 ttl=63 time=0.283 ms

            3 packets transmitted, 3 received, 0% packet loss, time 2002ms

    容器可以 ping 宿主机能访问的互联网，输入命令：

        docker exec -it centos1 ping www.baidu.com

        ->

            64 bytes from 14.215.177.38 (14.215.177.38): icmp_seq=1 ttl=127 time=11.7 ms
            64 bytes from 14.215.177.38 (14.215.177.38): icmp_seq=2 ttl=127 time=10.3 ms
            64 bytes from 14.215.177.38 (14.215.177.38): icmp_seq=3 ttl=127 time=11.0 ms

            3 packets transmitted, 3 received, 0% packet loss, time 2004ms

    因为容器都使用宿主机的网卡，同一宿主机的容器访问可以使用 localhost，可以跨主机访问其他容器，这里不做测试