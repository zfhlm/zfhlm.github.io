
# mysql集群一主多从

#### 服务器准备
	
	192.168.140.164		# 主服务器
	
	192.168.140.165		# 从服务器一
	
	192.168.140.166		# 从服务器二
	
	根据 Part1 安装配置好三台服务器

#### 所有服务器 mysql 创建主从同步账号，输入命令：
		
	mysql -uroot -p
	
	CREATE USER 'replicator'@'%' IDENTIFIED BY '123456';
	
	GRANT REPLICATION SLAVE ON *.* TO 'replicator'@'%' IDENTIFIED BY '123456';
	
	flush privileges;

#### 配置主从复制

	获取binlog信息，主服务器输入命令：
		
		mysql -uroot -p
		
		# 执行完毕输出信息，作为从服务器创建主从关系的master_log_file、master_log_pos参数值
		show master status;
	
	根据主服务器binlog信息关联，从服务器输入命令：
		
		mysql -uroot -p
		
		change master to master_host='192.168.140.164', master_user='replicator', master_password='123456', master_log_file='mysql-bin.000016', master_log_pos=1113;
		
		start slave;
		
		show slave status;
	
	如果需要关闭主从复制，从服务器输入命令：
		
		mysql -uroot -p
		
		stop slave;
		
		reset master;
		
		reset slave all;
		
		show slave status;

#### 测试主从同步

	主从服务器 mysql 建库建表并插入数据，输入命令：
		
		mysql -uroot -p
		
		create database `test`;
		
		use `test`;
		
		create table `test_user` (
		  `id` int(11) NOT NULL,
		  `name` varchar(50) NOT NULL,
		  primary key (`id`)
		) engine=InnoDB default charset=utf8mb4;
		
		insert into `test_user` values ('1', '张三');
		
	从服务器 mysql 查询数据，输入命令：
		
		mysql -uroot -p
		
		use test;
		
		SELECT * FROM `test_user` where `id` = 1;

#### 

