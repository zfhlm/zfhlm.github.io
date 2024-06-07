
#### 单点配置

    1，下载 erlang 安装包

        访问地址：https://www.rabbitmq.com/news.html

        查看最新版本 RabbitMQ 3.9.7 release24 描述：This release requires Erlang/OTP 23.2 and supports Erlang 24.

        该安装包依赖 Erlang 23.2版本

        地址：https://www.erlang.org/downloads

        下载包：otp_src_23.2.tar.gz

        下载完成上传到服务器目录：/usr/local/software

    2，配置 erlang ，输入命令：

        yum -y install make gcc gcc-c++ kernel-devel m4 ncurses-devel openssl-devel

        yum -y install unixODBC-devel libtool libtool-ltdl-devel

        cd /usr/local/software

        tar -zxvf ./otp_src_23.2.tar.gz

        cd ./otp_src_23.2

        ./configure --prefix=/usr/local/erlang-23.2 --without-javac

        make && make install

        cd ..

        rm -rf ./otp_src_23.2

        cd /usr/local

        ln -s ./erlang-23.2 erlang

        vi /etc/profile

        =>

            export PATH=$PATH:/usr/local/erlang/bin

        source /etc/profile

        erl -version

        ->

            Erlang (SMP,ASYNC_THREADS,HIPE) (BEAM) emulator version 11.1.4

    3，下载 rabbitmq 安装包：

        地址：https://github.com/rabbitmq/rabbitmq-server/releases

        下载包：rabbitmq-server-generic-unix-3.9.7.tar.xz

        下载完成上传到服务器目录：/usr/local/software

    4，解压配置 rabbitmq，输入命令：

        cd /usr/local/software

        tar -xvf ./rabbitmq-server-generic-unix-3.9.7.tar.xz

        mv ./rabbitmq_server-3.9.7/ ../

        cd ..

        ln -s ./rabbitmq_server-3.9.7 rabbitmq

    5，启动与停止rabbitmq，输入命令：

        ./sbin/rabbitmq-server -detached

        ./sbin/rabbitmqctl stop

    6，添加rabbitmq用户，输入命令：

        ./sbin/rabbitmqctl add_user rabbitmq 123456

        ./sbin/rabbitmqctl set_user_tags rabbitmq administrator

        ./sbin/rabbitmqctl set_permissions -p / rabbitmq '.*' '.*' '.*'

    7，开启 rabbitmq web 管理界面，输入命令：

        ./sbin/rabbitmq-plugins enable rabbitmq_management

        访问管理界面，使用刚刚创建的rabbitmq账号登录：http://192.168.140.144:15672/

    8，下载并启用配置文件，输入命令：

        cd /usr/local/rabbitmq

        wget https://github.com/rabbitmq/rabbitmq-server/blob/v3.8.x/deps/rabbit/docs/rabbitmq.conf.example

        cp rabbitmq.conf.example rabbitmq.conf

        ./sbin/rabbitmqctl stop

        ./sbin/rabbitmq-server -detached

    9，安装 rabbitmq 插件

        假设需要安装延迟队列插件：rabbitmq_delayed_message_exchange

        访问地址获取插件下载相关信息：https://www.rabbitmq.com/community-plugins.html

        下载地址：https://github.com/rabbitmq/rabbitmq-delayed-message-exchange/releases

        下载文件：rabbitmq_delayed_message_exchange-3.9.0.ez

        下载完成上传到rabbitmq插件目录：/usr/local/rabbitmq/plugins

        启用 rabbitmq 插件，输入命令：

            cd /usr/local/rabbitmq

            ./sbin/rabbitmq-plugins enable rabbitmq_delayed_message_exchange

# 使用 RPM 安装

    1，下载安装包
    
        [RabbitMQ](https://github.com/rabbitmq/rabbitmq-server/releases)
        
        [erlang](https://github.com/rabbitmq/erlang-rpm/releases)

    2，安装 erlang
    
        yum install -y erlang-25.3.2.7-1.el9.x86_64.rpm
        
    3，安装 RabbitMQ
    
        （略）