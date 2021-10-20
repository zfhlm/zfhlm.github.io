
# redis集群 哨兵模式
	
### 服务器准备
	
	192.168.140.160		#主服务器，redis 6379
	
	192.168.140.161		#从服务器，redis 6379
	
	192.168.140.162		#从服务器，redis 6379
	
	192.168.140.160		#sentinel服务器一，端口26379
	
	192.168.140.161		#sentinel服务器二，端口26379
	
	192.168.140.162		#sentinel服务器三，端口26379
	
	所有服务器配置好单点redis

### 从服务器redis配置

	输入命令：
		
		cd /usr/local/redis
		
		vi redis.conf
		
		=>
			
			replicaof 192.168.140.160 6379
	
### 修改redis哨兵配置

	输入命令：
			
		cd /usr/local/redis
		
		vi sentinel.conf
		
		=>
		
			protected-mode no
			
			daemonize yes
			
			sentinel monitor stnmaster 192.168.140.160 6379 2
		
### 启动主从服务器redis

	先启动所有主节点，再启动所有从节点
	
	输入命令：
	
		cd /usr/local/redis
		
		./bin/redis-server ./redis.conf
	
### 启动哨兵进程

	输入命令：
			
		cd /usr/local/redis
		
		./bin/redis-sentinel ./sentinel.conf
	
### 查看集群信息

	输入命令：
		
		cd /usr/local/redis
		
		./bin/redis-cli
		
		info replication
		
	主服务器可看到如下信息：
		
		role:master
		connected_slaves:2
		slave0:ip=192.168.140.161,port=6379,state=online,offset=21258,lag=1
		slave1:ip=192.168.140.162,port=6379,state=online,offset=21113,lag=1
		
	从服务器可看到如下信息：
	
		role:slave
		master_host:192.168.140.160
	
### 验证主从复制
	
	主服务器输入命令：
	
		./bin/redis-cli
		
		set masterkey 123456
		
		get masterkey
	
	从服务器输入命令：
	
		./bin/redis-cli
	
		get masterkey
		
		# 会报错，从节点不允许写
		set slavekey 123456
		
### 验证主从切换
	
	主服务杀死redis进程，输入命令：
	
		ps -ef | grep redis
		
		kill pid
		
	从服务器查看集群信息，输入命令：
	
		./bin/redis-cli
		
		info replication
		
	可以看到两个从服务器中，有一个节点被提升为master，且由只读变成可读可写
	
	重新启动主服务器redis进程，输入命令：
	
		./bin/redis-server ./redis.conf
		
		./bin/redis-cli
		
		info replication
	
	主服务器redis进程加入集群，成为从节点，主从服务器的redis.conf文件，主从配置已经变动
		
### 使用 springboot 连接哨兵集群 redis 

	配置文件 application.properties 示例：
		
		# sentinel进程连接地址
		spring.redis.sentinel.nodes=192.168.140.160:26379,192.168.140.161:26380,192.168.140.162:26381
		
		# 对应 sentinel.conf 中 sentinel monitor 配置的名称
		spring.redis.sentinel.master=stnmaster


