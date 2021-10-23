
# mysql  异步复制  半同步复制

#### 简单介绍

	异步复制：
		
		mysql默认的复制方式，主库在执行完客户端提交的事务后会立即将结果返给给客户端，并不关心从库是否已经接收并处理
		
		通过 Part2/Part3 配置的主从复制方式都是异步复制
		
	半同步复制：
		
		主库在执行完客户端提交的事务后不是立刻返回给客户端，而是等待至少一个从库接收到并写到relay log中才返回给客户端
		
		当半同步复制发生超时，会暂时关闭半同步复制，转而使用异步复制；当主库发送玩一个事务的所有事件后收到了从库的响应，则主从又重新恢复为半同步复制
		
		基于主从模式、主主模式，可以通过安装 mysql 插件的方式，开启半同步复制

#### 安装半同步复制插件
		
	可使用命令安装插件，输入命令：
		
		mysql -uroot -p
		
		INSTALL PLUGIN rpl_semi_sync_master SONAME 'semisync_master.so';
		
		INSTALL PLUGIN rpl_semi_sync_slave SONAME 'semisync_slave.so';
		
		show plugins;
	
	也可以添加 my.cnf 配置，引导数据库启动加载插件：
		
		[mysqld]
		
		plugin_load="rpl_semi_sync_master=semisync_master.so;rpl_semi_sync_slave=semisync_slave.so"
	
#### 开启半同步复制配置

	修改 my.cnf 配置文件，输入命令：
		
		vi /etc/my.cnf
	
	加入以下配置：
		
		loose-rpl_semi_sync_master_enabled=1                            #开启主节点半同步复制
		loose-rpl_semi_sync_slave_enabled=1                             #开启从节点半同步复制
		loose-rpl_semi_sync_master_timeout=5000                         #半同步复制等待超时时间(超时退化为异步复制)
	
	重启mysql，输入命令：
	
		service mysqld restart
	
	查看mysql启动日志，可以看到是否开启半同步复制，输入命令：
		
		tail -f /usr/local/mysql/log/mysql.log
		
		-> Start semi-sync binlog_dump to slave ......
		
		-> Start semi-sync replication to master ......
	
	其中的 Start semi-sync 显示半同步复制插件已经被启用


