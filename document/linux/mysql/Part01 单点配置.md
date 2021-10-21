
# mysql数据库单点配置

#### 下载安装包，相关信息：

	下载地址：https://downloads.mysql.com/archives/community/
	
	下载安装包：Compressed TAR Archive mysql-5.7.35-linux-glibc2.12-x86_64.tar.gz
	
	上传到服务器目录：/usr/local/software

#### 解压到安装目录，输入命令：

	rpm -qa | grep mariadb
	
	rpm -e --nodeps mariadb-libs-5.5.68-1.el7.x86_64
	
	cd /usr/loca/software
	
	tar -zxvf ./mysql-5.7.35-linux-glibc2.12-x86_64.tar.gz
	
	mv mysql-5.7.35-linux-glibc2.12-x86_64 ../mysql-5.7.35
	
	cd ..
	
	ln -s mysql-5.7.35 mysql

#### 配置数据库启动账号，输入命令：
	
	groupadd mysql
	
	useradd -r -s /sbin/nologin -g mysql mysql -d /usr/local/mysql/
	
	chown -R mysql:mysql /usr/local/mysql
	
	chown -R mysql:mysql /usr/local/mysql/

#### 配置数据库启动参数，输入命令：

	cd /usr/local/mysql
	
	mkdir log && touch ./log/mysql.log
	
	chown -R mysql:mysql ./log
	
	vi /ect/my.cnf
	
	添加以下配置：
		
		[client]
		
		port=3306                                                       #连接端口
		default-character-set=utf8mb4                                   #客户端默认字符集
		
		[mysqld_safe]
		
		log-error=/usr/local/mysql/log/mysql.log                        #错误日志位置
		
		[mysqld]
		
		basedir=/usr/local/mysql/                                       #安装目录
		datadir=/usr/local/mysql/data                                   #存储目录
		socket=/tmp/mysql.sock                                          #套接字文件位置
		
		user=mysql                                                      #启动用户
		server-id=1                                                     #服务器ID
		read_only=0                                                     #是否开启只读
		symbolic-links=0                                                #是否允许分区存储
		lower_case_table_names=1                                        #是否表名不区别大小写
		explicit_defaults_for_timestamp=1                               #是否允许日期自动填充
		open_files_limit=4096                                           #打开文件句柄最大数
		character_set_server=utf8mb4                                    #默认字符集
		collation_server=utf8mb4_general_ci                             #默认字符集排序规则
		default-storage-engine=INNODB                                   #默认存储引擎
		skip_name_resolve                                               #禁止DNS解析
		back_log=128                                                    #最大等待连接数
		max_connections=1000                                            #最大连接数
		max_connect_errors=5000                                         #最大错误连接次数
		transaction_isolation=REPEATABLE-READ                           #事务隔离级别
		max_allowed_packet=10M                                          #最大SQL数据包
		interactive_timeout=7200                                        #交互连接最大等待时间
		wait_timeout=7200                                               #非交互连接最大等待时间
		log_slow_admin_statements=ON                                    #是否记录管理日志
		
		innodb_open_files=4096                                          #innodb打开文件句柄最大数
		innodb_print_all_deadlocks=1                                    #innodb输出死锁日志
		
		log-bin=mysql-bin                                               #binlog日志名称
		binlog_format=ROW                                               #binlog格式
		sync_binlog=0                                                   #binlog是否每次刷盘
		expire_logs_days=7                                              #binlog过期天数
		max_binlog_size=1024M                                           #binlog文件最大值
		binlog_cache_size=1M                                            #binlog缓存大小
		binlog-ignore-db=mysql                                          #binlog忽略指定数据库
		binlog-ignore-db=information_schema                             #binlog忽略指定数据库
		binlog-ignore-db=performance_schema                             #binlog忽略指定数据库
		binlog-ignore-db=sys                                            #binlog忽略指定数据库
		#binlog-do-db=test                                              #binlog开启指定数据库
		#binlog-do-db=business                                          #binlog开启指定数据库
		
		slow_query_log=ON                                               #慢查询日志是否开启
		slow_query_log_file=/usr/local/mysql/log/mysql-slow.log         #慢查询日志文件
		long_query_time=2                                               #慢查询最小时间秒
		
		relay-log=mysql-relay-bin                                       #主从中继日志名称
		max_relay_log_size=1024M                                        #主从中继日志文件最大值
		log-slave-updates=1                                             #主从复制是否写入binlog

#### 初始化并启动数据库，输入命令：
		
	cd /usr/local/mysql
	
	# 执行完毕控制台会输出初始密码，需要记住密码文本
	./bin/mysqld --initialize --user=mysql --basedir=/usr/local/mysql/ --datadir=/usr/local/mysql/data/
	
	cp -a ./support-files/mysql.server /etc/init.d/mysqld
	
	service mysqld start

#### 配置数据库shell环境变量，输入命令：
				
	vi /etc/profile
	
	添加以下配置：
		
		export MYSQL_HOME="/usr/local/mysql/"
		
		export PATH="$PATH:$MYSQL_HOME/bin"
		
	source /etc/profile

#### 初始化超管账号，输入命令：

	# 初始化登录，使用控制台输出的初始密码登录
	mysql -uroot -p
			
	set PASSWORD = PASSWORD('123456');
	
	flush privileges;
	
	use mysql;
	
	update user set host='%' where user='root';
	
	grant all privileges on *.* to 'root'@'%' identified by '123456';
	
	flush privileges;
	
	service mysqld restart


