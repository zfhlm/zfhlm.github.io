
# mysql集群双主互从

#### 服务器准备
		
	192.168.140.164		# 主服务器一
	
	192.168.140.165		# 主服务器一
	
	根据 Part1 安装配置好三台服务器

#### 双主服务器 mysql 创建主从同步账号，输入命令：

	mysql -uroot -p
	
	CREATE USER 'replicator'@'host' IDENTIFIED BY '123456';
	
	GRANT REPLICATION SLAVE ON *.* TO 'replicator'@'%' IDENTIFIED BY '123456';
	
	flush privileges;

#### 主服务器一 mysql 配置为从节点

	在 主服务器二输入命令：
	
		mysql -uroot -p
		
		# 输出信息作为 change master 命令参数 master_log_file、master_log_pos 值
		show master status;
	
	使用上面的输出信息作为参数，在服务器一输入命令：
		
		mysql -uroot -p
		
		change master to master_host='192.168.140.165', master_user='replicator', master_password='123456', master_log_file='mysql-bin.000007', master_log_pos=65;
		
		start slave;
		
		show slave status;

#### 主服务器二 mysql 配置为从节点
		
	在 主服务器一 输入命令：
	
		mysql -uroot -p
		
		# 输出信息作为 change master 命令参数 master_log_file、master_log_pos 值
		show master status;
	
	使用上面的输出信息作为参数，在 主服务器二 输入命令：
		
		mysql -uroot -p
		
		change master to master_host='192.168.140.164', master_user='replicator', master_password='123456', master_log_file='mysql-bin.000011', master_log_pos=154;
		
		start slave;
		
		show slave status;

#### 测试主从同步

	主服务器一建库建表并插入数据，输入命令：
		
		mysql -uroot -p
		
		create database `test`;
		
		use `test`;
		
		create table `test_user` (
		  `id` int(11) NOT NULL,
		  `name` varchar(50) NOT NULL,
		  primary key (`id`)
		) engine=InnoDB default charset=utf8mb4;
		
		insert into `test_user` values ('1', '张三');
		
	主服务器二查询数据，输入命令：
		
		mysql -uroot -p
		
		use `test`;
		
		SELECT * FROM `test_user` where `id` = 1;
		
	主服务器二插入数据，输入命令：
		
		insert into `test_user` values ('2', '李四');
	
	主服务器一查询数据，输入命令：
	
		SELECT * FROM `test_user` where `id` = 2;


