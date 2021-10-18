
#### 下载安装包

	文档地址：https://rocketmq.apache.org/docs/quick-start/
	
	下载地址：https://github.com/apache/rocketmq/releases
	
	下载安装包：rocketmq-rocketmq-all-4.9.1.tar.gz
	
	上传到服务器目录：/usr/local/software

#### 安装配置rocketmq

	1，环境准备
		
		安装配置好jdk-1.8
		
		安装配置好maven-3.8.3
	
	2，解压编译
	
		输入命令：
		
			cd /usr/local/software
			
			tar -zxvf ./rocketmq-rocketmq-all-4.9.1.tar.gz
			
			cd rocketmq-rocketmq-all-4.9.1
			
			mvn -Prelease-all -DskipTests clean install -U
			
			cd ./distribution/target/rocketmq-4.9.1
			
			mv ./rocketmq-4.9.1/ /usr/local/
			
			cd /usr/local
			
			ln -s ./rocketmq-4.9.1 rocketmq
			
			cd /usr/local/software/
			
			rm -rf ./rocketmq-rocketmq-all-4.9.1
		
	3，启动 Name Server
	
		输入命令：
		
			cd /usr/local/rocketmq
			
			nohup sh bin/mqnamesrv &
			
			tail -f ~/logs/rocketmqlogs/namesrv.log
	
	4，启动 Broker
	
		输入命令：
		
			cd /usr/local/rocketmq
		
			nohup sh bin/mqbroker -n localhost:9876 &
			
			tail -f ~/logs/rocketmqlogs/broker.log
	
	5，停止 Name Server 和 Broker
	
		输入命令：
		
			cd /usr/local/rocketmq
		
			sh bin/mqshutdown broker
			
			sh bin/mqshutdown namesrv
	
	6，调整JVM内存占用
	
		输入命令：
			
			cd /usr/local/rocketmq
			
			vi ./bin/runserver.sh
		
		修改以下内容，调整合适参数：
		
			JAVA_OPT="${JAVA_OPT} -server -Xms4g -Xmx4g -Xmn2g -XX:MetaspaceSize=128m -XX:MaxMetaspaceSize=320m"
		
		输入命令：
		
			cd /usr/local/rocketmq
			
			vi ./bin/runbroker.sh
		
		修改以下内容，调整合适参数：
			
			JAVA_OPT="${JAVA_OPT} -server -Xms8g -Xmx8g"
	
	7，配置Broker
	
		配置文件官方文档：http://rocketmq.apache.org/docs/rmq-deployment/
		
		修改配置文件，输入命令：
		
			cd /usr/local/rocketmq
			
			vi conf/broker.conf
		
		配置参数含义：
	
			namesrvAddr					#NameServer地址，多个用分号隔开
			
			brokerClusterName				#Broker所属集群名称，同一集群名称一致
			
			brokerName					#Broker名称，主备名称一致
			
			brokerId					#0为Master，大于0为 Slave，Slave多个可以不同数值进行区别
			
			listenPort					#监听的端口
			
			brokerIP1					#IP地址，多个分号隔开
			
			storePathCommitLog				#提交日志保存目录
			
			storePathConsumerQueue				#队列消费记录保存目录
			
			mapedFileSizeCommitLog				#mapped file文件大小
			
			deleteWhen					#当天几点删除过期提交日志
			
			fileReserverdTime				#提交日志过期时间小时
			
			brokerRole					#Broker角色，可选 SYNC_MASTER/ASYNC_MASTER/SLAVE
			
			flushDiskType					#刷盘策略，可选 SYNC_FLUSH/ASYNC_FLUSH

#### 可视化控制台

	1，下载源码包
	
		下载地址：https://github.com/apache/rocketmq-dashboard/releases/
		
		下载包：rocketmq-dashboard-rocketmq-dashboard-1.0.0.tar.gz
		
		上传到服务器目录：/usr/local/software
	
	2，解压编译
	
		输入命令：
		
			cd /usr/local/software
			
			tar -zxvf ./rocketmq-dashboard-rocketmq-dashboard-1.0.0.tar.gz
			
			cd ./rocketmq-dashboard-rocketmq-dashboard-1.0.0
			
			mvn clean package -Dmaven.test.skip=true
			
			mkdir /usr/local/dashboard-rocketmq/
			
			mv ./target/rocketmq-dashboard-1.0.0.jar /usr/local/dashboard-rocketmq/
			
	3，启动
	
		输入命令：
		
			cd /usr/local/dashboard-rocketmq/
			
			nohup java -jar rocketmq-dashboard-1.0.0.jar &
			
	4，修改配置
	
		更改jar配置文件：
	
			rocketmq-dashboard-1.0.0.jar/BOOT-INF/classes/application.properties

#### 集群-双主模式

	单个节点出现故障，集群仍可使用，故障节点未被消费的消息在机器恢复之前不可订阅，出现磁盘故障丢失消息
	
	1，服务器准备
	
		Broker Master1    192.168.140.156
		
		Broker Master2    192.168.140.157
		
		Name Server1      192.168.140.156
		
		Name Server2      192.168.140.157
	
	2，分别修改 Broker 配置
	
		brokerClusterName=rocketmq-cluster
		brokerName=broker-node1
		brokerId=0
		namesrvAddr=192.168.140.156:9876;192.168.140.157:9876
		
		brokerClusterName=rocketmq-cluster
		brokerName=broker-node2
		brokerId=0
		namesrvAddr=192.168.140.156:9876;192.168.140.157:9876
	
	3，启动 Broker 和 Name Server
		
		nohup sh bin/mqnamesrv &
		
		nohup sh bin/mqbroker &

#### 集群-多主多从模式

	异步复制：主备有短暂消息延迟，出现磁盘故障消息丢失的非常少，且消息实时性不会受影响
	
	同步双写：只有主备都写成功，才向应用返回成功，消息与服务都无单点故障，性能略低
	
	1，服务器准备
		
		Broker Master1    192.168.140.156
		
		Broker Slave1     192.168.140.157
		
		Broker Master2    192.168.140.158
		
		Broker Slave2     192.168.140.159
		
		Name Server1      192.168.140.157
		
		Name Server2      192.168.140.159
	
	2，分别修改 Broker Master 配置
		
		brokerClusterName=rocketmq-cluster
		brokerName=broker-node1
		brokerId=0
		namesrvAddr=192.168.140.157:9876;192.168.140.159:9876
		brokerRole=ASYNC_MASTER
		
		brokerClusterName=rocketmq-cluster
		brokerName=broker-node2
		brokerId=0
		namesrvAddr=192.168.140.157:9876;192.168.140.159:9876
		brokerRole=ASYNC_MASTER
		
	3，分别修改 Broker Slave 配置
		
		brokerClusterName=rocketmq-cluster
		brokerName=broker-node1
		brokerId=1
		namesrvAddr=192.168.140.157:9876;192.168.140.159:9876
		brokerRole=SLAVE
		
		brokerClusterName=rocketmq-cluster
		brokerName=broker-node2
		brokerId=1
		namesrvAddr=192.168.140.157:9876;192.168.140.159:9876
		brokerRole=SLAVE
	
	3，启动 Broker 和 Name Server
		
		nohup sh bin/mqnamesrv &
		
		nohup sh bin/mqbroker &
	
	4，同步双写和异步复制
		
		两者配置的区别在于 Broker Master 节点 brokerRole 配置不同：
			
			brokerRole=SYNC_MASTER		#同步双写
			
			brokerRole=ASYNC_MASTER		#异步复制


