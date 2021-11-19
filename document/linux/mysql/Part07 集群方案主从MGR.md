
# mysql集群 主从MGR

    MySQL Group Replication，组复制

    MGR 是MySQL官方在5.7.17版本引进的一个数据库高可用与高扩展的解决方案，以插件形式提供

    MGR 不是全同步方案MGR，相对于半同步复制，在relay log前增加了冲突检查协调，但是binlog回放仍然可能延时

    MGR 由 paxos 协议保证数据最终一致性，提交事务之前发送集群广播，只有获得一致性层同意之后才能提交事务

    MGR 单主模式，会自动选主，出现故障会自动进行主从切换和节点临时剔除，所有更新操作都在主上进行，客户端对主可读可写，对从只读

    MGR 多主模式，出现故障会自动进行节点临时剔除，客户端可以任意节点写入数据

    MGR 最少要3节点，一般添加为奇数个，最多只能存在9个节点

    注意，MGR 不是全同步复制，只保证数据最终一致性

#### 服务器准备

    192.168.140.164        # 服务器一，主节点

    192.168.140.165        # 服务器二，从节点

    192.168.140.166        # 服务器三，从节点

    根据 Part1 安装配置好三台服务器，搭建一主二从 MGR 集群

#### 修改服务器host配置

    修改host，输入命令：

        vi /etc/hosts

    添加以下配置：

        192.168.140.164 node164
        192.168.140.165 node165
        192.168.140.166 node166

    重启网络服务，输入命令：

        hostname

        service network restart

#### 添加 mysql MGR配置

    输入命令：

        vi /etc/my.cnf

    服务器一加入以下内容：

        [mysqld]

        log-bin=mysql-bin                                                                         #binlog日志名称
        binlog_format=ROW                                                                         #binlog格式
        binlog_checksum=NONE                                                                      #binlog关闭日志校验

        gtid_mode=ON                                                                              #开启全局事务GTID
        enforce_gtid_consistency=ON                                                               #开启全局事务强一致性
        master_info_repository=TABLE                                                              #使用表记录master信息
        relay_log_info_repository=TABLE                                                           #使用表记录中继日志信息
        transaction_write_set_extraction=XXHASH64                                                 #事务依赖关系算法
        loose-group_replication_group_name="d81fa4d2-9cd2-455d-bf97-2acd2a672543"                 #组名称
        loose-group_replication_local_address="node164:13306"                                     #本节点通讯地址
        loose-group_replication_group_seeds="node164:13306,node165:13306,node166:13306"           #全部节点通讯地址
        loose-group_replication_bootstrap_group=OFF                                               #关闭引导设置
        loose-group_replication_start_on_boot=OFF                                                 #关闭插件数据库启动时自启
        loose-group_replication_enforce_update_everywhere_checks=FALSE                            #关闭多主写验证
        loose-group_replication_single_primary_mode=ON                                            #启用单主模式

    服务器二加入以下内容：

        [mysqld]

        log-bin=mysql-bin                                                                         #binlog日志名称
        binlog_format=ROW                                                                         #binlog格式
        binlog_checksum=NONE                                                                      #binlog关闭日志校验

        gtid_mode=ON                                                                              #开启全局事务GTID
        enforce_gtid_consistency=ON                                                               #开启全局事务强一致性
        master_info_repository=TABLE                                                              #使用表记录master信息
        relay_log_info_repository=TABLE                                                           #使用表记录中继日志信息
        transaction_write_set_extraction=XXHASH64                                                 #事务依赖关系算法
        loose-group_replication_group_name="d81fa4d2-9cd2-455d-bf97-2acd2a672543"                 #组名称
        loose-group_replication_local_address="node165:13306"                                     #本节点通讯地址
        loose-group_replication_group_seeds="node164:13306,node165:13306,node166:13306"           #全部节点通讯地址
        loose-group_replication_bootstrap_group=OFF                                               #关闭引导设置
        loose-group_replication_start_on_boot=OFF                                                 #关闭插件数据库启动时自启
        loose-group_replication_enforce_update_everywhere_checks=FALSE                            #关闭多主写验证
        loose-group_replication_single_primary_mode=ON                                            #启用单主模式

    服务器三加入以下内容：

        [mysqld]

        log-bin=mysql-bin                                                                         #binlog日志名称
        binlog_format=ROW                                                                         #binlog格式
        binlog_checksum=NONE                                                                      #binlog关闭日志校验

        gtid_mode=ON                                                                              #开启全局事务GTID
        enforce_gtid_consistency=ON                                                               #开启全局事务强一致性
        master_info_repository=TABLE                                                              #使用表记录master信息
        relay_log_info_repository=TABLE                                                           #使用表记录中继日志信息
        transaction_write_set_extraction=XXHASH64                                                 #事务依赖关系算法
        loose-group_replication_group_name="d81fa4d2-9cd2-455d-bf97-2acd2a672543"                 #组名称
        loose-group_replication_local_address="node166:13306"                                     #本节点通讯地址
        loose-group_replication_group_seeds="node164:13306,node165:13306,node166:13306"           #全部节点通讯地址
        loose-group_replication_bootstrap_group=OFF                                               #关闭引导设置
        loose-group_replication_start_on_boot=OFF                                                 #关闭插件数据库启动时自启
        loose-group_replication_enforce_update_everywhere_checks=FALSE                            #关闭多主写验证
        loose-group_replication_single_primary_mode=ON                                            #启用单主模式

    重启数据库，输入命令：

        service mysqld restart

#### 安装 mysql MGR 插件

    输入命令：

        mysql -uroot -p

        INSTALL PLUGIN group_replication SONAME 'group_replication.so';

        SHOW PLUGINS;

#### mysql 创建 mysql MGR 账号

    输入命令：

        mysql -uroot -p

        GRANT REPLICATION SLAVE ON *.* TO 'replicator'@'%' IDENTIFIED BY '123456';

        flush privileges;

#### 任意一台服务器创建 mysql MGR 组

    输入命令：

        mysql -uroot -p

        SET GLOBAL group_replication_bootstrap_group=ON;

        CHANGE MASTER TO MASTER_USER='replicator',MASTER_PASSWORD='123456' FOR CHANNEL 'group_replication_recovery';

        START GROUP_REPLICATION;

        SET GLOBAL group_replication_bootstrap_group=OFF;

#### 其他两台服务器加入 mysql MGR 组

    输入命令：

        mysql -uroot -p

        CHANGE MASTER TO MASTER_USER='replicator',MASTER_PASSWORD='123456' FOR CHANNEL 'group_replication_recovery';

        START GROUP_REPLICATION;

        SELECT * FROM performance_schema.replication_group_members;

#### 测试 MGR 主从同步

    使用命令获取主节点信息，输入命令：

        mysql -uroot -p

        select * from performance_schema.replication_group_members;

        show variables like '%read_only%';

    主节点  mysql 建库建表并插入数据，输入命令：

        mysql -uroot -p

        CREATE DATABASE 'test2';

        use 'test2';

        CREATE TABLE `test_user` (
          `id` int(11) NOT NULL,
          `name` varchar(50) NOT NULL,
          PRIMARY KEY (`id`)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

        INSERT INTO `test_user` VALUES ('1', '张三');

    从节点查询数据，输入命令：

        mysql -uroot -p

        use 'test2';

        SELECT * FROM 'test2' WHERE `id` = 1;

#### 集群 MGR 关闭

    输入命令：

        mysql -uroot -p

        STOP GROUP_REPLICATION;

        RESET MASTER;

        RESET SLAVE ALL;

#### 集群 MGR 添加节点

    1，所有节点的 binlog 并集为所有记录的 binlog，跳到第4步

    2，所有节点的 binlog 并集都不完整，使用 mysqldump 导出全量数据备份：

        mysqldump -uroot -p --single-transaction --master-data=2 -R --default-character-set=utf8 --databases test test2 >  fullback.sql

    3，导入全量数据到新节点

        mysql -uroot -p < ./fullback.sql

    4，修改所有节点的配置文件，加入新节点配置，然后按照正常的流程添加节点到 MGR 集群

#### 集群 MGR 多主

    和搭建主从MGR一样的流程，只需更改 my.cnf 以下配置：

        loose-group_replication_enforce_update_everywhere_checks=TRUE       #启用多主写验证
        loose-group_replication_single_primary_mode=OFF                     #关闭单主模式
