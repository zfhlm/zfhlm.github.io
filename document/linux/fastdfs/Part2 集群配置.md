
#### 集群配置

	1，服务器准备
	
		192.168.140.134		#tracker服务器
		
		192.168.140.135		#tracker服务器
		
		192.168.140.136		#storage服务器
		
		192.168.140.137		#storage服务器
		
		192.168.140.138		#storage服务器
	
	2，修改配置文件，输入命令：
	
		vi /etc/fdfs/storage.conf
		
		=>
			
			tracker_server=192.168.140.136:22122
			tracker_server=192.168.140.137:22122
		
		vi /etc/fdfs/client.conf
		
		=>
			
			tracker_server=192.168.140.136:22122
			tracker_server=192.168.140.137:22122
	
	3，启动集群，服务器根据各自角色，选择输入命令：
		
		/usr/bin/fdfs_trackerd /etc/fdfs/tracker.conf
		
		/usr/bin/fdfs_storaged /etc/fdfs/storage.conf
	
	4，集群错误处理
		
		item "group_count" is not found，删掉新加入节点的/data目录，拷贝当前Leader 目录下的 /data/*.dat 文件到新节点目录
		
		节点一直处于 WAIT_SYNC 状态，删除storage节点数据，重新启动即可


