
# Mysql集群  一主多从  异步复制

### 第一步，服务器准备
	
	192.168.140.164		# 主服务器
	
	192.168.140.165		# 从服务器一
	
	192.168.140.166		# 从服务器二
	
	三台服务器预安装  mysql 单点服务，开启binlog输出
	
### 第二步，所有服务器 mysql 创建主从同步账号

	输入命令：
		
		mysql -uroot -p
		
		CREATE USER 'replicator'@'host' IDENTIFIED BY '123456';
		
		GRANT REPLICATION SLAVE ON *.* TO 'replicator'@'%' IDENTIFIED BY '123456';
		
		flush privileges;
		
		show master status;
		
		-> 
		
			(记住控制台输出参数，作为 change master 命令参数)
	
### 第三步，从服务器 mysql 配置主从复制

	输入命令：
		
		mysql -uroot -p
		
		change master to master_host='192.168.140.164', master_user='replicator', master_password='123456', master_log_file='mysql-bin.000016', master_log_pos=1113;
		
		start slave;
		
		show slave status;
	
### 第四步，主从同步测试

	主从服务器 mysql 建表建库，输入命令：
		
		mysql -uroot -p
		
		CREATE DATABASE 'test';
		
		use test;
		
		CREATE TABLE `test_user` (
		  `id` int(11) NOT NULL,
		  `name` varchar(50) NOT NULL,
		  PRIMARY KEY (`id`)
		) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
		
		INSERT INTO `test_user` VALUES ('1', '张三');
		
	从服务器 mysql 查询数据，输入命令：
		
		mysql -uroot -p
		
		use test;
		
		SELECT * FROM `test_user` where `id` = 1;
	
### 关闭主从服务器 mysql 主从复制

	从服务器输入命令：
		
		mysql -uroot -p
		
		stop slave;
		
		reset slave all;
		
		show slave status;


