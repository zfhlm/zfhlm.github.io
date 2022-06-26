
# redis集群 Codis

### 服务器准备

    192.168.140.160        # codis-server 服务器一，6379/6380两个进程

    192.168.140.161        # codis-server 服务器二，6379/6380两个进程

    192.168.140.162        # codis-server 服务器三，6379/6380两个进程

    192.168.140.160        # redis-sentinel 服务器一

    192.168.140.161        # redis-sentinel 服务器二

    192.168.140.162        # redis-sentinel 服务器三

    192.168.140.160        # codis-proxy 服务器一

    192.168.140.161        # codis-proxy 服务器二

    192.168.140.162        # codis-proxy 服务器三

    192.168.140.160        # zookeeper 集群服务器一

    192.168.140.161        # zookeeper 集群服务器二

    192.168.140.162        # zookeeper 集群服务器三

    192.168.140.163        # codis-dashboard 服务器

    192.168.140.163        # codis-fe 服务器

### 各个组件简单介绍

    codis-server： codis基于redis的分支，增加了额外的数据结构，以支持 slot 有关的操作以及数据迁移指令

    redis-sentinel：用于codis-server的主从切换，保证主从高可用

    codis-proxy：客户端连接的 Redis 代理服务，实现了大多数 Redis 协议，多个 codis-proxy 一般使用 lvs+keepalived 进行高可用负载均衡

    zookeeper：集群状态外部存储

    codis-dashboard：集群管理服务

    codis-fe：集群可视化管理界面服务

### 所有服务器，配置 golang 运行环境

    输入命令：

        cd /usr/local/software

        curl https://studygolang.com/dl

        wget https://dl.google.com/go/go1.11.1.linux-amd64.tar.gz

        tar -zxvf ./go1.11.1.linux-amd64.tar.gz

        mv ./go ..

        mkdir -p /usr/local/progress/src

        mkdir -p /usr/local/progress/bin

        mkdir -p /usr/local/progress/pkg

        vi /etc/profile

        =>

            export GOROOT=/usr/local/go

            export GOPATH=/usr/local/progress

            export PATH=$PATH:/usr/local/go/bin:/usr/local/progress/bin

        source /etc/profile

        go version

### 所有服务器，编译codis

    输入命令：

        cd /usr/local/software

        wget -O codis-3.2.2.tar.gz https://codeload.github.com/CodisLabs/codis/tar.gz/refs/tags/3.2.2

        mkdir -p $GOPATH/src/github.com/CodisLabs

        cd $GOPATH/src/github.com/CodisLabs

        tar -zxvf /usr/local/software/codis-3.2.2.tar.gz -C ./

        mv ./codis-3.2.2 codis

        cd ./codis

        yum install -y autoconf

        make

### 所有服务器，配置 codis 安装目录

    输入命令：

        mkdir -p /usr/local/codis/conf

        mkdir -p /usr/local/codis/log/

        mkdir -p /usr/local/codis/data/6379/

        mkdir -p /usr/local/codis/data/6380/

        cd $GOPATH/src/github.com/CodisLabs/codis

        cp ./bin -r /usr/local/codis/

        cp ./config/* -r /usr/local/codis/conf/

### 三台zookeeper服务器

    安装和配置jdk1.8

    安装和配置zookeeper三节点集群

### 单台 codis-dashboard 服务器，启动一个 codis-dashboard

    注意集群环境中最多只能存在一个

    输入命令：

        cd /usr/local/codis

        ./bin/codis-dashboard -h

        ./bin/codis-dashboard --default-conifg | tee ./conf/dashboard.conf

        vim ./conf/dashboard.conf

        =>

            product_name = "mrh-codis"

            product_auth = ""

            coordinator_name = "zookeeper"

            coordinator_addr = "192.168.140.160:2181,192.168.140.161:2181,192.168.140.162:2181"

            admin_addr = "192.168.140.163:18080"

        nohup ./bin/codis-dashboard --config=conf/dashboard.conf --log=log/dashboard.log --log-level=WARN &

        ps -ef | grep codis-dashboard

        tail -f ./log/dashboard.log

### 三台 codis-server 服务器，启动 codis-server

    输入命令：

        cd /usr/local/codis/conf

        cp redis.conf redis-6379.conf

        cp redis.conf redis-6380.conf

        vi redis-6379.conf

        =>

            port 6379

            pidfile /usr/local/codis/bin/6379.pid

            logfile "/usr/local/codis/log/6379.log"

            dir /usr/local/codis/data/6379/

            appendonly yes

        vi redis-6380.conf

        =>

            port 6380

            pidfile /usr/local/codis/bin/6380.pid

            logfile "/usr/local/codis/log/6380.log"

            dir /usr/local/codis/data/6380/

            appendonly yes

        cd /usr/local/codis

        ./bin/codis-server -h

        ./bin/codis-server conf/redis-6379.conf

        ./bin/codis-server conf/redis-6380.conf

        ps -ef | grep codis-server

### 三台 redis-sentinel 服务器，启动 redis-sentinel

    注意，不用配置 sentinel monitor 参数，将监控的主导权交给 codis

    输入命令：

        cd /usr/local/codis

        vi ./conf/sentinel.conf

        =>

            protected-mode no

            port 26379

            dir "/usr/local/codis/data"

        nohup ./bin/redis-sentinel conf/sentinel.conf &

        ps -ef | grep redis-sentinel

### 三台 codis-proxy 服务器，启动 codis-proxy

    输入命令：

        cd /usr/local/codis

        ./bin/codis-proxy -h

        ./bin/codis-proxy --default-config | tee ./conf/proxy.conf

        vi ./conf/proxy.conf

        =>

            product_name = "mrh-codis"

            product_auth = ""

            admin_addr = "0.0.0.0:18090"

            proto_type = "tcp4"

            proxy_addr = "0.0.0.0:16379"

            jodis_name = "zookeeper"

            jodis_addr = "192.168.140.160:2181,192.168.140.161:2181,192.168.140.162:2181"

            jodis_compatible = true

        nohup ./bin/codis-proxy --config=conf/proxy.conf --log=log/proxy.log --log-level=WARN &

        ps -ef | grep codis-proxy

        tail -f log/proxy.log

### 单台 codis-fe 服务器，启动 codis-fe

    输入命令：

        cd /usr/local/codis

        ./bin/codis-fe -h

        ./bin/codis-admin --dashboard-list --zookeeper=192.168.140.160:2181,192.168.140.161:2181,192.168.140.162:2181 | tee ./conf/codis.json

        nohup ./bin/codis-fe --ncpu=1 --log=log/fe.log --log-level=WARN --dashboard-list=conf/codis.json --listen=192.168.140.163:8080 &

        ps -ef | grep codis-fe

### 使用可视化界面，配置 codis 集群

    使用浏览器访问 codis-fe 管理后台地址 http://192.168.140.163:8080/，点开 mrh-codis 进行配置

    添加 Proxy 配置，加入以下三个节点：

        192.168.140.160:18090

        192.168.140.161:18090

        192.168.140.162:18090

    添加 Server 配置，创建三对主从：

        Group 1

            192.168.140.160:6379

            192.168.140.161:6380

        Group 2

            192.168.140.161:6379

            192.168.140.162:6380

        Group 3

            192.168.140.162:6379

            192.168.140.160:6380

    添加 Sentinel 配置，加入以下三个节点：

        192.168.140.160:26379

        192.168.140.161:26379

        192.168.140.162:26379

    分配 Slots，点击 Rebalance All slots，分配hash槽

### 使用 springboot 连接 codis

    application.properties配置：

        spring.redis.host=192.168.140.160

        spring.redis.port=16379

    代码示例：

        @Autowired
        private StringRedisTemplate redisTemplate;

        @GetMapping(path="/")
        @ResponseBody
        public String index() {

            String key = UUID.randomUUID().toString();

            redisTemplate.opsForValue().set(key, "1");

            System.out.println(key + " : " + redisTemplate.opsForValue().get(key));

            return "success";
        }
