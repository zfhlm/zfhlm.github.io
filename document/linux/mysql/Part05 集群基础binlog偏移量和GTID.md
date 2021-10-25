
# mysql binlog 偏移量 和 GTID

	基于偏移量的binlog：
		
		在主从配置中使用 change master 命令指定 master_log_file 和 master_log_pos，是基于 binlog 和 binlog 的偏移量进行增量的复制
		
		如果偏移量指定错误，会造成数据的缺失或者数据不一致
	
	基于GTID的binlog：
	
		保证每个在主节点上提交的事务在集群中有一个唯一的ID，当一个事务在主节点执行并提交时会产生 GTID 并记录到binlog日志中
		
		从节点获取主节点binlog转存到relaylog后，会比对本节点是否有该GTID，再决定是否执行该GTID事务并记录到本节点binlog
		
		mysql开启了 GTID，当在主库上提交事务或者被从库应用时，可以定位和追踪每一个事务

#### 主从 mysql 开启 GTID

	主从节点修改 my.cnf，输入命令：
		
		vi /etc/my.cnf
		
	修改以下配置：
		
		log-bin=mysql-bin                                               #binlog开启
		binlog_format=row                                               #binlog格式
		log-slave-updates=1                                             #主从复制写入binlog
		
		gtid_mode=ON                                                    #开启GTID
		enforce_gtid_consistency=ON                                     #开启GTID强一致性事务
	
	重启 mysql，输入命令：
		
		service mysqld restart

#### 建立 mysql 主从复制

	从节点输入命令：
	
		mysql -uroot -p
		
		change master to master_host='192.168.140.164', master_user='replicator', master_password='123456',master_auto_position = 1;
		
		start slave;
		
		show slave status\G

#### 常见的 GTID 错误：Slave has more GTIDs than the master has, using the master's SERVER_UUID

	错误原因：
	
		人为在从节点上做了更新操作，从节点的 GTID_NEXT 超出主节点翻译
	
	避免错误：
		
		从节点开启只读，禁止使用super账号连接从节点，禁止对从节点进行更新操作
		
		提供给客户端的账号不允许为 super 账号
	
	解决办法：
	
		主节点人为干预追平从节点的 GTID；或解除主从关系，从节点清除数据，主节点全量备份之后导入从库

#### 常见的 GTID 错误：Error 'Operation ALTER USER failed for 'root'@'localhost'' on query

	错误原因：
		
		主服务器和从服务器都进行了更改root允许远程登录，在建立主从之后出现错误
		
	避免错误：
		
		基于GTID的主从，在从节点除了初始化更改root密码，建立主从关系之外，不能做其他更新操作


