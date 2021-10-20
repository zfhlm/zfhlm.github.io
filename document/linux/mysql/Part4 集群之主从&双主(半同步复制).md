
# Mysql集群 主从/主主 半同步复制

### 第一步，服务器准备
	
	基于 mysql 一主多从、主主互从等模式进行配置
	
	mysql 默认的主从复制方式为异步复制，可以通过安装 mysql 插件的方式，开启半同步复制
	
### 第二步，主从服务器 mysql 安装插件

	输入命令：
		
		mysql -uroot -p
		
		INSTALL PLUGIN rpl_semi_sync_master SONAME 'semisync_master.so';
		
		INSTALL PLUGIN rpl_semi_sync_slave SONAME 'semisync_slave.so';
		
		show plugins;
		
### 第三步，主从服务器 mysql 修改配置文件并重启

	输入命令：
		
		vi /etc/my.cnf
		
		=>
			
			rpl_semi_sync_master_enabled=1
			rpl_semi_sync_slave_enabled=1
		
		service mysqld restart
	
### 第四步，主从服务器 mysql 通过启动日志查看是否已启用半同步复制

	输入命令：
		
		tail -f /usr/local/mysql/log/mysql.log
		
		-> master
			
			Start semi-sync binlog_dump to slave (server_id: 165), pos(mysql-bin.000016, 1653)
			Start semi-sync binlog_dump to slave (server_id: 166), pos(mysql-bin.000016, 1653)
			
		-> slave
			
			Start semi-sync replication to master 'replicator@192.168.140.164:3306' in log 'mysql-bin.000016' at position 1653


