
### 单点配置

	1，下载安装包
		
		官方文档：https://redis.io/documentation
		
		下载地址：https://redis.io/download
		
		下载包：redis-6.2.6.tar.gz
		
		上传到服务器目录：/usr/local/software
		
	2，编译安装，输入命令：
	
		cd /usr/local/software
		
		tar -zxvf ./redis-6.2.6.tar.gz
		
		cd ./redis-6.2.6
		
		make PREFIX=/usr/local/redis install
		
		cp ./redis.conf /usr/local/redis/
		
		cp ./sentinel.conf /usr/local/redis/
		
		cd ..
		
		rm -rf redis-6.2.6
	
	3，修改redis配置文件，输入命令：
	
		cd /usr/local/redis
		
		vi redis.conf
		
		=>
		
			bind 127.0.0.1  192.168.140.160					#监听主机地址
			
			port 6379							#监听端口
			
			requirepass 123456						#配置使用密码
			
			daemonize yes                      				#启用守护进程
			
			pidfile /usr/local/redis/bin/6379.pid				#指定PID文件
			
			loglevel notice							#日志级别
			
			logfile /usr/local/redis/log/6379/redis.log			#日志位置
			
			dir "/usr/local/redis/data/6379/"				#本地数据库存放目录
			
			dbfilename dump.rdb						#本地数据库文件名
			
			activerehashing yes						#是否激活重置哈希
			
			rdbcompression yes						#是否储存启用压缩
			
			maxmemory							#最大内存占用
			
			maxmemory-policy						#缓存淘汰策略
			
			save 900 1							#RDB配置，每900秒至少有1个key发生变化，dump内存快照
			
			save 300 10							#RDB配置，每300秒至少有10个key发生变化，dump内存快照
			
			save 60 1000							#RDB配置，每60秒至少有10000个key发生变化，dump内存快照
					
			appendonly yes                     				#AOF配置，是否开启AOF持久化
			
			appendfilename "appendonly.aof"    				#AOF配置，AOF日志文件名
			
			appendfsync always                 				#AOF配置，每次有数据变动写入AOF文件，可选值 always/everysec/no
	
	4，启动redis，输入命令：
		
		cd /usr/local/redis
		
		./bin/redis-server ./redis.conf

### redis集群——主从复制
	
	1，服务器准备
	
		192.168.140.160		#主服务器
		
		192.168.140.161		#从服务器
		
		192.168.140.162		#从服务器
	
	2，更改从服务器redis配置，输入命令：
		
		cd /usr/local/redis
		
		vi redis.conf
	
		=>
			
			replicaof 192.168.140.160 6379
		
		pkill redis
		
		./bin/redis-server ./redis.conf
		
	4，验证主从复制
	
		主服务器插入数据，输入命令：
		
			./bin/redis-cli
			
			set test 123456
	
		从服务器查询数据，输入命令：
			
			./bin/redis-cli
			
			get test
	
	5，注意事项：
		
		如果超过两个 slave，一般都会配置为链式： master -> slave -> slave -> slave
		
		主节点可读可写，从节点只读，客户端配置必须加以区分，不能往从节点中写入数据
	
	6，使用 springboot 连接主从复制redis代码示例：
		
		// 使用主节点创建配置
		RedisStaticMasterReplicaConfiguration serverConfig = new RedisStaticMasterReplicaConfiguration("192.168.140.160", 6379);
		
		// 添加从节点
		serverConfig.addNode("192.168.140.161", 6379);
		serverConfig.addNode("192.168.140.162", 6379);
					
		// 客户端策略，任意从节点读，主节点写
		LettuceClientConfiguration clientConfig = LettuceClientConfiguration.builder().readFrom(ReadFrom.ANY_REPLICA).build();
		
		// 创建连接工厂
		LettuceConnectionFactory factory = new LettuceConnectionFactory(serverConfig, clientConfig);

### redis集群——哨兵模式
	
	1，服务器准备
	
		192.168.140.160		#主服务器，redis 6379
		
		192.168.140.161		#从服务器，redis 6379
		
		192.168.140.162		#从服务器，redis 6379
		
		192.168.140.160		#sentinel服务器一，端口26379
		
		192.168.140.161		#sentinel服务器二，端口26379
		
		192.168.140.162		#sentinel服务器三，端口26379
	
	2，从服务器redis配置，输入命令：
		
		cd /usr/local/redis
		
		vi redis.conf
		
		=>
			
			replicaof 192.168.140.160 6379
	
	3，修改redis哨兵配置，输入命令：
			
		cd /usr/local/redis
		
		vi sentinel.conf
		
		=>
		
			protected-mode no
			
			daemonize yes
			
			sentinel monitor stnmaster 192.168.140.160 6379 2
		
	4，启动主从服务器redis(先主后从)，输入命令：
	
		cd /usr/local/redis
		
		./bin/redis-server ./redis.conf
	
	5，启动哨兵进程，输入命令：
			
		cd /usr/local/redis
		
		./bin/redis-sentinel ./sentinel.conf
	
	6，查看集群信息，输入命令：
		
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
	
	7，验证主从复制
	
		主服务器输入命令：
		
			./bin/redis-cli
			
			set masterkey 123456
			
			get masterkey
		
		从服务器输入命令：
		
			./bin/redis-cli
		
			get masterkey
			
			# 会报错，从节点不允许写
			set slavekey 123456
		
	8，验证主从切换
	
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
		
	9，使用 springboot 连接哨兵集群 redis 配置示例：
		
		# sentinel进程连接地址
		spring.redis.sentinel.nodes=192.168.140.160:26379,192.168.140.161:26380,192.168.140.162:26381
		
		# 对应 sentinel.conf 中 sentinel monitor 配置的名称
		spring.redis.sentinel.master=stnmaster

### redis集群——Redis-Cluster模式

	1，服务器准备
		
		192.168.140.160		#redis 6379
		
		192.168.140.160		#redis 6380
		
		192.168.140.161		#redis 6379
		
		192.168.140.161		#redis 6380
		
		192.168.140.162		#redis 6379
		
		192.168.140.162		#redis 6380
	
	2，添加redis配置，各台服务器输入命令：
		
		cd /usr/local/redis
		
		cp ./redis.conf redis.6379.conf
		
		cp ./redis.conf redis.6380.conf
	
		vi redis.6379.conf
		
		=>
		
			port 6379
			
			dir "/usr/local/redis/data/6379/"
			
			pidfile /usr/local/redis/bin/6379.pid
			
			logfile /usr/local/redis/log/6379/redis.log
			
			cluster-enabled yes
			
			cluster-config-file /usr/local/redis/cluster/6379/redis.cfg
			
			cluster-node-timeout 10000
			
			appendonly yes
		
		vi redis.6380.conf
		
		=>
		
			port 6380
			
			dir "/usr/local/redis/data/6380/"
			
			pidfile /usr/local/redis/bin/6380.pid
			
			logfile /usr/local/redis/log/6380/redis.log
			
			cluster-enabled yes
			
			cluster-config-file /usr/local/redis/cluster/6380/redis.cfg
			
			cluster-node-timeout 10000
			
			appendonly yes
		
		mkdir -p /usr/local/redis/data/6379/
	
		mkdir -p /usr/local/redis/data/6380/
	
		mkdir -p /usr/local/redis/log/6379/
	
		mkdir -p /usr/local/redis/log/6380/
	
		mkdir -p /usr/local/redis/cluster/6379/
	
		mkdir -p /usr/local/redis/cluster/6380/
		
	3，启动所有redis服务，输入命令：
		
		cd /usr/local/redis
		
		./bin/redis-server ./redis.6379.conf
		
		./bin/redis-server ./redis.6380.conf
		
	4，构建redis集群，输入命令：
		
		cd /usr/local/redis
		
		./bin/redis-cli --cluster create 
			192.168.140.160:6379 192.168.140.160:6380 
			192.168.140.161:6379 192.168.140.161:6380 
			192.168.140.162:6379 192.168.140.162:6380 
			--cluster-replicas 1
		
		./bin/redis-cli --cluster check 192.168.140.160:6379
	
	5，验证主从切换
	
		杀死某台服务器 redis 6379 进程，输入命令：
		
			ps -ef | grep redis
			
			kill pid
		
		查看集群状态，集群变成三主二从，输入命令：
		
			./bin/redis-cli --cluster check 192.168.140.160:6380
		
		启动redis 6379 进程，并查看集群状态，可以看到集群回到三主三从，输入命令：
		
			./bin/redis-server ./redis.6379.conf
			
			./bin/redis-cli --cluster check 192.168.140.160:6380
		
	6，使用 springboot 连接 Cluster 集群 redis 配置示例：
		
		spring.redis.cluster.nodes=192.168.140.160:6379,192.168.140.160:6380,192.168.140.161:6379,192.168.140.161:6380,192.168.140.162:6379,192.168.140.162:6380

### redis集群——Codis

	1，服务器准备
		
		192.168.140.160		# codis-server 服务器一，6379/6380两个进程
		
		192.168.140.161		# codis-server 服务器二，6379/6380两个进程
		
		192.168.140.162		# codis-server 服务器三，6379/6380两个进程
		
		192.168.140.160		# redis-sentinel 服务器一
		
		192.168.140.161		# redis-sentinel 服务器二
		
		192.168.140.162		# redis-sentinel 服务器三
		
		192.168.140.160		# codis-proxy 服务器一
		
		192.168.140.161		# codis-proxy 服务器二
		
		192.168.140.162		# codis-proxy 服务器三
		
		192.168.140.160		# zookeeper 集群服务器一
		
		192.168.140.161		# zookeeper 集群服务器二
		
		192.168.140.162		# zookeeper 集群服务器三
		
		192.168.140.163		# codis-dashboard 服务器
		
		192.168.140.163		# codis-fe 服务器
	
	2，各个组件简单介绍：
		
		codis-server： codis基于redis的分支，增加了额外的数据结构，以支持 slot 有关的操作以及数据迁移指令
		
		redis-sentinel：用于codis-server的主从切换，保证主从高可用
		
		codis-proxy：客户端连接的 Redis 代理服务，实现了大多数 Redis 协议，多个 codis-proxy 一般使用 lvs+keepalived 进行高可用负载均衡
		
		zookeeper：集群状态外部存储
		
		codis-dashboard：集群管理服务
		
		codis-fe：集群可视化管理界面服务
	
	3，所有服务器，配置 golang 运行环境，输入命令：
		
		cd /usr/local/software
	
		curl https://studygolang.com/dl
		
		wget https://dl.google.com/go/go1.11.1.linux-amd64.tar.gz
		
		tar -zxvf ./go1.11.1.linux-amd64.tar.gz
		
		mv ./go ..
		
		mkdir -p /usr/local/progress/src
		
		mkdir -p /usr/local/progress/bin
		
		mkdir -p /usr/local/progress/pkg
		
		vi /etc/profile
		
		=>
	
			export GOROOT=/usr/local/go
			
			export GOPATH=/usr/local/progress
			
			export PATH=$PATH:/usr/local/go/bin:/usr/local/progress/bin
		
		source /etc/profile
		
		go version
		
	4，所有服务器，编译codis，输入命令：
		
		cd /usr/local/software
		
		wget -O codis-3.2.2.tar.gz https://codeload.github.com/CodisLabs/codis/tar.gz/refs/tags/3.2.2
		
		mkdir -p $GOPATH/src/github.com/CodisLabs
		
		cd $GOPATH/src/github.com/CodisLabs
		
		tar -zxvf /usr/local/software/codis-3.2.2.tar.gz -C ./
		
		mv ./codis-3.2.2 codis
		
		cd ./codis
		
		yum install -y autoconf
		
		make
	
	5，所有服务器，配置 codis 安装目录，输入命令：
	
		mkdir -p /usr/local/codis/conf
		
		mkdir -p /usr/local/codis/log/
		
		mkdir -p /usr/local/codis/data/6379/
		
		mkdir -p /usr/local/codis/data/6380/
		
		cd $GOPATH/src/github.com/CodisLabs/codis
		
		cp ./bin -r /usr/local/codis/
		
		cp ./config/* -r /usr/local/codis/conf/
	
	6，三台zookeeper服务器
	
		安装和配置jdk1.8
		
		安装和配置zookeeper三节点集群
	
	7，单台 codis-dashboard 服务器，启动一个 codis-dashboard，注意集群环境中最多只能存在一个，输入命令：
		
		cd /usr/local/codis
		
		./bin/codis-dashboard -h
		
		./bin/codis-dashboard --default-conifg | tee ./conf/dashboard.conf
		
		vim ./conf/dashboard.conf
		
		=>
			
			product_name = "mrh-codis"
			
			product_auth = ""
			
			coordinator_name = "zookeeper"
			
			coordinator_addr = "192.168.140.160:2181,192.168.140.161:2181,192.168.140.162:2181"
			
			admin_addr = "192.168.140.163:18080"
		
		nohup ./bin/codis-dashboard --config=conf/dashboard.conf --log=log/dashboard.log --log-level=WARN &
		
		ps -ef | grep codis-dashboard
		
		tail -f ./log/dashboard.log
				
	8，三台 codis-server 服务器，启动 codis-server，输入命令：
		
		cd /usr/local/codis/conf
		
		cp redis.conf redis-6379.conf
		
		cp redis.conf redis-6380.conf
		
		vi redis-6379.conf
		
		=>
			
			port 6379
			
			pidfile /usr/local/codis/bin/6379.pid
			
			logfile "/usr/local/codis/log/6379.log"
			
			dir /usr/local/codis/data/6379/
			
			appendonly yes
		
		vi redis-6380.conf
		
		=>
			
			port 6380
			
			pidfile /usr/local/codis/bin/6380.pid
			
			logfile "/usr/local/codis/log/6380.log"
			
			dir /usr/local/codis/data/6380/
			
			appendonly yes
		
		cd /usr/local/codis
		
		./bin/codis-server -h
		
		./bin/codis-server conf/redis-6379.conf
		
		./bin/codis-server conf/redis-6380.conf
		
		ps -ef | grep codis-server
	
	9，三台 redis-sentinel 服务器，启动 redis-sentinel，输入命令：
		
		cd /usr/local/codis
		
		vi ./conf/sentinel.conf
		
		=>
			
			#注意，不用配置 sentinel monitor，将监控的主导权交给 codis
			
			protected-mode no
			
			port 26379
			
			dir "/usr/local/codis/data"
			
		nohup ./bin/redis-sentinel conf/sentinel.conf &
		
		ps -ef | grep redis-sentinel
	
	10，三台 codis-proxy 服务器，启动 codis-proxy，输入命令：
		
		cd /usr/local/codis
		
		./bin/codis-proxy -h
		
		./bin/codis-proxy --default-config | tee ./conf/proxy.conf
		
		vi ./conf/proxy.conf
		
		=>
			
			product_name = "mrh-codis"
			
			product_auth = ""
			
			admin_addr = "0.0.0.0:18090"
			
			proto_type = "tcp4"
			
			proxy_addr = "0.0.0.0:16379"
			
			jodis_name = "zookeeper"
			
			jodis_addr = "192.168.140.160:2181,192.168.140.161:2181,192.168.140.162:2181"
			
			jodis_compatible = true
		
		nohup ./bin/codis-proxy --config=conf/proxy.conf --log=log/proxy.log --log-level=WARN &
		
		ps -ef | grep codis-proxy
		
		tail -f log/proxy.log
	
	11，单台 codis-fe 服务器，启动 codis-fe，输入命令：
		
		cd /usr/local/codis
		
		./bin/codis-fe -h
		
		./bin/codis-admin --dashboard-list --zookeeper=192.168.140.160:2181,192.168.140.161:2181,192.168.140.162:2181 | tee ./conf/codis.json
		
		nohup ./bin/codis-fe --ncpu=1 --log=log/fe.log --log-level=WARN --dashboard-list=conf/codis.json --listen=192.168.140.163:8080 &
		
		ps -ef | grep codis-fe
	
	12，使用可视化界面，配置 codis 集群
		
		使用浏览器访问 codis-fe 管理后台地址 http://192.168.140.163:8080/，点开 mrh-codis 进行配置
		
		添加 Proxy 配置，加入以下三个节点：
			
			192.168.140.160:18090
			
			192.168.140.161:18090
			
			192.168.140.162:18090
		
		添加 Server 配置，创建三对主从：
			
			Group 1
				
				192.168.140.160:6379
			
				192.168.140.161:6380
			
			Group 2
			
				192.168.140.161:6379
				
				192.168.140.162:6380
			
			Group 3
			
				192.168.140.162:6379
				
				192.168.140.160:6380
			
		添加 Sentinel 配置，加入以下三个节点：
		
			192.168.140.160:26379
			
			192.168.140.161:26379
			
			192.168.140.162:26379
		
		分配 Slots，点击 Rebalance All slots，分配hash槽
	
	13，使用 springboot 连接 codis
		
		application.properties配置：
		
			spring.redis.host=192.168.140.160
			
			spring.redis.port=16379
		
		代码示例：
			
			@Autowired
			private StringRedisTemplate redisTemplate;
			
			@GetMapping(path="/")
			@ResponseBody
			public String index() {
				
				String key = UUID.randomUUID().toString();
				
				redisTemplate.opsForValue().set(key, "1");
				
				System.out.println(key + " : " + redisTemplate.opsForValue().get(key));
				
				return "success";
			}


