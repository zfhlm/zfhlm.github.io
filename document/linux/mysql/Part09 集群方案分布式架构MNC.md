
# Mysql集群 分布式架构MNC

	MySQL NDB Cluster，一个 MNC 集群由若干管理节点、若干数据节点和若干 SQL 节点组成
	
	管理节点：用于管理集群内的其他节点，如提供配置数据，启动并停止节点，运行备份等，可以设置为1个到多个
			
	SQL节点：用于访问数据的节点，提供SQL接口，用户认证，赋予权限等功能，可以设置为1个到多个
	
	数据节点：
		
		用于保存数据、索引，控制事务等，多个节点组成一个分组，集群中可以有多个分组
		
		在同个分组中，数据节点数量必须能被 NoOfReplicas 参数整除，一般配置2个数据节点为同一个组，配置 NoOfReplicas=2
		
		如果同分组数据节点数=2，则 NoOfReplicas ∈ {1, 2}
		
		如果同分组数据节点数=3，则 NoOfReplicas ∈ {1, 3}
		
		如果同分组数据节点数=4，则 NoOfReplicas ∈ {1, 2, 4}

#### 下载安装包

	文档地址：https://dev.mysql.com/doc/refman/8.0/en/mysql-cluster.html
	
	下载地址：https://dev.mysql.com/downloads/cluster/
	
	下载安装包：mysql-cluster-8.0.27-linux-glibc2.12-x86_64.tar.gz
	
	上传到服务器目录：/usr/local/software

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

#### 配置管理节点

	管理节点修改配置文件，输入命令：
		
		mkdir -p /usr/local/mysql/mgmd/{data,log}
		
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
		DataDir=/usr/local/mysql/ndbd/data                                                       #数据节点默认存储目录
		
		[ndb_mgmd]
		NodeId=180                                                                               #管理节点一ID
		HostName=192.168.140.180                                                                 #管理节点一IP地址
		
		[ndb_mgmd]
		NodeId=181                                                                               #管理节点ID
		HostName=192.168.140.181                                                                 #管理节点二IP地址
		
		[ndbd]
		NodeId=1                                                                                 #数据节点一ID
		HostName=192.168.140.178                                                                 #数据节点一IP地址
		
		[ndbd]
		NodeId=2                                                                                 #数据节点二ID
		HostName=192.168.140.179                                                                 #数据节点二IP地址
		
		[mysqld]
		NodeId=100                                                                               #SQL节点一ID
		HostName=192.168.140.180                                                                 #SQL节点一IP地址
		
		[mysqld]
		NodeId=101                                                                               #SQL节点二ID
		HostName=192.168.140.181                                                                 #SQL节点二IP地址

#### 配置数据节点

	数据节点修改配置文件，输入命令：
		
		mkdir -p /usr/local/mysql/ndbd/data
		
		vi /etc/my.cnf
	
	添加以下配置内容：
		
		[mysqld]
		ndbcluster                                                                               #开启NDB存储引擎
		
		[mysql_cluster]
		ndb-connectstring=192.168.140.180,192.168.140.181                                        #管理节点连接地址

#### 配置SQL节点
	
	创建运行用户，输入命令：
		
		groupadd mysql
		
		useradd -r -s /sbin/nologin -g mysql mysql -d /usr/local/mysql/
		
		chown -R mysql:mysql mysql
		
		chown -R mysql:mysql mysql-cluster-8.0.27/
	
	SQL 节点初始化数据库，输入命令：
		
		mkdir -p /usr/local/mysql/data/
		
		chown -R mysql:mysql /usr/local/mysql/
		
		cd /usr/local/software
		
		./bin/mysqld --initialize --user=mysql --basedir=/usr/local/mysql --datadir=/usr/local/mysql/data
		
		-> 控制台输出 root 临时密码
		
		cp ./support-files/mysql.server /etc/init.d/mysqld
		
	SQL 节点修改配置文件，输入命令：
		
		vi /etc/my.cnf
		
	添加以下配置内容：
		
		[mysqld]
		basedir= /usr/local/mysql                                                                #SQL节点目录
		datadir=/usr/local/mysql/data                                                            #SQL节点存储目录
		ndbcluster                                                                               #开启NDB存储引擎
		
		[mysql_cluster]
		ndb-connectstring=192.168.140.180,192.168.140.181                                        #管理节点连接地址

#### 启动 MNC 集群

	启动管理节点，输入命令：
		
		cd /usr/local/mysql
		
		./bin/ndb_mgmd --initial -f /etc/mgmd.cnf
		
	启动数据节点，输入命令：
		
		cd /usr/local/mysql
		
		./bin/ndbd --initial
	
	启动 SQL 节点，输入命令：
		
		cd /usr/local/mysql
		
		service mysqld start
	
	管理节点查看各节点状态，输入命令：
		
		./bin/ndb_mgm -e -show --ndb-nodeid=181 --connect-string=192.168.140.181

#### 使用 MNC 集群

	初始化 SQL 节点 root 登录信息(使用临时密码)，输入命令：
		
		cd /usr/local/mysql
		
		./bin/mysql -uroot -p
		
		alter user 'root'@'localhost' identified by '123456';
		
		update mysql.user set host='%' where user='root';
		
		flush privileges;
	
	使用远程工具连接数据库，连接地址：
		
		192.168.140.180:3306
		
		192.168.140.181:3306
		
	创建数据库和测试表，输入 SQL 语句：
	
		CREATE DATABASE `test`;
		
		CREATE TABLE `test`.`test_user` (
		  `id` INT NOT NULL,
		  `name` VARCHAR(45) NULL,
		  PRIMARY KEY (`id`)
		) ENGINE = ndbcluster DEFAULT CHARACTER SET = utf8mb4 COLLATE = utf8mb4_bin;
	
	插入数据输入 SQL 语句：
		
		insert into `test_user` values ('1', '张三');
		
		insert into `test_user` values ('2', '李四');
	
	查询数据输入 SQL 语句：
	
		select * from `test_user`;

#### 模拟节点故障

	如果 SQL 节点 down 掉，只会影响连接这个 SQL 节点的客户端，其他 SQL 节点可以正常工作，这里不做模拟
	
	关闭第一个数据节点，输入命令：
	
		ps -ef | grep ndbd
		
		pkill ndbd
	
	客户端对数据库进行读写，正常执行(关闭第二个数据节点，发现数据库已经不能读写)：
		
		insert into `test_user` values ('3', '王五');
		
		select * from `test_user`;
	
	关闭第一个管理节点，输入命令：
	
		ps -ef | grep mgmd
		
		kill pid
	
	客户端对数据库进行读写，正常执行(关闭第二个管理节点，数据库仍旧可以正常读写)：
		
		insert into `test_user` values ('4', '赵六');
		
		select * from `test_user`;

#### 在线添加数据节点
	
	添加两个新的数据节点，组成一个新分组：
		
		192.168.140.182
		
		192.168.140.183
		
		(按照初始化安装、配置数据节点步骤，设定好各项配置)
		
	修改管理节点配置，输入命令：
		
		vi /etc/mgmd.cnf
		
	加入以下配置内容：
		
		[ndbd]
		NodeId=3                                                                                 #数据节点三ID
		HostName=192.168.140.182                                                                 #数据节点三IP地址
		
		[ndbd]
		NodeId=4                                                                                 #数据节点四ID
		HostName=192.168.140.183                                                                 #数据节点四IP地址
		
	管理节点重启，输入命令：
		
		ps -ef | grep mgmd
		
		kill pid
		
		./bin/ndb_mgmd -f /etc/mgmd.cnf --reload
		
	数据节点重启，管理节点输入命令：
		
		./bin/ndb_mgm --ndb-nodeid=181 --connect-string=192.168.140.181
		
		show
		
		1 restart
		
		-> 注意控制台输出，等待到启动成功
		-> Node 1: Node shutdown initiated
		-> Node 1: Node shutdown completed, restarting, no start.
		-> Node 1 is being restarted
		-> Node 1: Start initiated (version 8.0.27)
		-> Node 1: Started (version 8.0.27)
		
		2 restart
		
		-> 注意控制台输出，等待到启动成功
		-> Node 2: Node shutdown initiated
		-> Node 2: Node shutdown completed, restarting, no start.
		-> Node 2 is being restarted
		-> Node 2: Start initiated (version 8.0.27)
		-> Node 2: Started (version 8.0.27)
		
	SQL节点重启，输入命令：
		
		service mysqld restart
		
	初始化启动新的数据节点，输入命令：
		
		cd /usr/local/mysql
		
		./bin/ndbd --initial
	
	管理节点创建分组，输入命令：
	
		./bin/ndb_mgm --ndb-nodeid=181 --connect-string=192.168.140.181
		
		show
		
		create nodegroup 3,4
		
		show

#### 常用 MNC 命令

	注意，以下所有包含 --initial 命令中，只能在初次启动的时候使用
	
	数据节点命令：
		
		./bin/ndbd                                       #启动数据节点守护进程(常规启动)
		
		./bin/ndbd --initial                             #启动数据节点守护进程(初次启动)
		
	SQL节点命令：
		
		service mysqld start                             #启动SQL节点守护进程
		
		service mysqld stop                              #停止SQL节点守护进程
		
		service mysqld restart                           #重启SQL节点守护进程
	
	管理节点命令：
	
		./bin/ndb_mgmd -f /etc/mgmd.cnf                  #启动管理节点守护进程(常规启动)
		
		./bin/ndb_mgmd -f /etc/mgmd.cnf --reload         #启动管理节点守护进程(配置文件有改动时启动)
	
		./bin/ndb_mgmd -f /etc/mgmd.cnf --initial        #启动管理节点守护进程(初次启动)
		
		./bin/ndb_mgm                                    #进入管理节点控制台
		
		./bin/ndb_mgm -e show                            #使用管理节点控制台执行show命令
		
	管理节点控制台命令：
		
		show                                             #查看所有节点状态
		
		[nodeid] restart                                 #重启指定nodeid进程
		
		[nodeid] stop                                    #停止指定nodeid进程
		
		create nodegroup [nodeid1],[nodeid2]             #创建数据节点分组


