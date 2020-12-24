
#### 下载安装包

	准备好安装文件：apache-zookeeper-3.6.1-bin.tar.gz
	
	远程root账号登录，上传到服务器：/usr/local/backup/

#### 解压安装

	输入命令：
	
		cd /usr/local/
		
		tar -zxvf ./backup/apache-zookeeper-3.6.1-bin.tar.gz ./
	
	创建软引用：
	
		ln -s apache-zookeeper-3.6.1-bin zookeeper

#### 修改配置

	进入配置目录：
	
		cd ./zookeeper/config/
	
	修改日志级别：
	
		vi log4j.properties
	
		=> 
		
			zookeeper.root.logger=WARN
		
	修改zk配置：
	
		cp zoo_sample.cfg zoo.cfg
		
		vi zoo.cfg
		
		=> 
		
			dataDir=/usr/local/zookeeper/data
			logDir=/usr/local/zookeeper/logs
			admin.serverPort=18080

#### 启动测试

	启动命令：
	
		cd /usr/local/zookeeper/
	
		./bin/zkServer.sh start
	
	查看状态：
	
		./bin/zkServer.sh status
	
	停止命令
	
		./bin/zkServer.sh stop

#### 配置集群

	假设有三台服务器，按照单点方式配置zookeeper并成功运行：
	
		192.168.0.1、192.168.0.2、192.168.0.3
	
	配置 192.168.0.1 节点信息：
	
		cd ./data/
		
		echo 1 > myid
		
	配置 192.168.0.2 节点信息：
	
		cd ./data/
		
		echo 2 > myid
		
	配置 192.168.0.3 节点信息：
	
		cd ./data/
		
		echo 3 > myid
	
	修改配置文件：
	
		vi /usr/local/zookeeper/conf/zoo.cfg
		
		=> 
					
			server.1=192.168.0.1:2888:3888
			server.2=192.168.0.2:2888:3888
			server.3=192.168.0.3:2888:3888

#### 启动集群

	各自启动：
	
		cd /usr/local/zookeeper/
		
		./bin/zkServer.sh start
	
	查看状态：
	
		./bin/zkServer.sh status
		
	可以看到一个leader节点、两个follower节点，集群安装成功.

