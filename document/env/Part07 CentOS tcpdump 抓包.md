
# centos 网络抓包工具 tcpdump

### tcpdump

    安装 tcpdump，输入命令：

        yum install -y tcpdump

        # 显示命令帮助信息，所有参数都有说明
        man tcpdump

    简单的示例：

        tcpdump tcp port 80 -nn -vv

        tcpdump tcp port 80 -i ens33 -nn -vv
