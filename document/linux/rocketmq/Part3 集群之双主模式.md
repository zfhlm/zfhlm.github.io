
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


