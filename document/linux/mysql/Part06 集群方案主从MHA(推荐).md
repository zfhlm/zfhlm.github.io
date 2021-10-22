
# mysql集群 主从MHA

#### 集群 MHA 简单介绍

	

#### 服务器准备

	192.168.140.174		# mysql主节点、MHA node节点
	
	192.168.140.175		# mysql从节点、MHA node节点(备用master)
	
	192.168.140.176		# mysql从节点、MHA node节点(只作为slave)
	
	192.168.140.177		# MHA管理节点

#### 数据库搭建

	搭建单点数据库：
		
		(基于 Part01 进行)
		
	搭建一主二从集群：
		
		(基于 Part02 进行)
	
	限制从节点只读模式：
		
		(调整 my.cnf 参数 read_only=1 并重启服务)
	
	限制所有节点不允许删除中继日志：
	
		(调整 my.cnf 参数 relay_log_purge=0 并重启服务)
		
	集群开启半同步复制：
		
		(基于 Part04 进行)
	
	集群开启 GTID：
		
		(基于 Part05 进行)

#### 服务器ssh免密配置

	主节点生成公钥和私钥，输入命令：
	
		cd ~
		
		ssh-keygen
		
		cd .ssh/
		
		cp id_rsa.pub authorized_keys
	
	主节点同步公钥和私钥到其他节点，输入命令：
	
		cd /root
		
		scp -r /root/.ssh/ root@192.168.140.175:/root/
		
		scp -r /root/.ssh/ root@192.168.140.176:/root/
		
		scp -r /root/.ssh/ root@192.168.140.177:/root/
	
	测试ssh免密登录，输入命令：
	
		ssh 192.168.140.175
		
		ls /usr/local/software
		
		exit

#### 下载 MHA 安装包

	官方文档地址：
		
		https://github.com/yoshinorim/mha4mysql-manager/wiki
		
	下载地址：
		
		https://github.com/yoshinorim/mha4mysql-manager/releases/
		
		https://github.com/yoshinorim/mha4mysql-manager/releases/
		
	下载RPM包：
	
		mha4mysql-node-0.58.tar.gz
		
		mha4mysql-manager-0.58.tar.gz
	
	上传到服务器目录：
	
		/usr/local/software

#### 安装 MHA Node 和 MHA Manager
	
	MHA管理节点和Node节点，安装 MHA Node，输入命令：
		
		yum install -y perl-DBD-MySQL perl-ExtUtils-Embed cpan
		
		cd /usr/local/software
		
		tar -zxf ./mha4mysql-node-0.58.tar.gz
		
		cd mha4mysql-node-0.58
		
		perl Makefile.PL
		
		make && make install
		
		ll /usr/local/bin/
		
	MHA管理节点，安装 MHA Manager，输入命令：
		
		yum install https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
		
		yum install -y perl-Config-Tiny perl-Log-Dispatch perl-Parallel-ForkManager
		
		cd /usr/local/software
		
		tar -zxf ./mha4mysql-manager-0.58.tar.gz
		
		cd ./mha4mysql-manager-0.58
		
		perl Makefile.PL
		
		make && make install
		
		cp ./samples/scripts/* /usr/local/bin/
		
		ll /usr/local/bin/

#### 集群 MHA 脚本
	
	查看 MHA 脚本，输入命令：
	
		ll /usr/local/bin/
	
	MHA Node 节点脚本作用说明：
		
		apply_diff_relay_logs           #识别差异的中继日志事件
		
		filter_mysqlbinlog              #过滤回滚事务binlog
		
		purge_relay_logs                #清除中继日志
		
		save_binary_logs                #保存和复制master的二进制日志
		
	MHA Manager 节点脚本作用说明：
		
		masterha_check_repl             #
		
		masterha_check_ssh              #
		
		masterha_check_status           #
		
		masterha_conf_host              #
		
		masterha_manager                #
		
		masterha_master_monitor         #
		
		masterha_master_switch          #
		
		masterha_secondary_check        #
		
		masterha_stop                   #
		
		master_ip_failover              #
		
		master_ip_online_change         #
		
		power_manager                   #
		
		send_report                     #

#### 配置 MHA Manager

	配置文件参数官方文档：
	
		https://raw.githubusercontent.com/wiki/yoshinorim/mha4mysql-manager/Parameters.md
	
	管理节点添加 MHA Manager 全局配置，输入命令：
	
		vi /etc/masterha_default.cnf
		
		加入以下内容：
			
			[server default]
			
			#ssh远程账号
			ssh_user=root
			
			#ssh远程端口
			ssh_port=22
			
			#数据库连接账号
			user=root
			
			#数据库连接密码
			password=123456
			
			#数据库创建主从账号
			repl_user=replicator
			
			#数据库创建主从密码
			repl_password=123456
			
			#数据库主节点binlog目录
			master_binlog_dir= /usr/local/mysql/data
			
			#数据库主节点ping时间间隔
			ping_interval=3
			
			#远程节点工作目录
			remote_workdir=/usr/local/masterha/
			
			#管理节点工作目录
			manager_workdir=/usr/local/masterha/
			
			#管理节点日志目录
			manager_log=/usr/local/masterha/manager.log
			
	管理节点添加 MHA Manager 集群1配置，输入命令：
		
		vi /etc/app1.cnf
		
		添加以下内容：
			
			[server default]
			
			#集群1检测脚本
			secondary_check_script=masterha_secondary_check -s 192.168.140.174 -s 192.168.140.175 -s 192.168.140.176
			
			#管理节点集群1工作目录
			manager_workdir=/usr/local/masterha/app1/
			
			#管理节点集群1日志目录
			manager_log=/usr/local/masterha/app1/manager.log
			
			#数据库主节点
			[server1]
			hostname=192.168.140.174
			
			#数据库从节点，故障切换可提升为主节点
			[server2]
			hostname=192.168.140.175
			candidate_master=1
			check_repl_delay=0
			
			#数据库从节点
			[server3]
			hostname=192.168.140.176
			no_master=1
	
	管理节点添加 MHA Manager 集群2 ... 集群N，只需创建不同的配置文件，例如：
		
		vi /etc/app2.cnf
		
		vi /etc/app3.cnf
		
		      ...
		
		vi /etc/appN.cnf

#### 启动 MHA Manager

	管理节点验证集群1 ssh 是否正确，输入命令：
		
		masterha_check_ssh --conf=/etc/app1.cnf
		
		-> 注意控制台是否输出成功信息 All SSH connection tests passed successfully. 
		
	管理节点验证集群1 主从复制是否正确，输入命令：
		
		masterha_check_repl --conf=/etc/app1.cnf
		
		-> 注意控制台是否输出成功信息 MySQL Replication Health is OK. 
	
	管理节点启动 MHA Manager，输入命令：
		
		masterha_manager --conf=/etc/app1.cnf &
		
		tail -f /usr/local/masterha/app1/manager.log
		
		-> 观察控制台输出日志
		
		masterha_check_status --conf=/etc/app1.cnf
	
	如果需要关闭 MHA Manager，输入命令：
		
		masterha_stop --conf=/etc/app1.cnf 

#### 测试 MHA 故障转移

	将 mysql 主节点关掉，输入命令：
	
		



