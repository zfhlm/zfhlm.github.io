
#### 安装配置

    1，下载安装包

        文档地址：https://github.com/memcached/memcached/wiki/

        下载地址：http://memcached.org/downloads

        下载包：memcached-1.6.12.tar.gz

        上传到服务器目录：/usr/local/software

    2，编译安装

        输入命令：

            yum install -y gcc-c++

            yum install -y libevent libevent-devel

            cd /usr/local/software

            tar -zxvf ./memcached-1.6.12.tar.gz

            cd ./memcached-1.6.12

            ./configure --prefix=/usr/local/memcached

            make && make install

            cd ../

            rm -rf ./memcached-1.6.12

    3，启动服务

        输入命令：

            cd /usr/local/memcached

            ./bin/memcached  -d -m 500m -l 192.168.140.160 -p 11211 -c 1024 -u root

            ps aux | grep memcached

        以上命令，启动为守护进程，最大内容500MB，监听IP地址192.168.140.160，监听端口11211，最大连接数1024，以root用户启动
