
# mysql集群双主互从

#### 服务器准备

	192.168.140.164		# 主节点一
	
	192.168.140.165		# 主节点二
	
	(根据 Part01 安装配置好三台服务器)

#### 双主 mysql 创建主从同步账号

	输入命令：
		
		mysql -uroot -p
		
		CREATE USER 'replicator'@'host' IDENTIFIED BY '123456';
		
		GRANT REPLICATION SLAVE ON *.* TO 'replicator'@'%' IDENTIFIED BY '123456';
		
		FLUSH PRIVILEGES;

#### 主节点一 mysql 配置为 主节点二的从节点

	主节点二获取binlog信息，输入命令：
	
		mysql -uroot -p
		
		# 输出信息作为 change master 命令参数 master_log_file、master_log_pos 值
		show master status;
	
	主节点一使用上面的输出信息作为参数，输入命令：
		
		mysql -uroot -p
		
		change master to master_host='192.168.140.165', master_user='replicator', master_password='123456', master_log_file='mysql-bin.000007', master_log_pos=65;
		
		start slave;
		
		show slave status\G

#### 主节点二 mysql 配置为 主节点一的从节点
		
	主节点一 获取binlog信息，输入命令：
	
		mysql -uroot -p
		
		# 输出信息作为 change master 命令参数 master_log_file、master_log_pos 值
		show master status;
	
	主节点二使用上面的输出信息作为参数，输入命令：
		
		mysql -uroot -p
		
		change master to master_host='192.168.140.164', master_user='replicator', master_password='123456', master_log_file='mysql-bin.000011', master_log_pos=154;
		
		start slave;
		
		show slave status\G

#### 双主 mysql 复制测试

	主节点一建库建表并插入数据，输入命令：
		
		mysql -uroot -p
		
		create database `test`;
		
		use `test`;
		
		create table `test_user` ( `id` int(11) not null, `name` varchar(50) not null, primary key (`id`));
		
		insert into `test_user` values ('1', '张三');
		
	主节点二查询数据，输入命令：
		
		mysql -uroot -p
		
		use `test`;
		
		SELECT * FROM `test_user` where `id` = 1;
		
	主节点二插入数据，输入命令：
		
		insert into `test_user` values ('2', '李四');
	
	主节点器一查询数据，输入命令：
		
		SELECT * FROM `test_user` where `id` = 2;

#### 客户端连接 mysql 双主集群
	
	创建指定权限的普通账号给客户端使用：
		
		GRANT SELECT, UPDATE, INSERT, DELETE, CREATE, ALTER, DROP, INDEX on test.* TO 'test'@'%' IDENTIFIED BY '123456';
		
		FLUSH PRIVILEGES;
		
	虽然双主都允许写入数据，但是为了保证数据的一致性，只允许写入一个主节点，另一个主节点可承担部分读请求
	
	可以搭配 keepalived + VIP 的方式，主节点 down 掉后转移 VIP 到另一个主节点，继续提供服务给客户端


