
# mysql集群一主多从

#### 服务器准备

    192.168.140.164        # mysql主节点

    192.168.140.165        # mysql从节点一

    192.168.140.166        # mysql从节点二

    (根据 Part01 安装配置好三台服务器)

#### 修改 mysql 配置

    从节点修改配置，输入命令：

        vi /etc/my.cnf

    添加以下配置：

        [mysqld]

        read_only=1                                                     #开启只读

        relay-log=mysql-relay-bin                                       #主从中继日志名称
        relay_log_purge=1                                               #主从中继日志开启自动删除
        relay_log_recovery=1                                            #主从中继日志损坏丢弃重新获取
        max_relay_log_size=1024M                                        #主从中继日志文件最大值
        log-slave-updates=1                                             #主从复制是否写入binlog

#### 创建 mysql 主从账号

    主节点创建主从账号，输入命令：

        mysql -uroot -p

        GRANT REPLICATION SLAVE ON *.* TO 'replicator'@'%' IDENTIFIED BY '123456';

        FLUSH PRIVILEGES;

#### 开启 mysql 主从复制

    主节点获取binlog信息，输入命令：

        mysql -uroot -p

        show master status\G

        -> 输入信息例如：
        ->        File: mysql-bin.000016
        ->        Position: 1113
        -> 两个值在创建主从时作为参数值使用

    从节点创建主从关联，输入命令：

        mysql -uroot -p

        change master to master_host='192.168.140.164', master_user='replicator', master_password='123456', master_log_file='mysql-bin.000016', master_log_pos=1113;

        start slave;

        show slave status\G

#### 创建 mysql 客户端账号

    原则上禁止超级管理员账号操作主从数据库，而应该创建指定权限的普通账号给客户端使用：

        数据库配置的 read_only 属性不能对超级管理员账号生效，禁止使用超级管理员账号

        如果在从服务器新增数据，而主从节点单向复制，会导致从节点比主节点多数据

    主节点创建测试数据库，输入命令：

        mysql -uroot -p

        create database `test`;

    主节点创建普通账号，输入命令：

        GRANT SELECT, UPDATE, INSERT, DELETE, CREATE, ALTER, DROP, INDEX on test.* TO 'test'@'%' IDENTIFIED BY '123456';

        FLUSH PRIVILEGES;

    以上完成，从节点无须再创建，账号信息会被复制到从服务器

#### 使用客户端账号测试 mysql 主从同步

    主节点建库建表，输入命令：

        mysql -utest -p

        use `test`;

        create table `test_user` (`id` int(11) not null, `name` varchar(50) not null, primary key (`id`));

    主节点插入数据，输入命令：

        insert into `test_user` values ('1', '张三');

    从节点查询数据，输入命令：

        select * from `test_user` where `id` = 1;

    从节点插入数据，输入命令：

        # 会提示失败，因为数据只读不允许执行update操作
        insert into `test_user` values ('2', '李四');

#### 关闭 mysql 主从复制

    从节点暂时关闭，输入命令：

        mysql -uroot -p

        stop slave;

    从节点永久关闭，输入命令：

        mysql -uroot -p

        stop slave;

        reset master;

        reset slave all;

        show slave status\G

#### 添加 mysql 新从节点

    如果binlog完整的情况下，且数据量不多，可以直接建立主从同步

    使用 mysqldump 从主节点导出数据，输入命令：

        cd /usr/local/backup

        mysqldump -uroot -p --flush-logs --databases test --single-transaction --master-data=1 > backup.test.sql

        scp -r ./backup.test.sql 192.168.140.100:/usr/local/backup

    新节点导入备份数据，输入命令：

        cd /usr/local/backup

        head -100 ./backup.test.sql | grep 'CHANGE MASTER TO'

        -> 输出信息例如：CHANGE MASTER TO MASTER_LOG_FILE='mysql-bin.000010', MASTER_LOG_POS=2260;
        -> 新节点主从关联使用 MASTER_LOG_FILE 和 MASTER_LOG_POS 的值

        mysql < ./backup.test.sql

    新节点建立主从关联，输入命令：

        # 注意修改  MASTER_LOG_FILE 和 MASTER_LOG_POS 的值
        change master to master_host='192.168.140.164', master_user='replicator', master_password='123456', master_log_file='mysql-bin.000010', master_log_pos=2260;

        start slave;

        show slave status\G
