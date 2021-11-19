
#### DR模式

    1，环境说明

        192.168.140.1           #客户端

        10.1.125.200            #VIP地址

        10.1.125.151            #centos7 LVS服务器(安装ipvsadm)

        10.1.125.152            #centos7 真实服务器一

        10.1.125.153            #centos7 真实服务器二

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
