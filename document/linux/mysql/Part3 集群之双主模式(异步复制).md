
# Mysql集群 双主互从 异步复制

### 第一步，服务器准备
		
	192.168.140.164		# 主服务器一
	
	192.168.140.165		# 主服务器一
	
	服务器预安装  mysql 单点服务，并开启binlog输出
		
### 第二步，双主服务器 mysql 创建双主同步账号

	输入命令：
		
		mysql -uroot -p
		
		CREATE USER 'replicator'@'host' IDENTIFIED BY '123456';
		
		GRANT REPLICATION SLAVE ON *.* TO 'replicator'@'%' IDENTIFIED BY '123456';
		
		flush privileges;
	
### 第三步，双主服务器 mysql 都配置为对方的从节点
		
	在 192.168.140.164 输入命令：
	
		mysql -uroot -p
		
		show master status;
		
		-> (输出信息作为 192.168.140.165 change master 命令参数 master_log_file、master_log_pos 值)
	
	在 192.168.140.165 输入命令：
		
		mysql -uroot -p
		
		change master to master_host='192.168.140.164', master_user='replicator', master_password='123456', master_log_file='mysql-bin.000011', master_log_pos=154;
		
		start slave;
		
		show slave status;
	
	------------------------------------------------------------------------------------------------------------
		
	在 192.168.140.165 输入命令：
	
		mysql -uroot -p
		
		show master status;
		
		-> (输出信息作为 192.168.140.164 change master 命令参数 master_log_file、master_log_pos 值)
	
	在 192.168.140.164 上使用 192.168.140.165 show master 输出的信息作为参数，输入命令：
		
		mysql -uroot -p
		
		change master to master_host='192.168.140.165', master_user='replicator', master_password='123456', master_log_file='mysql-bin.000007', master_log_pos=65;
		
		start slave;
		
		show slave status;

### 第四步，双主服务器 mysql 同步测试
	
	主服务器一 mysql 插入一条数据，查看主服务器二 mysql 是否存在该条数据
	
	主服务器二 mysql 插入一条数据，查看主服务器一 mysql 是否存在该条数据


