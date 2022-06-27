
# centos 防火墙 firewalld

#### 常用命令

    firewalld 启停，输入命令：

        systemctl start firewalld

        systemctl stop firewalld

        systemctl status firewalld

        systemctl enable firewalld

        systemctl disable firewalld

    firewalld 端口限制，输入命令：

        firewall-cmd --state

        firewall-cmd --list-all

        firewall-cmd --zone=public --add-port=80/tcp --permanent

        firewall-cmd --zone= public --remove-port=80/tcp --permanent

        firewall-cmd --reload
