
# Redis单点配置

### 第一步，下载安装包

    官方文档：https://redis.io/documentation

    下载地址：https://redis.io/download

    下载包：redis-6.2.6.tar.gz

    上传到服务器目录：/usr/local/software

### 第二步，编译安装

    输入命令：

        cd /usr/local/software

        tar -zxvf ./redis-6.2.6.tar.gz

        cd ./redis-6.2.6

        make PREFIX=/usr/local/redis install

        cp ./redis.conf /usr/local/redis/

        cp ./sentinel.conf /usr/local/redis/

        cd ..

        rm -rf redis-6.2.6

### 第三步，修改redis配置文件

    输入命令：

        cd /usr/local/redis

        vi redis.conf

        =>

            bind 127.0.0.1  192.168.140.160                    #监听主机地址

            port 6379                                          #监听端口

            requirepass 123456                                 #配置使用密码

            daemonize yes                                      #启用守护进程

            maxclients 10000                                   #最大客户端连接数

            pidfile /usr/local/redis/bin/6379.pid              #指定PID文件

            loglevel notice                                    #日志级别

            logfile /usr/local/redis/logs/redis.log            #日志位置

            dir "/usr/local/redis/data"                        #本地数据库存放目录

            maxmemory 4GB                                      #最大内存占用 4G，按实际情况定义

            maxmemory-policy volatile-lru                      #最大内存上限缓存淘汰策略

            activerehashing yes                                #是否激活重置哈希

            dbfilename dump.rdb                                #RDB配置，文件名

            rdbcompression yes                                 #RDB配置，是否启用压缩

            save 900 1                                         #RDB配置，每900秒至少有1个key发生变化，dump内存快照

            save 300 10                                        #RDB配置，每300秒至少有10个key发生变化，dump内存快照

            save 60 10000                                      #RDB配置，每60秒至少有10000个key发生变化，dump内存快照

            appendonly yes                                     #AOF配置，是否开启AOF持久化

            appendfilename "appendonly.aof"                    #AOF配置，AOF日志文件名

            appendfsync everysec                               #AOF配置，每次有数据变动写入AOF文件，可选值 always/everysec/no

            auto-aof-rewrite-min-size 128MB                    #AOF配置，AOF达到指定文件大小才进行rewrite

            slowlog-log-slower-than 2000                       #慢查询日志，超过多少微秒记录

            slowlog-max-len 1024                               #慢查询日志，最多能保存多少条

### 第四步，启动redis

    输入命令：

        cd /usr/local/redis

        ./bin/redis-server ./redis.conf
