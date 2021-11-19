
#### NAT模式

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
