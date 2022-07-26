
# Mysql 主从模式

  * 特别注意：

        ①，主从已建立，主节点创建业务数据库、业务账号、业务表，从节点无须再创建，账号信息会被复制到从节点

        ②，业务禁止使用管理员，read_only=0 对管理员账号无效，如果管理员在从节点新增数据，而主从单向复制，导致从节点比主节点多数据

### 一主多从模式(完整 binlog 日志)

  * 服务器准备( 安装配置好单点 Mysql 服务 )：

        192.168.140.136        # 主节点

        192.168.140.130        # 从节点

  * 主节点，更改 my.cnf 配置，输入命令：

        vi /etc/my.cnf

        =>

            [mysqld]

            server_id=136                                                   #服务器ID(注意保持唯一)
            read_only=0                                                     #开启只读

            #relay-log=mysql-relay-bin                                      #主从中继日志名称
            #relay_log_purge=1                                              #主从中继日志开启自动删除
            #relay_log_recovery=1                                           #主从中继日志损坏丢弃重新获取
            #max_relay_log_size=1024M                                       #主从中继日志文件最大值
            #log-slave-updates=1                                            #主从中继是否写入binlog

            #replicate-ignore-db=mysql                                      #主从忽略指定数据库
            #replicate-ignore-db=information_schema                         #主从忽略指定数据库
            #replicate-ignore-db=performance_schema                         #主从忽略指定数据库
            #replicate-ignore-db=sys                                        #主从忽略指定数据库
            #replicate-ignore-table=test.t_test1                            #主从忽略指定表
            #replicate-ignore-table=test.t_test2                            #主从忽略指定表
            #replicate-ignore-table=test.t_test3                            #主从忽略指定表
            #replicate-wild-ignore-table=test.%                             #主从忽略指定表(模糊)

  * 从节点，更改 my.cnf 配置，输入命令：

        vi /etc/my.cnf

        =>

            [mysqld]

            server_id=130                                                   #服务器ID(注意保持唯一)
            read_only=1                                                     #开启只读

            relay-log=mysql-relay-bin                                       #主从中继日志名称
            relay_log_purge=1                                               #主从中继日志开启自动删除
            relay_log_recovery=1                                            #主从中继日志损坏丢弃重新获取
            max_relay_log_size=1024M                                        #主从中继日志文件最大值
            log-slave-updates=1                                             #主从中继是否写入binlog

            replicate-ignore-db=mysql                                       #主从忽略指定数据库
            replicate-ignore-db=information_schema                          #主从忽略指定数据库
            replicate-ignore-db=performance_schema                          #主从忽略指定数据库
            replicate-ignore-db=sys                                         #主从忽略指定数据库
            #replicate-ignore-table=test.t_test1                            #主从忽略指定表
            #replicate-ignore-table=test.t_test2                            #主从忽略指定表
            #replicate-ignore-table=test.t_test3                            #主从忽略指定表
            #replicate-wild-ignore-table=test.%                             #主从忽略指定表(模糊)

  * 主节点，创建主从账号，输入命令：

        mysql -uroot -p

        GRANT REPLICATION SLAVE ON *.* TO 'replicator'@'%' IDENTIFIED BY '123456';

        FLUSH PRIVILEGES;

        exit;

  * 主节点，获取 binlog 信息，输入命令：

        mysql -uroot -p

        show master status\G

        ->

            *************************** 1. row ***************************
            File: mysql-bin.000002
            Position: 2461
            Binlog_Do_DB:
            Binlog_Ignore_DB: mysql,information_schema,performance_schema,sys
            Executed_Gtid_Set:
            1 row in set (0.00 sec)

  * 从节点，创建主从关联，输入命令：

        mysql -uroot -p

        # 注意参数，使用主节点的 binlog File Position 值
        change master to master_host='192.168.140.136', master_user='replicator', master_password='123456', master_log_file='mysql-bin.000002', master_log_pos=2461;

        start slave;

        show slave status\G

  * 主节点，查看主从连接信息：

        mysql -uroot -p

        show slave hosts;

        ->

            +-----------+------+------+-----------+--------------------------------------+
            | Server_id | Host | Port | Master_id | Slave_UUID                           |
            +-----------+------+------+-----------+--------------------------------------+
            |       130 |      | 3306 |         1 | 6311c01b-f233-11ec-9c8d-000c2917c917 |
            +-----------+------+------+-----------+--------------------------------------+
            1 row in set (0.00 sec)

  * 从节点，查看主从同步信息：

        mysql -uroot -p

        show slave status\G

        ->

            *************************** 1. row ***************************
            Slave_IO_State: Waiting for master to send event
            Master_Host: 192.168.140.136
            Master_User: replicator
            Master_Port: 3306
            Connect_Retry: 60
            Master_Log_File: mysql-bin.000002
            Read_Master_Log_Pos: 4186
            Relay_Log_File: mysql-relay-bin.000002
            Relay_Log_Pos: 2045
            Relay_Master_Log_File: mysql-bin.000002
            Slave_IO_Running: Yes
            Slave_SQL_Running: Yes
            Replicate_Do_DB:
            Replicate_Ignore_DB: mysql,information_schema,performance_schema,sys
            ......
            1 row in set (0.00 sec)

  * 从节点，关闭主从同步：

        mysql -uroot -p

        # 停止主从同步
        stop slave;

        # 清除主从配置信息
        reset slave all;

        show slave status\G

        ->

            Empty set (0.00 sec)

### 一主多从模式(不完整 binlog 日志)

  * 主节点，导出全量备份，并上传到从节点：

        cd /usr/local/backup

        mysqldump -uroot -p --flush-logs --databases test --single-transaction --master-data=1 > backup.test.sql

        scp -r ./backup.test.sql 192.168.140.130:/usr/local/backup

  * 从节点，导入备份备份：

        cd /usr/local/backup

        mysql < ./backup.test.sql

        # 获取当前备份的 binlog 偏移量
        head -100 ./backup.test.sql | grep 'CHANGE MASTER TO'

        ->

            CHANGE MASTER TO MASTER_LOG_FILE='mysql-bin.000010', MASTER_LOG_POS=2260;

  * 从节点，建立主从同步：

        # 注意修改  MASTER_LOG_FILE 和 MASTER_LOG_POS
        change master to master_host='192.168.140.136', master_user='replicator', master_password='123456', master_log_file='mysql-bin.000010', master_log_pos=2260;

        start slave;

        show slave status\G

### 双主互从模式

  * 与一主多从模式类似(假设 A 和 B 两个节点)：

        ①，A 和 B 节点配置 read_only=0

        ②，将 A 节点配置为 B 节点的从节点

        ③，再将 B 节点配置为 A 节点的从节点

  * 注意事项：

        ①，虽然双主都允许写入数据，但是为了保证数据的一致性，只允许写入一个主节点，另一个主节点可承担部分读请求

        ②，可以搭配 keepalived + VIP 的方式，主节点 down 掉后转移 VIP 到另一个主节点，继续提供服务，可能会丢失少量未同步数据

### 半同步复制

  * 半同步复制：

        ①，默认 Mysql 使用 异步复制，主库在执行完客户端提交的事务后会立即将结果返给给客户端，并不关心从库是否已经接收并处理

        ②，半同步复制：主库在执行完客户端提交的事务后不是立刻返回给客户端，而是等待至少一个从库接收到并写到 relay log 中才返回给客户端

        ③，当半同步复制发生超时，会暂时关闭半同步复制，转而使用异步复制；当主库发送玩一个事务的所有事件后收到了从库的响应，则主从又重新恢复为半同步复制

  * 开启半同步复制，主从节点都更改 my.cnf 配置：

        vi /etc/my.cnf

        =>

            [mysqld]

            plugin_load="rpl_semi_sync_master=semisync_master.so;rpl_semi_sync_slave=semisync_slave.so"
            loose-rpl_semi_sync_master_enabled=1                            #开启主节点半同步复制
            loose-rpl_semi_sync_slave_enabled=1                             #开启从节点半同步复制
            loose-rpl_semi_sync_master_timeout=5000                         #半同步复制等待超时时间(超时退化为异步复制)

        service mysqld restart

        tail -f /usr/local/mysql/log/mysql.log

        ->

            Start semi-sync binlog_dump to slave ......
            ...
            Start semi-sync replication to master ......

### binlog GTID

  * 主从节点更改 my.cnf 配置 ( GTID binlog 格式必须为 ROW )：

        vi /etc/my.cnf

        =>

            gtid_mode=ON                                                    #开启GTID
            enforce_gtid_consistency=ON                                     #开启GTID强一致性事务

        service mysqld restart

  * 从节点建立主从，使用如下语句：

        # 注意，binlog 不完整的情况下，必须先备份导入从库

        # 自动处理 binlog 偏移量
        change master to master_host='192.168.140.136', master_user='replicator', master_password='123456',master_auto_position = 1;

        start slave;

### 示例配置文件

  * 按实际情况调整相关配置：

        [client]

        port=3306                                                       #连接端口
        default_character_set=utf8mb4                                   #客户端默认字符集

        [mysqld_safe]

        log_error=/usr/local/mysql/log/mysql.log                        #错误日志位置

        [mysqld]

        basedir=/usr/local/mysql/                                       #安装目录
        datadir=/usr/local/mysql/data                                   #存储目录
        socket=/tmp/mysql.sock                                          #套接字文件位置

        user=mysql                                                      #启动用户
        server_id=136                                                   #服务器ID
        read_only=0                                                     #是否开启只读
        symbolic_links=0                                                #是否允许分区存储
        lower_case_table_names=1                                        #是否表名不区别大小写
        explicit_defaults_for_timestamp=1                               #是否允许日期自动填充
        open_files_limit=4096                                           #打开文件句柄最大数
        character_set_server=utf8mb4                                    #默认字符集
        collation_server=utf8mb4_general_ci                             #默认字符集排序规则
        default_storage_engine=INNODB                                   #默认存储引擎
        skip_name_resolve                                               #禁止DNS解析
        back_log=128                                                    #最大等待连接数
        max_connections=1000                                            #最大连接数
        max_connect_errors=5000                                         #最大错误连接次数
        transaction_isolation=REPEATABLE-READ                           #事务隔离级别
        max_allowed_packet=10M                                          #最大SQL数据包
        interactive_timeout=7200                                        #交互连接最大等待时间
        wait_timeout=7200                                               #非交互连接最大等待时间
        log_slow_admin_statements=ON                                    #是否记录管理日志

        log_bin=mysql-bin                                               #binlog日志名称
        binlog_format=ROW                                               #binlog格式
        sync_binlog=0                                                   #binlog是否每次刷盘
        expire_logs_days=7                                              #binlog过期天数
        max_binlog_size=1024M                                           #binlog文件最大值
        binlog_cache_size=1M                                            #binlog缓存大小
        binlog_ignore_db=mysql                                          #binlog忽略指定数据库
        binlog_ignore_db=information_schema                             #binlog忽略指定数据库
        binlog_ignore_db=performance_schema                             #binlog忽略指定数据库
        binlog_ignore_db=sys                                            #binlog忽略指定数据库

        slow_query_log=ON                                               #慢查询日志是否开启
        slow_query_log_file=/usr/local/mysql/log/mysql-slow.log         #慢查询日志文件
        long_query_time=2                                               #慢查询最小时间秒

        innodb_open_files=4096                                          #innodb打开文件句柄最大数
        innodb_buffer_pool_size=512M                                    #innodb缓冲池大小，根据服务器内存分配设置
        innodb_buffer_pool_chunk_size=128M                              #innodb缓冲池每次增减大小
        innodb_buffer_pool_instances=1                                  #innodb缓冲池数量，一般划分1G以上缓冲区对应一个缓冲池
        innodb_buffer_pool_dump_at_shutdown=1                           #innodb关闭时记录缓冲页面
        innodb_buffer_pool_load_at_startup=1                            #innodb启动时加载缓冲页面
        innodb_log_file_size=256M                                       #innodb事务日志大小
        innodb_flush_log_at_trx_commit=1                                #innodb事务日志刷盘策略
        innodb_flush_method=O_DIRECT                                    #innodb磁盘读写模式
        innodb_print_all_deadlocks=1                                    #innodb输出死锁日志

        #gtid_mode=ON                                                    #开启GTID
        #enforce_gtid_consistency=ON                                     #开启GTID强一致性事务

        #relay-log=mysql-relay-bin                                      #主从中继日志名称
        #relay_log_purge=1                                              #主从中继日志开启自动删除
        #relay_log_recovery=1                                           #主从中继日志损坏丢弃重新获取
        #max_relay_log_size=1024M                                       #主从中继日志文件最大值
        #log-slave-updates=1                                            #主从中继是否写入binlog

        #replicate-ignore-db=mysql                                      #主从忽略指定数据库
        #replicate-ignore-db=information_schema                         #主从忽略指定数据库
        #replicate-ignore-db=performance_schema                         #主从忽略指定数据库
        #replicate-ignore-db=sys                                        #主从忽略指定数据库
        #replicate-ignore-table=test.t_test1                            #主从忽略指定表
        #replicate-ignore-table=test.t_test2                            #主从忽略指定表
        #replicate-ignore-table=test.t_test3                            #主从忽略指定表
        #replicate-wild-ignore-table=test.%                             #主从忽略指定表(模糊)

        #plugin_load="rpl_semi_sync_master=semisync_master.so;rpl_semi_sync_slave=semisync_slave.so"
        #loose-rpl_semi_sync_master_enabled=1                            #开启主节点半同步复制
        #loose-rpl_semi_sync_slave_enabled=1                             #开启从节点半同步复制
        #loose-rpl_semi_sync_master_timeout=5000                         #半同步复制等待超时时间(超时退化为异步复制)
