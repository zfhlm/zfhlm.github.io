
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
	
	配置文件官方文档地址：
		
		https://dev.mysql.com/doc/refman/8.0/en/mysql-cluster-mgm-definition.html
		
		https://dev.mysql.com/doc/refman/8.0/en/mysql-cluster-ndbd-definition.html
		
		https://dev.mysql.com/doc/refman/8.0/en/mysql-cluster-install-configuration.html

#### 服务器准备

	192.168.140.178		# 数据节点
	
	192.168.140.179		# 数据节点
	
	192.168.140.180		# 管理节点、SQL节点
	
	192.168.140.181		# 管理节点、SQL节点
	
	搭建 2个管理节点、2个 SQL 节点、2个数据节点同分组的 MNC 集群

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
		
		chown -R mysql:mysql mysql
		
		chown -R mysql:mysql mysql-cluster-8.0.27/

#### 配置管理节点

	管理节点修改配置文件，输入命令：
		
		mkdir -p /usr/local/mysql/mgmd/{data,log}
		
		chown -R mysql:mysql /usr/local/mysql/
		
		vi /etc/mgmd.cnf
		
	添加以下配置内容：
		
		[ndb_mgmd default]
		PortNumber=1186                                                                             #管理节点默认监听端口
		DataDir=/usr/local/mysql/mgmd/data                                                          #管理节点默认存储目录
		ArbitrationRank=1                                                                           #管理节点默认指定为决策者
		LogDestination=FILE:filename=/usr/local/mysql/mgmd/log/mgmd.log,maxsize=1000000,maxfiles=6  #管理节点默认日志配置
		
		[ndbd default]
		ServerPort=2202                                                                          #数据节点默认端口
		NoOfReplicas=2                                                                           #数据节点默认冗余备份数
		DataMemory=100M                                                                          #数据节点默认数据内存大小
		IndexMemory=100M                                                                         #数据节点默认索引内存大小
		DataDir=/usr/local/mysql/ndbd/data                                                       #数据节点默认存储目录
		
		[ndb_mgmd]
		NodeId=180                                                                               #管理节点一ID
		HostName=192.168.140.180                                                                 #管理节点一IP地址
		
		[ndb_mgmd]
		NodeId=181                                                                               #管理节点ID
		HostName=192.168.140.181                                                                 #管理节点二IP地址
		
		[ndbd]
		NodeId=1                                                                                 #数据节点一ID
		NodeGroup=0                                                                              #数据节点一分组
		HostName=192.168.140.178                                                                 #数据节点一IP地址
		
		[ndbd]
		NodeId=2                                                                                 #数据节点二ID
		NodeGroup=0                                                                              #数据节点二分组
		HostName=192.168.140.179                                                                 #数据节点二IP地址
		
		[mysqld]
		NodeId=100                                                                               #SQL节点一ID
		HostName=192.168.140.180                                                                 #SQL节点一IP地址
		
		[mysqld]
		NodeId=101                                                                               #SQL节点二ID
		HostName=192.168.140.181                                                                 #SQL节点二IP地址

#### 配置数据节点

	数据节点修改配置文件，输入命令：
		
		vi /etc/my.cnf
	
	添加以下配置内容：
		
		[mysqld]
		ndbcluster                                                                               #开启NDB存储引擎
		
		[mysql_cluster]
		ndb-connectstring=192.168.140.180,192.168.140.181                                        #管理节点连接地址

#### 配置SQL节点

	SQL 节点初始化数据库，输入命令：
		
		mkdir -p /usr/local/mysql/data/
		
		chown -R mysql:mysql /usr/local/mysql/
		
		cd /usr/local/software
		
		# 记住临时密码，用于启动初始化账号
		./bin/mysqld --initialize --user=mysql --basedir=/usr/local/mysql --datadir=/usr/local/mysql/data
		
	SQL 节点修改配置文件，输入命令：
		
		vi /etc/my.cnf
		
	添加以下配置内容：
		
		[mysqld]
		basedir= /usr/local/mysql                                                                #SQL节点目录
		datadir=/usr/local/mysql/data                                                            #SQL节点存储目录
		ndbcluster                                                                               #开启NDB存储引擎
		
		[mysql_cluster]
		ndb-connectstring=192.168.140.180,192.168.140.181                                        #管理节点连接地址

#### 启动管理节点

	管理节点分别启动，输入命令：
		
		cd /usr/local/mysql
		
		./bin/ndb_mgmd -f /etc/mgmd.cnf
	
	管理节点查看各节点状态，输入命令：
		
		# 因为 SQL 节点和管理节点在一个服务器时，受到 my.cnf 影响，要指定 NodeId 和 ConnectString
		# ./bin/ndb_mgm
		./bin/ndb_mgm --ndb-nodeid=181 --connect-string=192.168.140.181
		
		# 输出当前集群各节点信息
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
	
	数据节点分别启动，输入命令：
		
		cd /usr/local/mysql
		
		./bin/ndbd
	
	管理节点查看各节点状态，控制台可以看到如下输出：
		
		Cluster Configuration
		---------------------
		[ndbd(NDB)]	2 node(s)
		id=1	@192.168.140.178  (mysql-8.0.27 ndb-8.0.27, starting, Nodegroup: 0)
		id=2	@192.168.140.179  (mysql-8.0.27 ndb-8.0.27, starting, Nodegroup: 0)
		
		[ndb_mgmd(MGM)]	2 node(s)
		id=180	@192.168.140.180  (mysql-8.0.27 ndb-8.0.27)
		id=181	@192.168.140.181  (mysql-8.0.27 ndb-8.0.27)
		
		[mysqld(API)]	2 node(s)
		id=100 (not connected, accepting connect from 192.168.140.180)
		id=101 (not connected, accepting connect from 192.168.140.181)

#### 启动 SQL 节点

	SQL 节点分别启动，输入命令：
		
		cd /usr/local/mysql
		
		./support-files/mysql.server start
		
	初始化 root 登录信息，输入命令：
		
		./bin/mysql -uroot -p
		
		alter user 'root'@'localhost' identified by '123456';
		
		update mysql.user set host='%' where user='root';
		
		flush privileges;
	
	管理节点查看各节点状态，控制台可以看到如下输出：
		
		Connected to Management Server at: localhost:1186
		Cluster Configuration
		---------------------
		[ndbd(NDB)]	2 node(s)
		id=1	@192.168.140.178  (mysql-8.0.27 ndb-8.0.27, Nodegroup: 0, *)
		id=2	@192.168.140.179  (mysql-8.0.27 ndb-8.0.27, Nodegroup: 0)
		
		[ndb_mgmd(MGM)]	2 node(s)
		id=180	@192.168.140.180  (mysql-8.0.27 ndb-8.0.27)
		id=181	@192.168.140.181  (mysql-8.0.27 ndb-8.0.27)
		
		[mysqld(API)]	2 node(s)
		id=100	@192.168.140.180  (mysql-8.0.27 ndb-8.0.27)
		id=101	@192.168.140.181  (mysql-8.0.27 ndb-8.0.27)

#### 使用 MNC 集群





#### 添加新存储节点











