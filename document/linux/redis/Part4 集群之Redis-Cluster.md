
# redis集群 Redis-Cluster 模式

### 服务器准备

    192.168.140.160        #redis 6379

    192.168.140.160        #redis 6380

    192.168.140.161        #redis 6379

    192.168.140.161        #redis 6380

    192.168.140.162        #redis 6379

    192.168.140.162        #redis 6380

    所有服务器配置好单点redis

### 各台服务器添加redis配置

    输入命令：

        cd /usr/local/redis

        cp ./redis.conf redis.6379.conf

        cp ./redis.conf redis.6380.conf

        vi redis.6379.conf

        =>

            port 6379

            dir "/usr/local/redis/data/6379/"

            pidfile /usr/local/redis/bin/6379.pid

            logfile /usr/local/redis/log/6379/redis.log

            cluster-enabled yes

            cluster-config-file /usr/local/redis/cluster/6379/redis.cfg

            cluster-node-timeout 10000

            appendonly yes

        vi redis.6380.conf

        =>

            port 6380
            
            dir "/usr/local/redis/data/6380/"

            pidfile /usr/local/redis/bin/6380.pid

            logfile /usr/local/redis/log/6380/redis.log

            cluster-enabled yes

            cluster-config-file /usr/local/redis/cluster/6380/redis.cfg

            cluster-node-timeout 10000

            appendonly yes

        mkdir -p /usr/local/redis/data/6379/

        mkdir -p /usr/local/redis/data/6380/

        mkdir -p /usr/local/redis/log/6379/

        mkdir -p /usr/local/redis/log/6380/

        mkdir -p /usr/local/redis/cluster/6379/

        mkdir -p /usr/local/redis/cluster/6380/

### 启动所有redis服务

    输入命令：

        cd /usr/local/redis

        ./bin/redis-server ./redis.6379.conf

        ./bin/redis-server ./redis.6380.conf

### 构建redis集群

    输入命令：

        cd /usr/local/redis

        ./bin/redis-cli --cluster create
            192.168.140.160:6379 192.168.140.160:6380
            192.168.140.161:6379 192.168.140.161:6380
            192.168.140.162:6379 192.168.140.162:6380
            --cluster-replicas 1

        ./bin/redis-cli --cluster check 192.168.140.160:6379

### 验证主从切换

    杀死某台服务器 redis 6379 进程，输入命令：

        ps -ef | grep redis

        kill pid

    查看集群状态，集群变成三主二从，输入命令：

        ./bin/redis-cli --cluster check 192.168.140.160:6380

    启动redis 6379 进程，并查看集群状态，可以看到集群回到三主三从，输入命令：

        ./bin/redis-server ./redis.6379.conf

        ./bin/redis-cli --cluster check 192.168.140.160:6380

### 使用 springboot 连接 Redis Cluster 集群

    配置文件 application.properties 示例：

        spring.redis.cluster.nodes=192.168.140.160:6379,192.168.140.160:6380,192.168.140.161:6379,192.168.140.161:6380,192.168.140.162:6379,192.168.140.162:6380
