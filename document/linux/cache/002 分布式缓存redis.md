
#### 下载安装包

	官方文档：https://redis.io/documentation
	
	下载地址：https://redis.io/download
	
	下载包：redis-6.2.6.tar.gz
	
	上传到服务器目录：/usr/local/software

#### 安装redis

	编译安装，输入命令：
	
		cd /usr/local/software
		
		tar -zxvf ./redis-6.2.6.tar.gz
		
		cd ./redis-6.2.6
		
		make PREFIX=/usr/local/redis install
		
		cp ./redis.conf /usr/local/redis/
		
		cd ..
		
		rm -rf redis-6.2.6
	
	修改redis配置文件，输入命令：
	
		cd /usr/local/redis
		
		vi redis.conf
	
	更改以下配置：
		
		bind 127.0.0.1  192.168.140.160				#监听主机地址
		
		port 6379											#监听端口
		
		requirepass 123456								#配置使用密码
		
		daemonize yes                      			#启用守护进程
		
		pidfile /usr/local/redis/bin/redis.pid		#指定PID文件
		
		loglevel notice									#日志级别
		
		logfile /usr/local/redis/logs/redis.log		#日志位置
		
		dir /usr/local/redis/data						#本地数据库存放目录
		
		dbfilename dump.rdb								#本地数据库文件名
		
		activerehashing yes								#是否激活重置哈希
		
		rdbcompression yes								#是否储存启用压缩
		
		save 900 1										#RDB配置，每900秒至少有1个key发生变化，dump内存快照
		
		save 300 10										#RDB配置，每300秒至少有10个key发生变化，dump内存快照
		
		save 60 1000										#RDB配置，每60秒至少有10000个key发生变化，dump内存快照
				
		appendonly yes                     			#AOF配置，是否开启AOF持久化
		
		appendfilename "appendonly.aof"    			#AOF配置，AOF日志文件名
		
		appendfsync always                 			#AOF配置，每次有数据变动写入AOF文件，可选值 always/everysec/no
	
	启动redis，输入命令：
	
		cd /usr/local/redis
		
		./bin/redis-server ./redis.conf

#### 主从复制



















