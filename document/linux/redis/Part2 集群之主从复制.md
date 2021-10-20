
# redis集群 主从复制

### 服务器准备

	192.168.140.160		#主服务器
	
	192.168.140.161		#从服务器
	
	192.168.140.162		#从服务器
	
	三台服务器都配置好单点redis

### 更改从服务器redis配置

	输入命令：
		
		cd /usr/local/redis
		
		vi redis.conf
	
		=>
			
			replicaof 192.168.140.160 6379
		
		pkill redis
		
		./bin/redis-server ./redis.conf
		
### 验证主从复制
	
	主服务器插入数据，输入命令：
	
		./bin/redis-cli
		
		set test 123456
	
	从服务器查询数据，输入命令：
		
		./bin/redis-cli
		
		get test
	
### 注意事项：
		
	如果超过两个 slave，一般都会配置为链式： master -> slave -> slave -> slave
	
	主节点可读可写，从节点只读，客户端配置必须加以区分，不能往从节点中写入数据
	
### 使用 springboot 连接主从复制redis

	代码示例：
		
		// 使用主节点创建配置
		RedisStaticMasterReplicaConfiguration serverConfig = new RedisStaticMasterReplicaConfiguration("192.168.140.160", 6379);
		
		// 添加从节点
		serverConfig.addNode("192.168.140.161", 6379);
		serverConfig.addNode("192.168.140.162", 6379);
					
		// 客户端策略，任意从节点读，主节点写
		LettuceClientConfiguration clientConfig = LettuceClientConfiguration.builder().readFrom(ReadFrom.ANY_REPLICA).build();
		
		// 创建连接工厂
		LettuceConnectionFactory factory = new LettuceConnectionFactory(serverConfig, clientConfig);


