
# Mysql 单点配置

### 安装并初始化

  * 下载安装包：

        官网地址：https://www.mysql.com/

        下载地址：https://downloads.mysql.com/archives/community/

        安装包：Compressed TAR Archive mysql-5.7.35-linux-glibc2.12-x86_64.tar.gz

  * 解压安装包，输入命令：

        yum -y remove mariadb*

        cd /usr/loca/software

        tar -zxvf ./mysql-5.7.35-linux-glibc2.12-x86_64.tar.gz

        mv mysql-5.7.35-linux-glibc2.12-x86_64 ../mysql-5.7.35

        cd ..

        ln -s mysql-5.7.35 mysql

  * 创建数据库服务器账号，输入命令：

        groupadd mysql

        useradd -r -s /sbin/nologin -g mysql mysql -d /usr/local/mysql/

        chown -R mysql:mysql /usr/local/mysql

        chown -R mysql:mysql /usr/local/mysql/

  * 更改数据库运行参数，输入命令：

        cd /usr/local/mysql

        mkdir log && touch ./log/mysql.log

        chown -R mysql:mysql ./log

        vi /etc/my.cnf

        =>

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
            server_id=1                                                     #服务器ID
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

  * 初始化并启动数据库，输入命令：

        cd /usr/local/mysql

        # 执行完毕控制台会输出初始密码，需要记住密码文本
        ./bin/mysqld --initialize --user=mysql --basedir=/usr/local/mysql/ --datadir=/usr/local/mysql/data/

        cp -a ./support-files/mysql.server /etc/init.d/mysqld

        service mysqld start

  * 配置数据库环境变量，输入命令：

        vi /etc/profile

        =>

            export MYSQL_HOME="/usr/local/mysql/"
            export PATH="$PATH:$MYSQL_HOME/bin"

        source /etc/profile

  * 初始化超级管理员账号，输入命令：

        # 初始化登录，使用控制台输出的初始密码登录
        mysql -uroot -p

        set PASSWORD = PASSWORD('123456');

        update mysql.user set host='%' where user='root';

        grant all privileges on *.* to 'root'@'%' identified by '123456' with grant option;

        flush privileges;

### 创建并授权账号

  * 查看数据库所有权限信息，输入命令：

        mysql -uroot -p

        SHOW PRIVILEGES;

        ->

            +-------------------------+---------------------------------------+-------------------------------------------------------+
            | Privilege               | Context                               | Comment                                               |
            +-------------------------+---------------------------------------+-------------------------------------------------------+
            | Alter                   | Tables                                | To alter the table                                    |
            | Alter routine           | Functions,Procedures                  | To alter or drop stored functions/procedures          |
            | Create                  | Databases,Tables,Indexes              | To create new databases and tables                    |
            | Create routine          | Databases                             | To use CREATE FUNCTION/PROCEDURE                      |
            | Create temporary tables | Databases                             | To use CREATE TEMPORARY TABLE                         |
            | Create view             | Tables                                | To create new views                                   |
            | Create user             | Server Admin                          | To create new users                                   |
            | Delete                  | Tables                                | To delete existing rows                               |
            | Drop                    | Databases,Tables                      | To drop databases, tables, and views                  |
            | Event                   | Server Admin                          | To create, alter, drop and execute events             |
            | Execute                 | Functions,Procedures                  | To execute stored routines                            |
            | File                    | File access on server                 | To read and write files on the server                 |
            | Grant option            | Databases,Tables,Functions,Procedures | To give to other users those privileges you possess   |
            | Index                   | Tables                                | To create or drop indexes                             |
            | Insert                  | Tables                                | To insert data into tables                            |
            | Lock tables             | Databases                             | To use LOCK TABLES (together with SELECT privilege)   |
            | Process                 | Server Admin                          | To view the plain text of currently executing queries |
            | Proxy                   | Server Admin                          | To make proxy user possible                           |
            | References              | Databases,Tables                      | To have references on tables                          |
            | Reload                  | Server Admin                          | To reload or refresh tables, logs and privileges      |
            | Replication client      | Server Admin                          | To ask where the slave or master servers are          |
            | Replication slave       | Server Admin                          | To read binary log events from the master             |
            | Select                  | Tables                                | To retrieve rows from table                           |
            | Show databases          | Server Admin                          | To see all databases with SHOW DATABASES              |
            | Show view               | Tables                                | To see views with SHOW CREATE VIEW                    |
            | Shutdown                | Server Admin                          | To shut down the server                               |
            | Super                   | Server Admin                          | To use KILL thread, SET GLOBAL, CHANGE MASTER, etc.   |
            | Trigger                 | Tables                                | To use triggers                                       |
            | Create tablespace       | Server Admin                          | To create/alter/drop tablespaces                      |
            | Update                  | Tables                                | To update existing rows                               |
            | Usage                   | Server Admin                          | No privileges - allow connect only                    |
            +-------------------------+---------------------------------------+-------------------------------------------------------+

  * 创建账号并授权，常见语句：

        # 创建一个所有权限的账号admin，允许访问所有数据库，允许该账户授权给其他用户
        GRANT ALL PRIVILEGES ON *.* TO 'admin'@'%' IDENTIFIED BY '123456' WITH GRANT OPTION;

        # 创建一个指定权限的账号test，只允许访问数据库test
        GRANT SELECT, UPDATE, INSERT, DELETE, CREATE, ALTER, DROP, INDEX, EXECUTE, CREATE VIEW, SHOW VIEW on test.* TO 'test'@'%' IDENTIFIED BY '123456';

        FLUSH PRIVILEGES;
