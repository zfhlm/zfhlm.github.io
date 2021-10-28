
# 集群配置elasticsearch

#### 服务器准备

	192.168.140.193		#节点一
	
	192.168.140.194		#节点二
	
	192.168.140.195		#节点三
	
	三台服务器根据 Part1 进行单点配置
	
	注意：elasticsearch 集群节点数一般三台以上，总服务器数应该配置为奇数

#### 配置集群

	输入命令：
		
		cd /usr/local/elasticsearch
		
		vi ./config/elasticsearch.yml
	
	节点一加入以下配置：
		
		#集群名称
		cluster.name: mrh-elastic-cluster
		
		#集群节点列表
		discovery.seed_hosts: ["192.168.140.193:9300", "192.168.140.194:9300", "192.168.140.195:9300"]
		
		#集群候选主节点
		cluster.initial_master_nodes: ["192.168.140.193:9300", "192.168.140.194:9300", "192.168.140.195:9300"]
		
		#节点名称
		node.name: elastic-193
		
		#监听IP地址
		network.host: 192.168.140.193
		
		#监听端口
		http.port: 9200
		
		#日志输出目录
		path.logs: /var/log/elasticsearch
		
		#数据存储目录
		path.data: /var/data/elasticsearch
		
		#内存锁定是否开启(服务器资源充足时开启，OOM也不允许内存交换)
		bootstrap.memory_lock: false
		
		#开启自动创建索引
		action.auto_create_index: .monitoring*,.watches,.triggered_watches,.watcher-history*,.ml*, logstash-*
		
		#禁用安全验证(收费)
		xpack.security.enabled: false
		
	节点二加入以下配置：
		
		#集群名称
		cluster.name: mrh-elastic-cluster
		
		#集群节点列表
		discovery.seed_hosts: ["192.168.140.193:9300", "192.168.140.194:9300", "192.168.140.195:9300"]
		
		#集群候选主节点
		cluster.initial_master_nodes: ["192.168.140.193:9300", "192.168.140.194:9300", "192.168.140.195:9300"]
		
		#节点名称
		node.name: elastic-194
		
		#监听IP地址
		network.host: 192.168.140.194
		
		#监听端口
		http.port: 9200
		
		#日志输出目录
		path.logs: /var/log/elasticsearch
		
		#数据存储目录
		path.data: /var/data/elasticsearch
		
		#内存锁定是否开启(服务器资源充足时开启，OOM也不允许内存交换)
		bootstrap.memory_lock: false
		
		#开启自动创建索引
		action.auto_create_index: .monitoring*,.watches,.triggered_watches,.watcher-history*,.ml*, logstash-*
		
		#禁用安全验证(收费)
		xpack.security.enabled: false
		
	节点三加入以下配置：
		
		#集群名称
		cluster.name: mrh-elastic-cluster
		
		#集群节点列表
		discovery.seed_hosts: ["192.168.140.193:9300", "192.168.140.194:9300", "192.168.140.195:9300"]
		
		#集群候选主节点
		cluster.initial_master_nodes: ["192.168.140.193:9300", "192.168.140.194:9300", "192.168.140.195:9300"]
		
		#节点名称
		node.name: elastic-195
		
		#监听IP地址
		network.host: 192.168.140.195
		
		#监听端口
		http.port: 9200
		
		#日志输出目录
		path.logs: /var/log/elasticsearch
		
		#数据存储目录
		path.data: /var/data/elasticsearch
		
		#内存锁定是否开启(服务器资源充足时开启，OOM也不允许内存交换)
		bootstrap.memory_lock: false
		
		#开启自动创建索引
		action.auto_create_index: .monitoring*,.watches,.triggered_watches,.watcher-history*,.ml*, logstash-*
		
		#禁用安全验证(收费)
		xpack.security.enabled: false

#### 启动集群

	各个节点输入命令：
	
		su - elastic
		
		cd /usr/local/elasticsearch
		
		./bin/elasticsearch -d
	
	查看 elasticsearch 运行状态，输入命令：
		
		curl http://192.168.140.195:9200/
		
		curl http://192.168.140.195:9200/_cat/health?v


