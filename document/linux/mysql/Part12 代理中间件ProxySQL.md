
# ProxySQL

	文档地址：https://proxysql.com/Documentation/
	
	下载地址：https://github.com/sysown/proxysql/releases

#### 服务器准备

	192.168.140.164		#mysql服务器，主节点
	
	192.168.140.165		#mysql服务器，从节点
	
	192.168.140.191		#ProxySQL服务器
	
	(根据 Part02 配置好主从复制)

#### 安装启用 ProxySQL

	【以下都在 ProxySQL 服务器执行】
	
	1，使用 yum 安装，输入命令：
	
		yum install -y https://github.com/sysown/proxysql/releases/download/v2.3.2/proxysql-2.3.2-1-centos7.x86_64.rpm
	
	2，安装 mysql 控制台，输入命令：
	
		cd /usr/local/software
		
		tar -zxvf ./mysql-5.7.35-linux-glibc2.12-x86_64.tar.gz
		
		mv ./mysql-5.7.35-linux-glibc2.12-x86_64 ../mysql
		
		echo '' >> /etc/profile
		
		echo 'export MYSQL_HOME="/usr/local/mysql/"' >> /etc/profile
		
		echo 'export PATH="$PATH:$MYSQL_HOME/bin"' >> /etc/profile
		
		source /etc/profile
	
	3，启动进程，输入命令：
		
		systemctl proxysql start                           #启动ProxySQL进程
		
		systemctl proxysql restart                         #重启ProxySQL进程
		
		systemctl proxysql stop                            #停止ProxySQL进程
		
		proxysql --version                                 #查看ProxySQL版本
		
	4，登录管理控制台，输入命令：
	
		mysql -uadmin -padmin -P6032 -h127.0.0.1           #登录ProxySQL控制台
		
		show databases;                                    #列出ProxySQL所有表空间
		
		show tables;                                       #列出ProxySQL所有表
		
		show mysql variables;                              #列出ProxySQL所有变量
		
		select * from stats.stats_mysql_connection_pool;   #查询连接统计信息

#### 添加 mysql 账号

	【以下都在 mysql 主节点执行】
	
	1，创建账号（test/123456 为客户端账号，monitor/123456 为 ProxySQL 监控账号），输入命令：
		
		mysql -uroot -p
		
		grant all on *.* to 'monitor'@'%' identified by '123456';
		
		grant select, update, insert, delete, create, alter, drop, index, execute on test.* to 'test'@'%' identified by '123456';
		
		flush privileges;
		
	2，建库建表，输入命令：
	
		create database test;
		
		use test;
		
		create table `user` (`id` int(11) not null, `name` varchar(50) not null, primary key (`id`)) engine=innodb default charset=utf8mb4 collate=utf8mb4_bin;

#### 配置 mysql 账号到 ProxySQL

	【以下都在 ProxySQL 服务器执行】
	
	1，添加数据库客户端账号 ，输入命令：
		
		mysql -uadmin -padmin -P6032 -h127.0.0.1
		
		insert into mysql_users(username, password, default_hostgroup, comment) VALUES ('test', '123456', 1, '客户端账号');
		
		load mysql users to runtime;
		
		save mysql users to disk;
		
		select * from mysql_users;
	
	2，添加数据库监控账号，输入命令：
		
		set mysql-monitor_username = 'monitor';
		
		set mysql-monitor_password = '123456';
		
		set mysql-monitor_connect_interval = '2000';
		
		set mysql-monitor_ping_interval = '2000';
		
		set mysql-monitor_read_only_interval = '2000';
		
		load mysql variables to runtime;
		
		save mysql variables to disk;
		
		select * from global_variables;

#### 配置 ProxySQL 读写分离

	【以下都在 ProxySQL 服务器执行】
	
	1，创建读写分离分组，输入命令：
		
		# 分组1可写，分组2可读
		insert into mysql_replication_hostgroups(writer_hostgroup, reader_hostgroup, comment) values(1, 2, '读写分离分组');
		
		load mysql servers to runtime;
		
		save mysql servers to disk;
		
	2，添加 mysql 服务器配置，输入命令：
		
		# 主节点添加到分组1
		insert into mysql_servers(hostgroup_id, hostname, port, weight, comment) values(1, '192.168.140.164', 3306, 1, '主节点');
		
		# 主节点添加到分组2，权重1承担少部分读请求，兜底从节点不可用
		insert into mysql_servers(hostgroup_id, hostname, port, weight, comment) values(2, '192.168.140.164', 3306, 1, '主节点');
		
		# 从节点添加到分组2，权重5000，主要承担读请求
		insert into mysql_servers(hostgroup_id, hostname, port, weight, comment) values(2, '192.168.140.165', 3306, 5000, '从节点');
		
		load mysql servers to runtime;
		
		save mysql servers to disk;
		
	 3，添加 mysql 路由规则（注意，规则匹配顺序根据 rule_id 大小排序，数值越小越先匹配，如果匹配不到规则，则请求主节点），输入命令：
		
		# select for update 路由到主节点
		insert into mysql_query_rules(rule_id, active, match_pattern, destination_hostgroup, apply) values(1, 1, '^SELECT.*UPDATE$', 1, 1);
		
		# select 路由到从节点
		insert into mysql_query_rules(rule_id, active, match_pattern, destination_hostgroup, apply) values(2, 1, '^SELECT', 2, 1);
		
		load mysql query rules to runtime;
		
		save mysql query rules to disk;
	
	4，查看连接统计信息，输入命令：
		
		select * from runtime_mysql_servers;
		
		select * from stats.stats_mysql_connection_pool;

#### 模拟  ProxySQL 读写分离

	1，以上环境配置好， ProxySQL 查询状态：
		
		select * from runtime_mysql_servers;
		
		# 符合主节点可读可写，从节点只读
		
		+--------------+-----------------+------+--------+--------+-----------------+-----------+
		| hostgroup_id | hostname        | port | status | weight | max_connections | comment   |
		+--------------+-----------------+------+--------+--------+-----------------+-----------+
		| 1            | 192.168.140.164 | 3306 | ONLINE | 1      | 1000            | 主节点     |
		| 2            | 192.168.140.164 | 3306 | ONLINE | 1      | 1000            | 主节点     |
		| 2            | 192.168.140.165 | 3306 | ONLINE | 100    | 1000            | 从节点     |
		+--------------+-----------------+------+--------+--------+-----------------+-----------+
	
	2，模拟 mysql 主节点故障，ProxySQL 查询状态：
		
		select * from runtime_mysql_servers;
		
		# 符合主节点不可用，从节点可读
		
		+--------------+-----------------+------+--------+--------+-----------------+-----------+
		| hostgroup_id | hostname        | port | status | weight | max_connections | comment   |
		+--------------+-----------------+------+--------+--------+-----------------+-----------+
		| 1            | 192.168.140.164 | 3306 |SHUNNED | 1      | 1000            | 主节点     |
		| 2            | 192.168.140.164 | 3306 |SHUNNED | 1      | 1000            | 主节点     |
		| 2            | 192.168.140.165 | 3306 | ONLINE | 100    | 1000            | 从节点     |
		+--------------+-----------------+------+--------+--------+-----------------+-----------+
	
	4，模拟 mysql 从节点故障，ProxySQL 查询状态：
		
		select * from runtime_mysql_servers;
		
		# 符合主节点可读可写，从节点不可用
		
		+--------------+-----------------+------+--------+--------+-----------------+-----------+
		| hostgroup_id | hostname        | port | status | weight | max_connections | comment   |
		+--------------+-----------------+------+--------+--------+-----------------+-----------+
		| 1            | 192.168.140.164 | 3306 | ONLINE | 1      | 1000            | 主节点     |
		| 2            | 192.168.140.164 | 3306 | ONLINE | 1      | 1000            | 主节点     |
		| 2            | 192.168.140.165 | 3306 |SHUNNED | 100    | 1000            | 从节点     |
		+--------------+-----------------+------+--------+--------+-----------------+-----------+

#### 模拟 ProxySQL 主从切换

	1，配置 mysql 为双主互从，节点一可读可写，节点二只读，ProxySQL 查询状态：
		
		select * from runtime_mysql_servers;
		
		# 符合节点一可读可写，节点二只读
		
		+--------------+-----------------+------+--------+--------+-----------------+-----------+
		| hostgroup_id | hostname        | port | status | weight | max_connections | comment   |
		+--------------+-----------------+------+--------+--------+-----------------+-----------+
		| 1            | 192.168.140.164 | 3306 | ONLINE | 1      | 1000            | 主节点     |
		| 2            | 192.168.140.164 | 3306 | ONLINE | 1      | 1000            | 主节点     |
		| 2            | 192.168.140.165 | 3306 | ONLINE | 100    | 1000            | 从节点     |
		+--------------+-----------------+------+--------+--------+-----------------+-----------+
		
	2，模拟主从切换，配置更改为节点一只读，节点二可读可写，ProxySQL 查询状态：
		
		select * from runtime_mysql_servers;
		
		# 符合节点一只读，节点二可读可写
		
		+--------------+-----------------+------+--------+--------+-----------------+-----------+
		| hostgroup_id | hostname        | port | status | weight | max_connections | comment   |
		+--------------+-----------------+------+--------+--------+-----------------+-----------+
		| 1            | 192.168.140.165 | 3306 | ONLINE | 100    | 1000            | 从节点     |
		| 2            | 192.168.140.164 | 3306 | ONLINE | 1      | 1000            | 主节点     |
		| 2            | 192.168.140.165 | 3306 | ONLINE | 100    | 1000            | 从节点     |
		+--------------+-----------------+------+--------+--------+-----------------+-----------+
		
	3，模拟主从再次切换，配置更改为节点一可读可写，节点二只读，ProxySQL 查询状态：
	
		select * from runtime_mysql_servers;
		
		# 符合节点一可读可写，节点二只读
		
		+--------------+-----------------+------+--------+--------+-----------------+-----------+
		| hostgroup_id | hostname        | port | status | weight | max_connections | comment   |
		+--------------+-----------------+------+--------+--------+-----------------+-----------+
		| 1            | 192.168.140.164 | 3306 | ONLINE | 1      | 1000            | 主节点     |
		| 2            | 192.168.140.164 | 3306 | ONLINE | 1      | 1000            | 主节点     |
		| 2            | 192.168.140.165 | 3306 | ONLINE | 100    | 1000            | 从节点     |
		+--------------+-----------------+------+--------+--------+-----------------+-----------+

#### 

