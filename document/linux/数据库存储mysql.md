
### 单点配置

	1，下载安装包
	
		下载地址：https://downloads.mysql.com/archives/community/
		
		下载安装包：Compressed TAR Archive mysql-5.7.35-linux-glibc2.12-x86_64.tar.gz
		
		上传到服务器目录：/usr/local/software
		
	2，解压到安装目录，输入命令：
		
		rpm -qa | grep mariadb
		
		rpm -e --nodeps mariadb-libs-5.5.68-1.el7.x86_64
		
		cd /usr/loca/software
		
		tar -zxvf ./mysql-5.7.35-linux-glibc2.12-x86_64.tar.gz
		
		mv mysql-5.7.35-linux-glibc2.12-x86_64 ../mysql-5.7.35
		
		cd ..
		
		ln -s mysql-5.7.35 mysql
		
	3，配置数据库启动账号，输入命令：
		
		groupadd mysql
		
		useradd -r -s /sbin/nologin -g mysql mysql -d /usr/local/mysql/
		
		chown -R mysql:mysql /usr/local/mysql
		
		chown -R mysql:mysql /usr/local/mysql/
	
	4，初始化数据库，输入命令：
		
		cd /usr/local/mysql
		
		./bin/mysqld --initialize --user=mysql --basedir=/usr/local/mysql/ --datadir=/usr/local/mysql/data/
		
		-> 执行完毕控制台会输出初始密码，需要记住密码文本
		
		vi /etc/my.cnf
		
		mkdir log
		
		touch ./log/mysql.log
		
		chown -R mysql:mysql ./log
		
		vi /etc/profile
		
		=>
			
			export MYSQL_HOME="/usr/local/mysql/"
			
			export PATH="$PATH:$MYSQL_HOME/bin"
			
		source /etc/profile
		
	5，启动数据库，输入命令：
		
		cd /usr/local/mysql
		
		cp -a ./support-files/mysql.server /etc/init.d/mysqld
		
		service mysqld start
	
	6，初始化远程超管账号，输入命令：
		
		mysql -uroot -p
		
		-> 使用控制台输出的初始密码登录
		
		set PASSWORD = PASSWORD('123456');
		
		flush privileges;
		
		use mysql;
		
		update user set host='%' where user='root';
		
		grant all privileges on *.* to 'root'@'%' identified by '123456';
		
		flush privileges;
		
		service mysqld restart

### mysql集群——一主多从
	
	1，服务器准备
	
		192.168.140.164		# 主服务器
	
		192.168.140.165		# 从服务器一
	
		192.168.140.166		# 从服务器二
	
	2，所有服务器 mysql 开启 binlog，输入命令：
		
		vi /etc/my.cnf
		
		=> 主服务器
			
			[mysqld]
			server-id=164
			log-bin=mysql-bin
			relay-log=mysql-relay-bin
			
		=> 从服务器一
			
			[mysqld]
			server-id=165
			log-bin=mysql-bin
			relay-log=mysql-relay-bin
			
		=> 从服务器二
			
			[mysqld]
			server-id=166
			log-bin=mysql-bin
			relay-log=mysql-relay-bin
				
		service mysqld restart
	
	3，所有服务器 mysql 创建主从同步账号，输入命令：
		
		mysql -uroot -p
		
		CREATE USER 'replicator'@'host' IDENTIFIED BY '123456';
		
		GRANT REPLICATION SLAVE ON *.* TO 'replicator'@'%' IDENTIFIED BY '123456';
		
		flush privileges;
		
		show master status;
		
		-> 记住控制台输出参数，作为 change master 命令参数
	
	4，从服务器 mysql 配置主从复制，输入命令：
		
		mysql -uroot -p
		
		change master to master_host='192.168.140.164', master_user='replicator', master_password='123456', master_log_file='mysql-bin.000016', master_log_pos=1113;
		
		start slave;
		
		show slave status;
	
	5，主从服务器 mysql 建表建库，输入命令：
		
		mysql -uroot -p
		
		CREATE DATABASE 'test';
		
		CREATE TABLE `test_user` (
		  `id` int(11) NOT NULL,
		  `name` varchar(50) NOT NULL,
		  PRIMARY KEY (`id`)
		) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
	
	6，主服务器 mysql 插入数据，输入命令：
		
		mysql -uroot -p
		
		use test;
		
		INSERT INTO `test_user` VALUES ('1', '张三');
		
	7，从服务器 mysql 查询数据，输入命令：
		
		mysql -uroot -p
		
		use test;
		
		SELECT * FROM `test_user` where `id` = 1;
	
	8，从服务器 mysql 停止主从复制，输入命令：
		
		mysql -uroot -p
		
		stop slave;
		
		reset slave all;
		
		show slave status；

### mysql集群——一主多从






