
# ProxySQL

#### 服务器准备

	192.168.140.164		#节点一，mysql
	
	192.168.140.165		#节点二，mysql
	
	192.168.140.191		#节点三，ProxySQL
	
	节点一：根据 Part01、Part04、Part05 配置好单点数据库，开启GTID和半同步复制，关闭只读
	
	节点二：根据 Part01、Part04、Part05 配置好单点数据库，开启GTID和半同步复制，开启只读
	
	节点三：上传 mysql5.7 安装包到ProxySQL服务器 /usr/local/software 目录

#### ProxySQL 安装

	节点三使用 yum 安装，输入命令：
	
		yum install -y https://github.com/sysown/proxysql/releases/download/v2.3.2/proxysql-2.3.2-1-centos7.x86_64.rpm
	
	节点三配置 mysql 控制台，输入命令：
		
		cd /usr/local/software
		
		tar -zxvf ./mysql-5.7.35-linux-glibc2.12-x86_64.tar.gz
		
		mv ./mysql-5.7.35-linux-glibc2.12-x86_64 ../mysql
		
		echo '' >> /etc/profile
		
		echo 'export MYSQL_HOME="/usr/local/mysql/"' >> /etc/profile
		
		echo 'export PATH="$PATH:$MYSQL_HOME/bin"' >> /etc/profile
		
		source /etc/profile
		
	节点三启动 ProxySQL，输入命令：
		
		systemctl proxysql start

#### ProxySQL 常用命令

	操作进程相关命令：
		
		systemctl proxysql start                                 #启动ProxySQL进程
		
		systemctl proxysql restart                               #重启ProxySQL进程
		
		systemctl proxysql stop                                  #停止ProxySQL进程
		
		proxysql --version                                       #查看ProxySQL版本
		
		mysql -uadmin -padmin -P6032 -h127.0.0.1                 #登录ProxySQL控制台

#### ProxySQL 相关介绍
	
	查询常用的语句：
		
		show databases;                                          #列出所有表空间
			
		show tables;                                             #列出所有表
		
		show tables from database_name;                          #列出表空间下所有表
		
		show create table table_name;                            #列出表创建语句
	
	表空间相关信息：
		
		main                                                     #内存配置表空间
		
		disk                                                     #内存配置持久化表空间
		
		stats                                                    #进程运行状况表空间
		
		monitor                                                  #进程监控信息表空间
		
		stats_history                                            #进程统计历史信息表空间      
	
	表空间下各个的相关作用，查看官方文档：
		
		https://proxysql.com/Documentation/                      #文档首页
		
		https://proxysql.com/documentation/main-runtime/         #表空间main相关表介绍
		
		https://proxysql.com/documentation/disk-disk/            #表空间disk相关表介绍
		
		https://proxysql.com/documentation/stats-statistics/     #表空间stats相关表介绍
		
		https://proxysql.com/documentation/galera-configuration/ #PXC和MGC相关文档

#### 主从集群，ProxySQL分别把查询和更新路由到主节点和从节点

	节点一创建客户端账号、监控账号、主从同步账号，输入命令：
		
		mysql -uroot -p
		
		grant replication slave on *.* TO 'replicator'@'%' identified by '123456';
		
		grant all on *.* to 'monitor'@'%' identified by '123456';
		
		grant select, update, insert, delete, create, alter, drop, index, execute on test.* to 'test'@'%' identified by '123456';
		
		flush privileges;
		
	节点一创建测试库和测试表，输入命令：
		
		create database test;
		
		create table `test.user` (
			`id` int(11) not null, 
			`name` varchar(50) not null, 
			primary key (`id`)
		) engine=innodb default charset=utf8mb4 collate=utf8mb4_bin;
	
	节点二关联到节点一作为从库，输入命令：
		
		change master to master_host='192.168.140.164', master_user='replicator', master_password='123456',master_auto_position = 1;
		
		start slave;
	
	节点三配置后端数据库账号，输入命令：
		
		mysql -uadmin -padmin -P6032 -h127.0.0.1
		
		insert into mysql_users(username, password, default_hostgroup, comment) VALUES ('test', '123456', 1, '客户端账号');
		
		load mysql users to runtime;
		
		save mysql users to disk;
		
		select * from mysql_users;
	
	节点三配置后端数据库监控账号，输入命令：
		
		set mysql-monitor_username = 'monitor';
		
		set mysql-monitor_password = '123456';
		
		set mysql-monitor_connect_interval = '2000';
		
		set mysql-monitor_ping_interval = '2000';
		
		set mysql-monitor_read_only_interval = '2000';
		
		load mysql variables to runtime;
		
		save mysql variables to disk;
		
		select * from global_variables;
	
	节点三配置后端数据库读写分组(分组1只写，分组2只读)，输入命令：
		
		insert into mysql_replication_hostgroups(writer_hostgroup, reader_hostgroup, comment) values(1, 2, '读写分离分组');
		
		load mysql servers to runtime;
		
		save mysql servers to disk;
	
	节点三配置后端数据库并分组，输入命令：
	
		# 主节点只写
		insert into mysql_servers(hostgroup_id, hostname, port, weight, comment) values(1, '192.168.140.164', 3306, 1, '节点一');
		
		# 主节点可读，权重1承担少部分读请求，兜底从节点不可用
		insert into mysql_servers(hostgroup_id, hostname, port, weight, comment) values(2, '192.168.140.164', 3306, 1, '节点一');
		
		# 从节点只读，权重5000，主要承担读请求
		insert into mysql_servers(hostgroup_id, hostname, port, weight, comment) values(2, '192.168.140.165', 3306, 5000, '节点二');
		
		load mysql servers to runtime;
		
		save mysql servers to disk;
	
	节点三配置 SQL 是读是写匹配规则(规则匹配顺序根据rule_id数值越小越先匹配，如果匹配不到规则，则请求主节点)，输入命令：
		
		insert into mysql_query_rules(rule_id, active, match_pattern, destination_hostgroup, apply) values(1, 1, '^SELECT.*UPDATE$', 1, 1);
		
		insert into mysql_query_rules(rule_id, active, match_pattern, destination_hostgroup, apply) values(2, 1, '^SELECT', 2, 1);
		
		load mysql query rules to runtime;
		
		save mysql query rules to disk;
	
	节点二模拟客户端对ProxySQL进行读写，输入命令：
		
		mysql -utest -p123456 -P6033 -h192.168.140.191
		
		select * from test.user;
		
		insert into test.user(id, name) values(1, '张三');
		
		insert into test.user(id, name) values(2, '李四');
		
		insert into test.user(id, name) values(3, '王五');
		
		insert into test.user(id, name) values(4, '赵六');
		
		select * from test.user;
		
	节点三查询数据库连接统计信息，输入命令：	
		
		select * from stats.stats_mysql_connection_pool;
		
		# Queries执行次数指标(连接或重连也算一次)
		+-----------+-----------------+----------+--------+----------+----------+--------+---------+-------------+---------+
		| hostgroup | srv_host        | srv_port | status | ConnUsed | ConnFree | ConnOK | ConnERR | MaxConnUsed | Queries |
		+-----------+-----------------+----------+--------+----------+----------+--------+---------+-------------+---------+
		| 1         | 192.168.140.164 | 3306     | ONLINE | 0        | 1        | 1      | 0       | 1           | 6       |
		| 2         | 192.168.140.164 | 3306     | ONLINE | 0        | 0        | 0      | 0       | 0           | 0       | 
		| 2         | 192.168.140.165 | 3306     | ONLINE | 0        | 1        | 1      | 0       | 1           | 3       |
		+-----------+-----------------+----------+--------+----------+----------+--------+---------+-------------+---------+
		
	节点二继续模拟客户端对ProxySQL进行读写，输入命令：
		
		insert into test.user(id, name) values(5, '张三');
		
		insert into test.user(id, name) values(6, '李四');
		
		insert into test.user(id, name) values(7, '王五');
		
		select * from test.user;
			
	节点三查询数据库连接统计信息，输入命令：	
		
		select * from stats.stats_mysql_connection_pool;
		
		# Queries执行次数指标，符合查询加1次，更新加2次
		+-----------+-----------------+----------+--------+----------+----------+--------+---------+-------------+---------+
		| hostgroup | srv_host        | srv_port | status | ConnUsed | ConnFree | ConnOK | ConnERR | MaxConnUsed | Queries |
		+-----------+-----------------+----------+--------+----------+----------+--------+---------+-------------+---------+
		| 1         | 192.168.140.164 | 3306     | ONLINE | 0        | 1        | 1      | 0       | 1           | 9       |
		| 2         | 192.168.140.164 | 3306     | ONLINE | 0        | 0        | 0      | 0       | 0           | 0       | 
		| 2         | 192.168.140.165 | 3306     | ONLINE | 0        | 1        | 1      | 0       | 1           | 4       |
		+-----------+-----------------+----------+--------+----------+----------+--------+---------+-------------+---------+
		
	节点三展示后端数据库连接状态，模拟主从节点故障，可以发现主节点 down 会影响写，从节点 down 无影响：
		
		select * from runtime_mysql_servers;
		
		# 主从节点正常时
		+--------------+-----------------+------+--------+--------+-----------------+-----------+
		| hostgroup_id | hostname        | port | status | weight | max_connections | comment   |
		+--------------+-----------------+------+--------+--------+-----------------+-----------+
		| 1            | 192.168.140.164 | 3306 | ONLINE | 1      | 1000            | 节点一     |
		| 2            | 192.168.140.164 | 3306 | ONLINE | 1      | 1000            | 节点一     |
		| 2            | 192.168.140.165 | 3306 | ONLINE | 100    | 1000            | 节点二     |
		+--------------+-----------------+------+--------+--------+-----------------+-----------+
		
		# 模拟关闭主节点进程，主节点不可用，从节点可读
		+--------------+-----------------+------+--------+--------+-----------------+-----------+
		| hostgroup_id | hostname        | port | status | weight | max_connections | comment   |
		+--------------+-----------------+------+--------+--------+-----------------+-----------+
		| 1            | 192.168.140.164 | 3306 |SHUNNED | 1      | 1000            | 节点一     |
		| 2            | 192.168.140.164 | 3306 |SHUNNED | 1      | 1000            | 节点一     |
		| 2            | 192.168.140.165 | 3306 | ONLINE | 100    | 1000            | 节点二     |
		+--------------+-----------------+------+--------+--------+-----------------+-----------+
		
		# 模拟关闭从节点进程，主节点可读可写，从节点不可用
		+--------------+-----------------+------+--------+--------+-----------------+-----------+
		| hostgroup_id | hostname        | port | status | weight | max_connections | comment   |
		+--------------+-----------------+------+--------+--------+-----------------+-----------+
		| 1            | 192.168.140.164 | 3306 | ONLINE | 1      | 1000            | 节点一     |
		| 2            | 192.168.140.164 | 3306 | ONLINE | 1      | 1000            | 节点一     |
		| 2            | 192.168.140.165 | 3306 |SHUNNED | 100    | 1000            | 节点二     |
		+--------------+-----------------+------+--------+--------+-----------------+-----------+
	
	ProxySQL 会根据后端数据库的 read_only 配置，自动进行主从切换，动态将后端数据库分配到读分组或写分组
	
	节点三展示展示后端数据库连接状态，模拟 MHA 主从切换，主节点开启只读并关闭进程，从节点关闭只读：
		
		# 节点二可读可写，节点一不可用
		+--------------+-----------------+------+--------+--------+-----------------+-----------+
		| hostgroup_id | hostname        | port | status | weight | max_connections | comment   |
		+--------------+-----------------+------+--------+--------+-----------------+-----------+
		| 1            | 192.168.140.165 | 3306 | ONLINE | 100    | 1000            | 节点二     |
		| 2            | 192.168.140.164 | 3306 |SHUNNED | 1      | 1000            | 节点一     |
		| 2            | 192.168.140.165 | 3306 | ONLINE | 100    | 1000            | 节点二     |
		+--------------+-----------------+------+--------+--------+-----------------+-----------+
	
	节点三展示展示后端数据库连接状态，模拟 MHA 主节点恢复：
	
		# 节点二可读可写，节点一只读
		+--------------+-----------------+------+--------+--------+-----------------+-----------+
		| hostgroup_id | hostname        | port | status | weight | max_connections | comment   |
		+--------------+-----------------+------+--------+--------+-----------------+-----------+
		| 1            | 192.168.140.165 | 3306 | ONLINE | 100    | 1000            | 节点二     |
		| 2            | 192.168.140.164 | 3306 | ONLINE | 1      | 1000            | 节点一     |
		| 2            | 192.168.140.165 | 3306 | ONLINE | 100    | 1000            | 节点二     |
		+--------------+-----------------+------+--------+--------+-----------------+-----------+
	
	节点三展示展示后端数据库连接状态，模拟 MHA 主节点从新接管作为主：
		
		# 节点一可读可写，节点二只读
		+--------------+-----------------+------+--------+--------+-----------------+-----------+
		| hostgroup_id | hostname        | port | status | weight | max_connections | comment   |
		+--------------+-----------------+------+--------+--------+-----------------+-----------+
		| 1            | 192.168.140.164 | 3306 | ONLINE | 1      | 1000            | 节点一     |
		| 2            | 192.168.140.164 | 3306 | ONLINE | 1      | 1000            | 节点一     |
		| 2            | 192.168.140.165 | 3306 | ONLINE | 100    | 1000            | 节点二     |
		+--------------+-----------------+------+--------+--------+-----------------+-----------+


