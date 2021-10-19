
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

#### 界面管理工具cmak

	1，下载 cmak：
	
		https://github.com/yahoo/CMAK/releases
		
		下载安装包：cmak-3.0.0.5.zip
		
		上传到 192.168.140.141 服务器
	
	2，解压安装包，输入命令：
		
		cd /usr/local/software
		
		unzip ./cmak-3.0.0.5.zip
		
		mv ./cmak-3.0.0.5 /usr/local
		
		cd /usr/local
		
		ln -s ./cmak-3.0.0.5 cmak
			
	3，更改配置，输入命令：
		
		cd /usr/local/cmak/conf
		
		vi application.conf
		
		=>
			
			kafka-manager.zkhosts="192.168.140.141:2181,192.168.140.142:2181,192.168.140.143:2181"
			cmak.zkhosts="192.168.140.141:2181,192.168.140.142:2181,192.168.140.143:2181"
	
	4，指定运行jdk版本
	
		官方最新版本需要jdk11及以上版本，如果服务器版本更低，需要下载jdk然后指定版本运行
		
		下载jdk11并解压，输入命令：
		
			cd /usr/local/software
			
			tar -zxvf jdk-11.0.12_linux-x64_bin.tar.gz
			
			mv ./jdk-11.0.12 /usr/local
			
			ln -s ./jdk-11.0.12 jdk11
		
		更改 cmak 启动脚本，输入命令：
		
			cd /usr/local/cmak/bin
			
			vi cmak
			
			=>
			
				export JAVA_HOME=/usr/local/jdk11/
				export JRE_HOME=${JAVA_HOME}/jre
				export CLASSPATH=.:${JAVA_HOME}/lib:${JRE_HOME}/lib
				export PATH=.:${JAVA_HOME}/bin:$PATH
		
	5，启动cmak，输入命令：
		
		cd /usr/local/cmak/bin
		
		./cmak
	
	6，添加需要管理的kafka集群：
	
		访问web页面 http://192.168.140.141:9000/
	
		点击界面【Cluster】
		
		选择【Add Cluster】
		
		输入创建信息：
		
			【Cluster Name】：kafka集群名称
			
			【Cluster Zookeeper Hosts】：kafka集群地址，例如 192.168.140.141:2181,192.168.140.142:2181,192.168.140.143:2181
			
			【Kafka Version】：kafka版本
			
			【Enable JMX Polling】：按需开启，如果开启则kafka必须开启JMX功能，这样可以获取更多信息
			
			其他信息按需配置
		
		点击【Save】提交保存
		
		回到监控界面，查看和管理kafka集群


