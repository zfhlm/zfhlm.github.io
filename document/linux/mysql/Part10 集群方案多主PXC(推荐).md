
# mysql集群 多主PXC

	Percona XtraDB Cluster，属于 Galera Cluster 两个版本之一，简称 PXC
	
	PXC 是基于 Galera 的面向 OLTP 的多主同步复制插件
	
	PXC 是多主架构，可以在任何节点读写数据
	
	PXC 事务在所有集群节点同时提交，任何一个节点失败都算作事务失败，这样不同节点之间数据同步，没有延迟，在数据库挂掉之后，数据不会丢失
	
	PXC 数据强一致性，所有节点的数据保持一致，数据不仅在本地写入，还要同步到所有节点才成功

#### 服务器准备

	三台服务器信息：
		
		192.168.140.170		#节点一
		
		192.168.140.172		#节点二
		
		192.168.140.173		#节点三
	
	配置三台服务器host，输入命令：
	
		vi /etc/hosts
		
		添加以下配置：
		
			192.168.140.170 pxc170
			192.168.140.172 pxc172
			192.168.140.173 pxc173
		
		service network restart
		
		hostname
		
	关闭三台服务器防火墙，输入命令：
	
		setenforce 0
		
		vi /etc/selinux/config
		
		=> SELINUX=disabled
		
		systemctl stop firewalld
		
		systemctl disable firewalld

#### 下载安装包
	
	注意 PXC 安装包的版本号与 mysql 版本号相对应，本次搭建基于 5.7.34 版本
	
	官方网站：https://downloads.percona.com/
	
	下载安装包
	
		下载地址： https://www.percona.com/downloads/Percona-XtraDB-Cluster-57/LATEST/
		
		下载包名称： Percona-XtraDB-Cluster-5.7.34-31.51-r604-el7-x86_64-bundle.tar
	
	下载依赖包：
		
		https://repo.percona.com/release/7/RPMS/x86_64/qpress-11-1.el7.x86_64.rpm
	
		https://repo.percona.com/release/7/RPMS/x86_64/percona-xtrabackup-24-2.4.23-1.el7.x86_64.rpm
	
	上传到服务器目录  /usr/local/software

#### 安装 PXC 集群

	安装rpm包，输入命令：
		
		yum -y remove mariadb*
		
		cd /usr/local/software
		
		tar -xvf ./Percona-XtraDB-Cluster-5.7.34-31.51-r604-el7-x86_64-bundle.tar
		
		yum localinstall -y *.rpm
	
	注意，如果需要修改数据库相关目录，请在此配置完 my.cnf 再初始化启动
	
	初始化 PXC 数据库账号，输入命令：
		
		systemctl start mysql
		
		grep 'temporary password' /var/log/mysqld.log
		
		mysql -uroot -p
		
		alter user 'root'@'localhost' IDENTIFIED BY '123456';
		
		exit
		
		systemctl stop mysql
	
	关闭 PXC 开启自启动，输入命令：
	
		chkconfig mysqld off

#### 修改 PXC 集群配置

	注意，此处只是修改了 PXC 集群相关配置，优化配置参考单点配置
	
	修改 PXC 数据库配置，输入命令：
		
		vi /etc/percona-xtradb-cluster.conf.d/mysqld.cnf
		
	节点一添加以下内容：
	
		server-id=170
	
	节点二添加以下内容：
	
		server-id=172
	
	节点三添加以下内容：
	
		server-id=173
	
	注意，在此可以加入其他参数，参考 Part01 单点配置的参数进行配置
	
	修改 PXC 节点配置，输入命令：
		
		vi /etc/percona-xtradb-cluster.conf.d/wsrep.cnf
		
	节点一添加以下内容：
		
		[mysqld]
		
		wsrep_provider=/usr/lib64/galera3/libgalera_smm.so
		wsrep_cluster_name=mrh-pxc-cluster
		wsrep_cluster_address=gcomm://192.168.140.170,192.168.140.172,192.168.140.173
		
		wsrep_node_name=pxc170
		wsrep_node_address=192.168.140.170
		
		wsrep_sst_method=xtrabackup-v2
		wsrep_sst_auth=sstuser:123456
		
		pxc_strict_mode=ENFORCING
		
		binlog_format=ROW
		default_storage_engine=InnoDB
		innodb_autoinc_lock_mode=2
	
	节点二添加以下内容：
		
		[mysqld]
		
		wsrep_provider=/usr/lib64/galera3/libgalera_smm.so
		wsrep_cluster_name=mrh-pxc-cluster
		wsrep_cluster_address=gcomm://192.168.140.170,192.168.140.172,192.168.140.173
		
		wsrep_node_name=pxc172
		wsrep_node_address=192.168.140.172
		
		wsrep_sst_method=xtrabackup-v2
		wsrep_sst_auth=sstuser:123456
		
		pxc_strict_mode=ENFORCING
		
		binlog_format=ROW
		default_storage_engine=InnoDB
		innodb_autoinc_lock_mode=2
	
	节点三添加以下内容：
		
		[mysqld]
		
		wsrep_provider=/usr/lib64/galera3/libgalera_smm.so
		wsrep_cluster_name=mrh-pxc-cluster
		wsrep_cluster_address=gcomm://192.168.140.170,192.168.140.172,192.168.140.173
		
		wsrep_node_name=pxc173
		wsrep_node_address=192.168.140.173
		
		wsrep_sst_method=xtrabackup-v2
		wsrep_sst_auth=sstuser:123456
		
		pxc_strict_mode=ENFORCING
		
		binlog_format=ROW
		default_storage_engine=InnoDB
		innodb_autoinc_lock_mode=2

#### 初次启动 PXC 集群

	启动节点一，输入命令：
		
		systemctl start mysql@bootstrap.service
		 
		mysql -uroot -p
		 
		show status like 'wsrep%';
	
	节点一创建 PXC 连接账号，输入命令：
		
		mysql -uroot -p
		
		CREATE USER 'sstuser'@'%' IDENTIFIED BY '123456';
		
		GRANT RELOAD, LOCK TABLES, PROCESS, REPLICATION CLIENT ON *.* TO 'sstuser'@'%';
		
		FLUSH PRIVILEGES;
		
		select user,host from mysql.user;
		
	启动节点二和节点三，输入命令：
	
		systemctl start mysql
		
		show status like 'wsrep%';

#### 关闭 PXC 集群节点

	确认是否引导启动节点（进程是否有--wsrep-new-cluster参数），输入命令：
		
		ps -ef | grep mysql
		
	关闭引导启动节点，输入命令：
		
		systemctl stop mysql@bootstrap.service
		
	关闭其他节点，输入命令：
		
		systemctl stop mysql

#### 重新启动 PXC 集群

	1，集群未关闭全部节点，直接启动关闭节点加入集群
		
		输入命令：
			
			systemctl start mysql
			
			show status like 'wsrep%';
	
	2，集群被关闭全部节点，确认节点是否最后关闭节点：
	
		文件参数 safe_to_bootstrap=1 为最后关闭节点，查看是否最后关闭节点，输入命令：
			
			cat /var/lib/mysql/grastate.dat
		
		如果全部节点 safe_to_bootstrap=0，通过比对 seqno 值最大的为最后关闭节点，输入命令：
		
			mysqld_safe --wsrep-recover
		
	3，集群被关闭全部节点，启动所有节点：
		
		先启动最后关闭节点，输入命令：
		
			systemctl start mysql@bootstrap.service
		
		再启动其他节点，输入命令：
		
			systemctl start mysql

#### 添加新节点到 PXC 集群

	1，如果集群数据量非常小，直接加入新节点到 PXC 集群，触发 SST 全量同步
	
	2，如果集群数据量非常大，直接加入新节点 SST 开销大，可通过 xtrabackup + IST增量同步的方式添加新节点：
		
		旧节点拉取当前时间点的全量数据，输入命令(根据实际情况更改命令参数)：
			
			mkdir /usr/local/backup
			
			cd /usr/local/backup
			
			innobackupex --databases="test" --host="localhost" --port=3306 --user="sstuser" --password="123456" --galera-info "./"
			
			tar -cvf backup.2021-10-21_19-25-46.tar ./2021-10-21_19-25-46
			
			cat /var/lib/mysql/grastate.dat > copy.grastate.dat
		
		旧节点将还原需要的文件传输到新节点服务器，输入命令(根据实际情况更改命令参数)：
			
			cd /usr/local/backup
			
			scp ./backup.2021-10-21_19-25-46.tar root@192.168.140.175:/usr/local/backup
			
			scp ./copy.grastate.dat root@192.168.140.175:/usr/local/backup
			
		新节点还原备份数据，并修改 grastate.dat IST增量同步参数 seqno，输入命令(根据实际情况更改命令参数)：
			
			cd /usr/local/backup
			
			tar --xvf ./backup.2021-10-21_19-25-46.tar
			
			cd ./backup.2021-10-21_19-25-46
			
			innobackupex –apply-log ./
			
			innobackupex –copy-back ./
			
			cat ./xtrabackup_galera_info
			
			-> 输出内容例如如 cd39819a-32a7-11ec-a078-6feecc9850b6:14，seqno值为14，集群uuid值为cd39819a-32a7-11ec-a078-6feecc9850b6
			
			cp ./copy.grastate.dat /var/lib/mysql/grastate.dat
			
			vi /var/lib/mysql/grastate.dat
			
			=> 根据上面的输出内容，修改 seqno 值，比如 14
		
		新节点更改配置文件，然后启动加入集群，输入命令：
			
			vi /etc/percona-xtradb-cluster.conf.d/wsrep.cnf
			
			=> 配置各项参数，包含新旧节点IP
			
			systemctl start mysql
			
			show status like 'wsrep%';
		
		旧节点更改配置文件，然后逐个重启，输入命令：
			
			vi /etc/percona-xtradb-cluster.conf.d/wsrep.cnf
			
			=> wsrep_cluster_address 加入新节点IP

#### 恢复故障节点到 PXC 集群

	1，如果故障节点加入集群binlog可以补全，直接启动加入到集群，触发 IST 增量同步
	
	2，如果故障节点加入集群binlog不能补全，可以通过添加新节点的方式


