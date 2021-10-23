
# Mysql集群 分布式架构MNC

	MySQL NDB Cluster，一个 MNC 集群由若干管理节点、若干数据节点和若干 SQL 节点组成
	
	管理节点：对 SQL 节点和数据节点进行配置管理，可以设置为1个到多个
		
	数据节点：
		
		集群数据存取节点，多个节点组成一个分组，集群中可以有多个分组
		
		在同个分组中，数据节点数量必须能被 NoOfReplicas 参数整除，例如：
		
			同分组数据节点数=2，则 NoOfReplicas ∈ {1, 2}
		
			同分组数据节点数=3，则 NoOfReplicas ∈ {1, 3}
		
			同分组数据节点数=4，则 NoOfReplicas ∈ {1, 2, 4}
		
		一般配置2个数据节点为同一个组，配置 NoOfReplicas=2
		
		如果配置不正确，启动管理节点会报类似错误：Nodegroup 1 has 1 members, NoOfReplicas=2
		
	SQL节点：对外提供数据访问

#### 下载安装包

	下载地址：https://dev.mysql.com/downloads/cluster/
	
	下载安装包：mysql-cluster-8.0.27-linux-glibc2.12-x86_64.tar.gz
	
	上传到服务器目录：/usr/local/software
	
	管理节点官方文档地址：
	
		https://dev.mysql.com/doc/refman/8.0/en/mysql-cluster-mgm-definition.html
		
		https://dev.mysql.com/doc/refman/8.0/en/mysql-cluster-ndbd-definition.html
	
	数据节点官方文档地址：
		
		https://dev.mysql.com/doc/refman/8.0/en/mysql-cluster-install-configuration.html

#### 服务器准备

	192.168.140.178		# 数据节点
	
	192.168.140.179		# 数据节点
	
	192.168.140.180		# 管理节点、SQL节点
	
	192.168.140.181		# 管理节点、SQL节点
	
	搭建 2个管理节点、2个 SQL 节点、2个数据节点为同分组的 MNC 集群

#### 初始化安装

	解压安装包，输入命令：
		
		yum -y remove mariadb*
		
		cd /usr/local/software
		
		tar ./mysql-cluster-8.0.27-linux-glibc2.12-x86_64.tar.gz
		
		mv ./mysql-cluster-8.0.27-linux-glibc2.12-x86_64 ../mysql-cluster-8.0.27
		
		cd ..
		
		ln -s ./mysql-cluster-8.0.27 mysql
	
	创建运行用户，输入命令：
		
		groupadd mysql
		
		useradd -r -s /sbin/nologin -g mysql mysql -d /usr/local/mysql/
		
		chown -R mysql:mysql mysql && chown -R mysql:mysql mysql-cluster-8.0.27/
		
	初始化数据库，输入命令：
		
		cd /usr/local/software
		
		./bin/mysqld --initialize --user=mysql --basedir=/usr/local/mysql --datadir=/usr/local/mysql/data
		
		cp -a ./support-files/mysql.server /etc/init.d/mysqld

#### 配置管理节点

	管理节点修改配置文件，输入命令：
		
		mkdir -p /usr/local/mysql/data/mgnd
		
		mkdir -p /usr/local/mysql/log/
		
		chown -R mysql:mysql /usr/local/mysql/
	
		vi /etc/mgnd.cnf
		
	添加以下配置内容：
		
		[ndb_mgmd default]
		PortNumber=1186                                                                          #管理节点默认监听端口
		DataDir=/usr/local/mysql/data/mgnd                                                       #管理节点默认存储目录
		ArbitrationRank=1                                                                        #管理节点默认指定为决策者
		LogDestination=FILE:filename=/usr/local/mysql/log/mgnd.log,maxsize=1000000,maxfiles=6    #管理节点默认日志配置
		
		[ndbd default]
		ServerPort=2202                                                                          #数据节点默认端口
		NoOfReplicas=2                                                                           #数据节点默认冗余备份数
		DataMemory=100M                                                                          #数据节点默认数据内存大小
		IndexMemory=100M                                                                         #数据节点默认索引内存大小
		DataDir=/usr/local/mysql/data                                                            #数据节点默认存储目录
		
		[ndb_mgmd]
		NodeId=180                                                                               #管理节点一ID
		HostName=192.168.140.180                                                                 #管理节点一IP地址
		
		[ndb_mgmd]
		NodeId=181                                                                               #管理节点ID
		HostName=192.168.140.181                                                                 #管理节点二IP地址
		
		[ndbd]
		NodeId=1                                                                                 #数据节点一ID
		NodeGroup=1                                                                              #数据节点一分组
		HostName=192.168.140.178                                                                 #数据节点一IP地址
		
		[ndbd]
		NodeId=2                                                                                 #数据节点二ID
		NodeGroup=1                                                                              #数据节点二分组
		HostName=192.168.140.179                                                                 #数据节点二IP地址
		
		[mysqld]
		NodeId=100                                                                               #SQL节点一ID
		HostName=192.168.140.180                                                                 #SQL节点一IP地址
		
		[mysqld]
		NodeId=101                                                                               #SQL节点二ID
		HostName=192.168.140.181                                                                 #SQL节点二IP地址

#### 配置数据节点

	数据节点修改配置文件，输入命令：
	
		

#### 配置SQL节点
	
	
	
#### 启动管理节点

	管理节点分别启动，输入命令：
		
		cd /usr/local/mysql
		
		./bin/ndb_mgmd -f /etc/mgnd.cnf
	
	管理节点查看各节点状态，输入命令：
		
		./bin/ndb_mgm
		
		show
	
	管理节点可以看到控制台输出：
		
		Connected to Management Server at: localhost:1186
		Cluster Configuration
		---------------------
		[ndbd(NDB)]	2 node(s)
		id=1 (not connected, accepting connect from 192.168.140.178)
		id=2 (not connected, accepting connect from 192.168.140.179)
		
		[ndb_mgmd(MGM)]	2 node(s)
		id=180	@192.168.140.180  (mysql-8.0.27 ndb-8.0.27)
		id=181	@192.168.140.181  (mysql-8.0.27 ndb-8.0.27)
		
		[mysqld(API)]	2 node(s)
		id=100 (not connected, accepting connect from 192.168.140.180)
		id=101 (not connected, accepting connect from 192.168.140.181)

#### 启动数据节点

	
	
	
	

	
	
	
	
	
	
	
	