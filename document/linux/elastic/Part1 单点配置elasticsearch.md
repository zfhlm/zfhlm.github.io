
# 单点配置elasticsearch

#### 下载安装包

	官方文档：https://www.elastic.co/guide/en/elasticsearch/reference/7.15/getting-started.html
	
	下载地址：https://www.elastic.co/cn/downloads/past-releases#elasticsearch
	
	下载安装包：elasticsearch-7.15.1-linux-x86_64.tar.gz
	
	上传到服务器目录：/usr/local/software

#### 服务器准备

	192.168.140.193
	
	使用单台服务器进行单点配置

#### 解压启动

	配置依赖运行环境JDK1.8：
	
		(略)
	
	解压安装包，输入命令：
		
		cd /usr/local/software
		
		tar -zxvf ./elasticsearch-7.15.1-linux-x86_64.tar.gz
		
		mv ./elasticsearch-7.15.1 ..
		
		cd ..
		
		ln -s ./elasticsearch-7.15.1 elasticsearch
	
	创建启动用户，输入命令：
		
		cd /usr/local
		
		useradd elastic
	
		passwd elastic
		
		chown -R elastic:elastic ./elasticsearch
		
		chown -R elastic:elastic ./elasticsearch-7.15.1
		
		cd /usr/local/elasticsearch
	
	启动 elasticsearch，输入命令：
		
		su - elastic
		
		cd /usr/local/elasticsearch
		
		./bin/elasticsearch --help
		
		# 前台进程启动
		./bin/elasticsearch
		
		# 后台进程启动
		./bin/elasticsearch -d
		
	查看 elasticsearch 运行状态，输入命令：
		
		curl http://192.168.140.195:9200/
		
		curl http://192.168.140.195:9200/_cat/health?v

#### 更改服务器配置
	
	修改文件句柄限制，输入命令：
		
		vi /etc/security/limits.conf
		
		=>
			
			* soft nofile 65535
			* hard nofile 65535
			
	修改进程数量限制，输入命令：
		
		vi /etc/security/limits.conf
		
		=>
			
			* soft nproc 4096
			* hard nproc 4096
			
		vi /etc/security/limits.d/20-nproc.conf
		
		=>
			
			*    soft nproc 4096
			root soft nproc unlimited
	
	允许内存锁定，输入命令：
		
		vi /etc/security/limits.conf
		
		=>
			
			* soft memlock unlimited
			* hard memlock unlimited
			
	调整虚拟内存配置，输入命令：
		
		vi /etc/sysctl.conf 
		
		=>
			
			#趋向于不使用虚拟内存
			vm.swappiness=1
			#最大虚拟内存区域数
			vm.max_map_count=262144
			
		sysctl -p
	
	禁用虚拟内存(服务器资源充足时开启，OOM也不允许内存交换)，输入命令：
	
		vi /etc/fstab
		
		=>
			
			(注释所有包含swap字段的行配置)

#### 更改运行配置

	更改 elasticsearch 堆内存大小，官方建议不超过服务器50%内存，输入命令：
		
		su - elastic
		
		cd /usr/local/elasticsearch
		
		vi ./config/jvm.options.d/jvm.options
		
		=> 
			
			# 堆内存最小值
			-Xms2g
			
			# 堆内存最大值
			-Xmx2g
		
	创建 elasticsearch 相关存储目录，输入命令：
		
		su - root
		
		mkdir -p /var/log/elasticsearch
		
		mkdir -p /var/data/elasticsearch
		
		chown -R elastic:elastic /var/log/elasticsearch
		
		chown -R elastic:elastic /var/data/elasticsearch
		
	更改 elasticsearch 运行配置，输入命令：
		
		su - elastic
		
		cd /usr/local/elasticsearch
		
		vi ./config/elasticsearch.yml
		
		=>
			
			#集群名称
			cluster.name: mrh-elastic-cluster
			
			#集群单节点模式(多节点移除此配置)
			discovery.type: single-node
			
			#集群节点列表
			discovery.seed_hosts: ["192.168.140.193:9300"]
			
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
			
			#自动创建索引
			action.auto_create_index: .monitoring*,.watches,.triggered_watches,.watcher-history*,.ml*,logstash*,app*

#### 设置索引分片和副本

	elasticsearch 默认分片数为1，副本数为1，在单节点的情形下创建索引，因为无法设置副本，查询节点状态会变为 yellow
	
	假如需要将名称匹配 logstash-* 的索引副本设置为0，发送http请求：
		
		curl -X PUT 192.168.140.193:9200/_template/log  -H 'Content-Type: application/json' -d '{
			"template": "logstash-*",
			"settings": {
				"number_of_shards": 1,
				"number_of_replicas": 0
			}
		}'
		
	假如需要将名称匹配 app-* 的索引副本设置为2，发送http请求：
		
		curl -X PUT 192.168.140.193:9200/_template/log  -H 'Content-Type: application/json' -d '{
			"template": "app-*",
			"settings": {
				"number_of_shards": 1,
				"number_of_replicas": 2
			}
		}'
	

