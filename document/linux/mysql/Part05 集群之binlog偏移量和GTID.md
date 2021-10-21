
# mysql binlog偏移量和GTID

#### binlog偏移量和GTID

	基于偏移量的binlog：
		
		在主从配置中使用 change master 命令指定 master_log_file 和 master_log_pos，是基于 binlog 和 binlog 的偏移量进行增量的复制
		
		如果偏移量指定错误，会造成数据的缺失或者数据不一致
	
	基于GTID的binlog：
	
		保证每个在主节点上提交的事务在集群中有一个唯一的ID，当一个事务在主节点执行并提交时会产生 GTID 并记录到binlog日志中
		
		从节点获取主节点binlog转存到relaylog后，会比对本节点是否有该GTID，再决定是否执行该GTID事务并记录到本节点binlog
		
		开启GTID之后，通过 change master to master_host='xxx', master_auto_position=1 就可以建立主从关联，不用再去查询binlog偏移量
		
		mysql开启了 GTID，当在主库上提交事务或者被从库应用时，可以定位和追踪每一个事务
		
		通过change master to master_host='xxx', master_auto_position=1的即可方便的搭建从库

#### 开启 mysql GTID

	修改 mysql 主从配置文件，输入命令：
	
		vi /etc/my.cnf
		
		加入以下配置：
			
			log-bin=mysql-bin
			binlog_format=row
			log-slave-updates=1
			gtid_mode=ON
			enforce_gtid_consistency=ON
	
	重启 mysql，输入命令：
		
		service mysqld restart
		
	查看 mysql 当前事务 GTID，输入命令：
		
		show master status;
		
		show slave status;


