
# mysql集群 多主MGC

	基于 Mysql 的  Mysql Galera Cluster，基于 MariaDB 的 MariaDB Galera Cluster，属于 Galera Cluster 两个版本之一，简称 MGC
	
	MGC 的特点：多主架构、同步复制、多线程复制、故障转移、节点自动加入等
	
	MGC 和 PXC 都同属 Galera Cluster

#### 服务器准备

	三台服务器信息：
		
		192.168.140.184		#节点一
		
		192.168.140.185		#节点二
		
		192.168.140.186		#节点三
	
	配置三台服务器host，输入命令：
	
		vi /etc/hosts
		
		添加以下配置：
		
			192.168.140.184 mgc184
			192.168.140.185 mgc185
			192.168.140.186 mgc186
		
		service network restart
		
		hostname
		
	关闭三台服务器防火墙，输入命令：
	
		setenforce 0
		
		vi /etc/selinux/config
		
		=> SELINUX=disabled
		
		systemctl stop firewalld
		
		systemctl disable firewalld

#### 安装 MGC

	官方文档地址：
		
		https://galeracluster.com/library/documentation/index.html
		
	使用 yum 安装，输入命令：
		
		yum -y remove mariadb*
			
		cat > /etc/yum.repos.d/galera.repo <<EOF
		
		[galera]
		name=galera
		baseurl= http://releases.galeracluster.com/galera-3/centos/7/x86_64/
		gpgcheck=0
		
		[mysql-wsrep]
		name = mysql-wsrep
		baseurl = http://releases.galeracluster.com/mysql-wsrep-5.7/centos/7/x86_64/
		gpgcheck = 0
		
		EOF
		
		yum makecache
		
		yum install -y  mysql-wsrep-5.7 galera-3
		
		yum localinstall -y https://repo.percona.com/release/7/RPMS/x86_64/percona-xtrabackup-24-2.4.24-1.el7.x86_64.rpm
	
	注意，如果需要修改数据库相关目录，请在此配置完 my.cnf 再初始化
	
	初始化数据库root账号，输入命令：
		
		systemctl start mysqld
		
		grep 'temporary password' /var/log/mysqld.log
		
		mysql -uroot -p
		
		set global validate_password_policy=LOW;
		
		set global validate_password_length=6;
		
		alter user 'root'@'localhost' IDENTIFIED BY '123456';
		
		exit
		
		systemctl stop mysqld
	
	关闭数据库开机自启动，输入命令：
		
		chkconfig mysqld off

#### 配置 MGC

	注意，此处只是修改了 MGC 集群相关配置，优化配置参考单点配置
	
	修改 my.cnf，输入命令：
	
		vi /etc/my.cnf
	
	节点一加入以下内容：
		
		server_id=184
				
		binlog_format=ROW
		default_storage_engine=InnoDB
		innodb_autoinc_lock_mode=2
		
		wsrep_node_name=mgc184
		wsrep_node_address=192.168.140.184
		wsrep_cluster_address=gcomm://192.168.140.184,192.168.140.185,192.168.140.186
		wsrep_cluster_name=mrh_galera_cluster
		wsrep_sst_auth=sstuser:123456
		wsrep_sst_method=xtrabackup
		wsrep-provider=/usr/lib64/galera-3/libgalera_smm.so
		
	节点二加入以下内容：
		
		server_id=185
				
		binlog_format=ROW
		default_storage_engine=InnoDB
		innodb_autoinc_lock_mode=2
		
		wsrep_node_name=mgc185
		wsrep_node_address=192.168.140.185
		wsrep_cluster_address=gcomm://192.168.140.184,192.168.140.185,192.168.140.186
		wsrep_cluster_name=mrh_galera_cluster
		wsrep_sst_auth=sstuser:123456
		wsrep_sst_method=xtrabackup
		wsrep-provider=/usr/lib64/galera-3/libgalera_smm.so
		
	节点三加入以下内容：
		
		server_id=186
				
		binlog_format=ROW
		default_storage_engine=InnoDB
		innodb_autoinc_lock_mode=2
		
		wsrep_node_name=mgc186
		wsrep_node_address=192.168.140.186
		wsrep_cluster_address=gcomm://192.168.140.184,192.168.140.185,192.168.140.186
		wsrep_cluster_name=mrh_galera_cluster
		wsrep_sst_auth=sstuser:123456
		wsrep_sst_method=xtrabackup
		wsrep-provider=/usr/lib64/galera-3/libgalera_smm.so

#### 初始化启动 MGC 集群

	节点一引导启动，输入命令：
		
		/usr/bin/mysqld_bootstrap
		
		mysql -uroot -p
		
		show status like 'wsrep%';
		
	节点一创建 PXC 连接账号，输入命令：
		
		mysql -uroot -p
		
		CREATE USER 'sstuser'@'%' IDENTIFIED BY '123456';
		
		GRANT RELOAD, LOCK TABLES, PROCESS, REPLICATION CLIENT ON *.* TO 'sstuser'@'%';
		
		FLUSH PRIVILEGES;
		
		select user,host from mysql.user;
		
	节点二和节点三启动，输入命令：
		
		systemctl start mysqld
		
		show status like 'wsrep%';
		
#### 关闭 MGC 集群节点

	输入命令：
		
		systemctl stop mysqld

#### 其他 MGC 集群操作

	MGC 集群重启、添加新节点、故障恢复，可参考 其兄弟 Part10，两者的区别在于命令有略微差异


	