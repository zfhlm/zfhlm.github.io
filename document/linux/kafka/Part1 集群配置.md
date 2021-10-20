
#### 集群配置

	1，服务器准备
		
		192.168.140.141
		
		192.168.140.142
		
		192.168.140.143
	
		提前配置好jdk1.8和zookeeper三节点集群
		
		下载 kafka 安装包，地址：http://kafka.apache.org/downloads
		
		上传到服务器目录 /usr/local/software
	
	2，解压kafka安装包，输入命令：
			
		cd /usr/local/software
		
		tar -zxvf ./kafka_2.13-3.0.0.tgz
		
		mv ./kafka_2.13-3.0.0 ../
		
		cd /usr/local
		
		ln -s kafka_2.13-3.0.0/ kafka
	
	3，更改 kafka 配置文件，输入命令：
		
		vi server.properties
		
		=> 192.168.140.141
		
			broker.id=1
			listeners=PLAINTEXT://192.168.140.141:9092
			log.dirs=/usr/local/kafka/kafka-logs
			zookeeper.connect=192.168.140.141:2181,192.168.140.142:2181,192.168.140.143:2181
		
		=> 192.168.140.142
		
			broker.id=2
			listeners=PLAINTEXT://192.168.140.142:9092
			log.dirs=/usr/local/kafka/kafka-logs
			zookeeper.connect=192.168.140.141:2181,192.168.140.142:2181,192.168.140.143:2181
		
		=> 192.168.140.143
		
			broker.id=3
			listeners=PLAINTEXT://192.168.140.143:9092
			log.dirs=/usr/local/kafka/kafka-logs
			zookeeper.connect=192.168.140.141:2181,192.168.140.142:2181,192.168.140.143:2181
		
	4，启动kafka，输入命令：
		
		cd /usr/local/kafka
	
		nohup ./bin/kafka-server-start.sh ./config/server.properties &
	
	5，常用优化配置
		
		线程IO：
			
			num.network.threads=3					#broker处理网络请求的线程数，建议CPU核数+1
			num.io.threads=8					#broker处理磁盘IO的线程数，建议CPU核数*2
			
		刷盘策略：
			
			log.flush.interval.messages=10000			#每写入10000条消息刷数据到磁盘
			log.flush.interval.ms=1000				# 每间隔1秒刷数据到磁盘
		
		日志保留策略：
			
			log.retention.hours=72					#消息数据的存留小时
			log.retention.bytes=-1					#消息存储最大占用空间byte，-1不限制
		
		主从复制策略：
		
			num.replica.fetchers=3					#拉取线程数
			replica.fetch.min.bytes=1				#拉取最小字节数
			replica.fetch.max.bytes=5242880				#拉取最大字节数，默认1M，需要可调大
			replica.fetch.wait.max.ms=1000				#拉取最大时间间隔，默认即可
		
		消息可靠策略：
		
			delete.topic.enable=true				#是否允许删除topic
			num.partitions=2					#每个topic的默认分区个数
			min.insync.replicas=2					#broker端必须成功响应client消息发送的最小副本数
			message.max.bytes=					#接受的消息最大byte数


