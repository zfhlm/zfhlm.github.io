
#### 下载安装包

	准备好安装文件：apache-zookeeper-3.6.1-bin.tar.gz
	
	远程root账号登录，上传到服务器：/usr/local/backup/

#### 解压安装

	输入命令：
	
		cd /usr/local/
		
		tar -zxvf ./backup/apache-zookeeper-3.6.1-bin.tar.gz ./
	
	创建软引用：
	
		ln -s apache-zookeeper-3.6.1-bin zookeeper

#### 配置修改

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

#### 配置调优

	1，调整zookeeper JVM内存占用大小，在配置文件目录conf下新建java.env，加入以下内容：
	
		#!/bin/sh
		export JAVA_HOME=/usr/java/jdk
		export JVMFLAGS="-Xms512m -Xmx1024m $JVMFLAGS"
	
	2，调整日志输出，按天出zookeeper日志，zkEnv.sh文件日志输出方式从CONSOLE改为ROLLINGFILE；
		
		if [ "x${ZOO_LOG4J_PROP}" = "x" ]
		then
		#   ZOO_LOG4J_PROP="INFO,CONSOLE"
		    ZOO_LOG4J_PROP="INFO,ROLLINGFILE"
		fi
	
	3，调整日志级别，配置文件log4j.properties更改：
	
		zookeeper.root.logger=INFO, ROLLINGFILE
		log4j.appender.ROLLINGFILE=org.apache.log4j.DailyRollingFileAppender
		log4j.appender.ROLLINGFILE.Threshold=${zookeeper.log.threshold}
		log4j.appender.ROLLINGFILE.File=${zookeeper.log.dir}/${zookeeper.log.file}
		log4j.appender.ROLLINGFILE.DatePattern='.'yyyy-MM-dd
	
	4，zoo.cfg配置优化：
		
		tickTime=2000						#维持心跳的时间间隔
		initLimit=5							#主从之间初始连接时能容忍的最多心跳数
		syncLimit=10						#主从之间请求和应答之间能容忍的最多心跳数
		maxClientCnxns=2000					#客户端最大连接数
		autopurge.snapRetainCount=10		#保留的文件数目，默认3个
		autopurge.purgeInterval=1			#自动清理snapshot和事务日志，清理频率，单位是小时
		globalOutstandingLimit=200			#等待处理的最大请求数量
		leaderServes=yes					#leader是否接受client请求

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
