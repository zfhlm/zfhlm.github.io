
# redis集群 Twemproxy

### 服务器准备

    192.168.140.160        # redis 服务器一，端口6379

    192.168.140.161        # redis 服务器二，端口6379

    192.168.140.162        # redis 服务器三，端口6379

    192.168.140.163        # Twemproxy服务器

### 下载安装包

    官方文档地址：https://github.com/twitter/twemproxy

    下载地址：https://github.com/twitter/twemproxy/releases

    下载安装包：twemproxy-0.5.0.tar.gz

    上传到服务器目录：/usr/local/software

### 编译 twemproxy

    输入命令：

        cd /usr/local/software

        tar -zxvf twemproxy-0.5.0.tar.gz

        cd twemproxy-0.5.0

        yum install -y gcc-c++

        ./configure --prefix=/usr/local/twemproxy/

        make && make install

        cd ..

        rm -rf ./twemproxy-0.5.0

### 配置 twemproxy 代理规则

    输入命令：

        cd /usr/local/twemproxy

        mkdir conf

        mkdir logs

        vi ./conf/nutcracker.yml

        =>

            beta:
              listen: 192.168.140.163:6379
              hash: fnv1a_64
              distribution: ketama
              tcpkeepalive: true
              redis: true
              auto_eject_hosts: true
              server_retry_timeout: 2000
              server_failure_limit: 3
              servers:
               - 192.168.140.160:6379:1
               - 192.168.140.161:6379:1
               - 192.168.140.162:6379:1

        ./sbin/nutcracker -h

        ./sbin/nutcracker -t -c ./conf/nutcracker.yml

        ./sbin/nutcracker -d -c ./conf/nutcracker.yml -p ./sbin/twemproxy.pid -o  ./logs/twemproxy.log

### 连接客户端

    客户端创建连接，直连 twemproxy 代理的 IP 和 port 即可
