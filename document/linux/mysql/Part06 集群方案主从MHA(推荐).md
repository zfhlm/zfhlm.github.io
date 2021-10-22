
# mysql集群 主从MHA

#### 集群 MHA 简单介绍

	

#### 服务器准备
	
	192.168.140.174		# mysql主节点、MHA node节点
	
	192.168.140.175		# mysql从节点、MHA node节点
	
	192.168.140.176		# mysql从节点、MHA node节点
	
	192.168.140.177		# MHA管理节点
	
	基于 Part01、Part02、Part05 搭建好一主二从集群并开启 GTID 功能

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

	




