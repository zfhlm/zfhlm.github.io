
# PostgreSQL 单点配置

### 下载安装包

  * 基于源码包进行编译安装：

        文档地址：https://www.postgresql.org/docs/current/installation.html

        下载地址：https://www.postgresql.org/ftp/source/v14.4/

  * 下载安装包，输入命令：

        cd /usr/local/software

        wget https://ftp.postgresql.org/pub/source/v14.4/postgresql-14.4.tar.gz

### 解压与配置

  * 安装依赖，输入命令：

        su - root

        yum -y install gcc-c++ readline-devel perl-ExtUtils-Embed zlib-devel python-devel

  * 编译安装，输入命令：

        su - root

        cd /usr/local/software

        tar -zxvf postgresql-14.4.tar.gz

        cd postgresql-14.4

        ./configure --prefix=/usr/local/postgresql --with-perl --with-python

        make & make install

  * 配置环境变量，输入命令：

        su - root

        vi /etc/profile

        =>

            export PGHOME=/usr/local/postgresql
            export PATH=$PATH:$PGHOME/bin

        source /etc/profile

  * 创建启动用户，输入命令：

        su - root

        useradd postgresql

        chown -R postgresql:postgresql /usr/local/postgresql

  * 初始化数据库，输入命令：

        su - postgresql

        cd /usr/local/postgresql

        ./bin/initdb -D /usr/local/postgresql/data

  * 修改数据库配置文件，输入命令：

        su - postgresql

        cd /usr/local/postgresql/data

        vi postgresql.conf

        =>

            #------------------------------------------------------------------------------
            # CUSTOMIZED OPTIONS
            #------------------------------------------------------------------------------

            # Add settings for extensions here

            # 监听IP地址
            listen_addresses = '*'

            # 监听端口号
            port = 5432

            # 最大客户端连接数
            max_connections = 500

            # 预留给超级用户连接数
            superuser_reserved_connections = 15

            # 强制把数据同步更新到磁盘
            fsync = on

            # 强制提交等待刷盘
            synchronous_commit = on

            # 内存缓冲区大小
            shared_buffers = 256MB

            # 磁盘高速缓存的内存量预估值
            effective_cache_size = 512MB

            # 连接会话使用内存大小
            work_mem = 4MB

            # 维护任务使用内存大小
            maintenance_work_mem = 64MB

  * 开启密码认证和远程连接，输入命令：

        su - postgresql

        cd /usr/local/postgresql

        vi data/pg_hba.conf

        =>

            host    all             all             0.0.0.0/0               password

  * 启动数据库，输入命令：

        su - postgresql

        cd /usr/local/postgresql

        ./bin/pg_ctl -D /usr/local/postgresql/data start

  * 进入 psql 控制台修改密码，输入命令：

        su - postgresql

        psql template1

        select datname from pg_database;

        ->

            datname  
            -----------
            postgres
            template1
            template0
            (3 rows)

        exit

        psql -U postgresql -d postgres

        alter user postgresql with password '123456';

        exit

  * 配置到系统服务，输入命令：

        su - root

        vi /etc/systemd/system/postgresql.service

        =>

            [Unit]
            Description=postgresql
            Wants=network-online.target

            [Service]
            Type=forking
            User=postgresql
            Group=postgresql
            ExecStart=/usr/local/postgresql/bin/pg_ctl -D /usr/local/postgresql/data start
            ExecReload=/usr/local/postgresql/bin/pg_ctl -D /usr/local/postgresql/data reload
            ExecStop=/usr/local/postgresql/bin/pg_ctl -D /usr/local/postgresql/data stop
            Restart=always
            RestartSec=10s

            [Install]
            WantedBy=multi-user.target

        systemctl daemon-reload

        systemctl start postgresql

        systemctl stop postgresql

        # 开机启动
        # systemctl enable postgresql

### 可视化客户端 navicat

  * 下载并安装客户端，地址：

        http://www.navicat.com.cn/download/navicat-for-postgresql

  * 打开 navicat 新建连接，填写以下信息：

        连接名：192.168.140.133

        主机：192.168.140.133

        端口：5432

        初始数据库：postgres

        用户名：postgresql

        密码：123456

  * 点击【测试连接】，成功后点击【确定】，至此完成客户端配置
