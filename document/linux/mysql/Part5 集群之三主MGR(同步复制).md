
# Mysql集群 三主MGR 同步复制

### 第一步，服务器准备
		
	192.168.140.164		# 主服务器一
	
	192.168.140.165		# 主服务器二
	
	192.168.140.166		# 主服务器三
	
	三台服务器预安装  mysql 单点服务，开启binlog输出

### 第二步，所有服务器修改 hosts 配置
	
	输入命令：
	
		vi /etc/hosts
		
		=>
		
			192.168.140.164 node164
			192.168.140.165 node165
			192.168.140.166 node166
		
		hostname
		
		service network restart
	
### 第三步，所有服务器 mysql 加入MGR配置

	输入命令：
	
		vi /etc/my.cnf
		
		=> (具体查看 installer/mysql/my.cnf.mgr 文件)
		
		service mysqld restart
		
### 第四步，所有服务器 mysql 安装 MGR 插件

	输入命令：
		
		mysql -uroot -p
		
		INSTALL PLUGIN group_replication SONAME 'group_replication.so';
		
		SHOW PLUGINS;
	
### 第五步，所有服务器 mysql 创建组复制账号

	输入命令：
		
		mysql -uroot -p
		
		CREATE USER 'replicator'@'host' IDENTIFIED BY '123456';
		
		GRANT REPLICATION SLAVE ON *.* TO 'replicator'@'%' IDENTIFIED BY '123456';
		
		flush privileges;
	
### 第六步，主服务器一  mysql 引导创建组

	输入命令：
		
		mysql -uroot -p
		
		SET GLOBAL group_replication_bootstrap_group=ON;
		
		CHANGE MASTER TO MASTER_USER='replicator',MASTER_PASSWORD='123456' FOR CHANNEL 'group_replication_recovery';
		
		START GROUP_REPLICATION;
		
		SET GLOBAL group_replication_bootstrap_group=OFF;
	
	注意，如果集群被关闭，需要重复执行以上命令

### 第七步，主服务器二和三 mysql 加入组

	输入命令：
		
		mysql -uroot -p
		
		CHANGE MASTER TO MASTER_USER='replicator',MASTER_PASSWORD='123456' FOR CHANNEL 'group_replication_recovery';
		
		START GROUP_REPLICATION;
		
		SELECT * FROM performance_schema.replication_group_members;
	
	注意，如果集群被关闭，需要重复执行以上命令

### 第八步，MGR集群同步测试

	任意一台服务器  mysql，输入命令：
		
		mysql -uroot -p
		
		CREATE DATABASE 'test2';
		
		use 'test2';
		
		CREATE TABLE `test_user` (
		  `id` int(11) NOT NULL,
		  `name` varchar(50) NOT NULL,
		  PRIMARY KEY (`id`)
		) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
		
		INSERT INTO `test_user` VALUES ('1', '张三');
	
	其他服务器查询数据，输入命令：
		
		mysql -uroot -p
		
		use 'test2';
		
		SELECT * FROM 'test2' WHERE `id` = 1;

#### 关闭服务器 mysql MGR 集群

	输入命令：
		
		mysql -uroot -p
		
		STOP GROUP_REPLICATION;
		
		RESET MASTER;
		
		RESET SLAVE ALL;
		
### 搭建 mysql MGR 遇到的问题
		
	配置主机 hostname，使用 IP 地址作为配置非引导节点一直处在 RECOVERING 状态
	
	主主配置错误，使用 reset master 命令重置，再使用 change master 命令进行配置
	
	如果节点出现故障，整个数据库会变成只读不允许写状态，直到故障恢复
	
	如果 MGR 集群被关闭，整个数据库会变成只读不允许写状态，直到重新启用 MGR 或重启mysql

### 三主切换为一主二从

	1，更改两台从服务器 mysql 的 my.cnf配置，设置为：
	
		loose-group_replication_enforce_update_everywhere_checks=FALSE
		loose-group_replication_single_primary_mode=ON
	
	2，通过主服务器 mysql 引导创建组，并启动 mysql MGR
		
		mysql -uroot -p
		
		SET GLOBAL group_replication_bootstrap_group=ON;
		
		CHANGE MASTER TO MASTER_USER='replicator',MASTER_PASSWORD='123456' FOR CHANNEL 'group_replication_recovery';
		
		START GROUP_REPLICATION;
		
		SET GLOBAL group_replication_bootstrap_group=OFF;
	
	3，启动从服务器 mysql MGR
		
		mysql -uroot -p
		
		CHANGE MASTER TO MASTER_USER='replicator',MASTER_PASSWORD='123456' FOR CHANNEL 'group_replication_recovery';
		
		START GROUP_REPLICATION;
		
		SELECT * FROM performance_schema.replication_group_members;
	
	4，使用命令查看集群各个数据库，主节点可读可写，从节点只读不允许写
	
		show variables like '%read_only%';


