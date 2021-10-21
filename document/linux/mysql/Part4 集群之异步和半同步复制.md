
# mysql集群异步复制和半同步复制

### 异步复制和半同步复制

	异步复制：
		
		mysql默认的复制方式，主库在执行完客户端提交的事务后会立即将结果返给给客户端，并不关心从库是否已经接收并处理
		
		通过 Part2/Part3 配置的主从复制方式都是异步复制
		
	半同步复制：
		
		主库在执行完客户端提交的事务后不是立刻返回给客户端，而是等待至少一个从库接收到并写到relay log中才返回给客户端
		
		当半同步复制发生超时，会暂时关闭半同步复制，转而使用异步复制；当主库发送玩一个事务的所有事件后收到了从库的响应，则主从又重新恢复为半同步复制
		
		基于主从模式、主主模式，可以通过安装 mysql 插件的方式，开启半同步复制

### 第一步，主从服务器 mysql 安装插件

	输入命令：
		
		mysql -uroot -p
		
		INSTALL PLUGIN rpl_semi_sync_master SONAME 'semisync_master.so';
		
		INSTALL PLUGIN rpl_semi_sync_slave SONAME 'semisync_slave.so';
		
		show plugins;
		
### 第二步，主从服务器 mysql 修改配置文件并重启

	输入命令：
		
		vi /etc/my.cnf
		
		=>
			
			rpl_semi_sync_master_enabled=1
			rpl_semi_sync_slave_enabled=1
		
		service mysqld restart
	
### 第三步，主从服务器 mysql 通过启动日志查看是否已启用半同步复制

	查看mysql启动日志，输入命令：
		
		tail -f /usr/local/mysql/log/mysql.log
		
		-> master
			
			Start semi-sync binlog_dump to slave (server_id: 165), pos(mysql-bin.000016, 1653)
			Start semi-sync binlog_dump to slave (server_id: 166), pos(mysql-bin.000016, 1653)
			
		-> slave
			
			Start semi-sync replication to master 'replicator@192.168.140.164:3306' in log 'mysql-bin.000016' at position 1653
	
	可以看到主库和从库都已经开启了半同步复制


