
# mysql集群 主从MHA

	Master HA，开源的 MySQL 的高可用程序
	
	MHA 在监控到 master 节点故障时，会提升其中拥有最新数据的 slave 节点成为新的master 节点，在此期间，MHA 会通过于其它从节点获取额外信息来避免一致性方面的问题
	
	MHA 还提供了 master 节点的在线切换功能，即按需切换 master/slave 节点

#### 服务器准备

	192.168.140.174		# mysql主节点、MHA node节点
	
	192.168.140.175		# mysql从节点、MHA node节点(备用master)
	
	192.168.140.176		# mysql从节点、MHA node节点(只作为slave)
	
	192.168.140.177		# MHA管理节点

#### 数据库搭建

	搭建单点数据库：
		
		(基于 Part01 进行)
				
	开启半同步复制：
		
		(基于 Part04 进行)
		
	开启 GTID：
		
		(基于 Part05 进行)
	
	搭建一主二从集群：
		
		(基于 Part02 进行)
	
	主从配置修改：
	
		限制从节点只读模式，修改 my.cnf 参数 read_only=1
	
		限制所有节点不允许删除主从中继日志，修改 my.cnf 参数 relay_log_purge=0

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
		
	下载源码包：
	
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
		
		masterha_check_repl             #检查 MHA 主从数据库状态脚本
		
		masterha_check_ssh              #检查 MHA ssh 连接配置脚本
		
		masterha_check_status           #检测当前MHA运行状态脚本
		
		masterha_conf_host              #管理 MHA server配置脚本
		
		masterha_manager                #启动 MHA 脚本
		
		masterha_master_monitor         #监控主从 master 状态脚本
		
		masterha_master_switch          #故障转移脚本
		
		masterha_secondary_check        #检查网络连接脚本
		
		masterha_stop                   #停止 MHA 脚本
		
		master_ip_failover              #VIP故障转移脚本
		
		master_ip_online_change         #VIP手动切换脚本
		
		power_manager                   #防止集群脑裂关闭master服务脚本
		
		send_report                     #发送邮件通知脚本

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
			
			#管理节点集群1工作目录
			manager_workdir=/usr/local/masterha/app1/
			
			#管理节点集群1日志目录
			manager_log=/usr/local/masterha/app1/manager.log
			
			[server1]
			
			#主节点IP
			hostname=192.168.140.174
			
			#允许故障切换为master
			candidate_master=1
			
			#切换master不用考虑复制延迟
			check_repl_delay=0
			
			[server2]
			
			#从节点IP
			hostname=192.168.140.175
			
			#允许故障切换为master
			candidate_master=1
			
			#切换master不用考虑复制延迟
			check_repl_delay=0
			
			[server3]
			
			#从节点IP
			hostname=192.168.140.176
			
			#不允许故障切换为master
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
		
		masterha_check_status --conf=/etc/app1.cnf
		
		tail -f /usr/local/masterha/app1/manager.log
		
	如果需要关闭 MHA Manager，输入命令：
		
		masterha_stop --conf=/etc/app1.cnf 

#### 模拟 MHA 故障转移

	管理节点持续查看日志，输入命令：
		
		tail -f /usr/local/masterha/app1/manager.log
		
	主节点 mysql 模拟故障，重启服务器，输入命令：
		
		reboot
	
	MHA切换master成功，管理节点可以看到如下输出信息：
	
		Started automated(non-interactive) failover.
		Selected 192.168.140.175(192.168.140.175:3306) as a new master.
		192.168.140.175(192.168.140.175:3306): OK: Applying all logs succeeded.
		192.168.140.176(192.168.140.176:3306): OK: Slave started, replicating from 192.168.140.175(192.168.140.175:3306)
		192.168.140.175(192.168.140.175:3306): Resetting slave info succeeded.
		Master failover to 192.168.140.175(192.168.140.175:3306) completed successfully.
	
	从节点可以看到节点三的master已经是节点二，输入命令：
	
		mysql -uroot -p
	
		show slave status\G;
		
		show master status;
	
	管理节点 MHA Manager 在故障转移后会杀死自身进程，查看进程输入命令：
		
		ps -ef | grep masterha

#### 模拟 MHA 故障恢复

	节点二(新master)模拟写入数据提升集群 GTID，输入命令：
	
		mysql -uroot -p
		
		#根据实际情况插入数据
		insert into table_name ......
		
	节点一(原 master)以只读的方式启动，输入命令：
		
		service mysqld start --read-only=1
		
		mysql -uroot -p
	
		show variables like 'read_only';
	
	节点一(原 master)加入到主从集群，输入命令：
		
		change master to master_host='192.168.140.175', master_user='replicator', master_password='123456',master_auto_position=1;
		
		start slave;
		
		show slave status\G
	
	管理节点删除上次故障切换的标记文件，检查配置文件信息是否正确，输入命令：
	
		rm -rf /usr/local/masterha/app1/app1.failover.complete
		
		cat /etc/app1.cnf
	
	管理节点执行切换脚本，将主节点切换为 master，输入命令：
	
		masterha_master_switch --conf=/etc/app1.cnf --master_state=alive --new_master_host=192.168.140.174 --new_master_port=3306  --orig_master_is_new_slave
	
	所有节点检查状态是否正常，输入命令：
	
		show master status;
		
		show slave status\G;
		
		show variables like 'read_only';
		
	管理节点重新启动 MHA，输入命令：
		
		masterha_check_ssh --conf=/etc/app1.cnf
		
		masterha_manager --conf=/etc/app1.cnf &
		
		masterha_check_status --conf=/etc/app1.cnf

#### 配置 MHA 执行脚本

	选择性加入到全局配置文件，或 集群配置文件：
		
		# 故障二次检测确认脚本，提升集群网络容忍能力
		secondary_check_script=masterha_secondary_check -s 192.168.140.175 -s 192.168.140.176
		
		# 故障切换邮件通知，自带脚本未实现邮件发送的功能，仅仅是定义了命令行传递的参数，需要额外编写发送逻辑
		report_script=/usr/local/bin/send_report
		
		# 故障切换 VIP 到备用 master
		master_ip_failover_script=/usr/local/bin/master_ip_failover


