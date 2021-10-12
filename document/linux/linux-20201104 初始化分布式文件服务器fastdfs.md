
#### 下载安装包

	假设服务器IP地址：
	
		192.168.0.1
	
	准备好安装包：
	
		FastDFS_v5.08.tar.gz
		
		perl-5.26.1.tar.gz
		
		libfastcommon-master.zip
	
	远程root账号登录，用ftp工具上传到服务器目录：/usr/local/backup

#### 解压编译
		
	①，安装perl：
	
		输入命令编译安装：
		
			cd /usr/local/backup
			
			tar -zxvf ./perl-5.26.1.tar.gz
			
			cd ./perl-5.26.1
			
			./Configure -des -Dprefix=/usr/local/perl -Dusethreads -Uversiononly
			
			make && make install
	
		输入命令查看是否安装成功：
		
			perl -version
	
	②，yum安装eventlib
		
		yum -y install libevent
		
		rpm -qa | grep libevent
	
	③，安装libfastcommon
		
		输入命令编译安装：
		
			cd /usr/local/backup
			
			unzip libfastcommon-master.zip
			
			cd ./libfastcommon-master
			
			./make.sh
			
			./make.sh install
			
		注意查看安装输出日志是否正常。
		
		安装完成后创建软引用：
		
			ln -s /usr/lib64/libfastcommon.so /usr/local/lib/libfastcommon.so
			
			ln -s /usr/lib64/libfastcommon.so /usr/lib/libfastcommon.so
			
			ln -s /usr/lib64/libfdfsclient.so /usr/local/lib/libfdfsclient.so
			
			ln -s /usr/lib64/libfdfsclient.so /usr/lib/libfdfsclient.so
	
	④，安装fastdfs：
	
		输入命令编译安装：
		
			cd /usr/local/backup
			
			tar -zxvf ./FastDFS_v5.08.tar.gz
			
			cd ./FastDFS
			
			./make.sh
			
			./make.sh install
			
		注意查看安装输出日志是否正常。
			
		执行检测命令：
		
			ll /bin/fdfs_*
			
			(注意目录可能为/usr/bin，注意安装信息)
		
		必须输出这些脚本：
		
			<p>
			
			/bin/fdfs_monitor
			
			/bin/fdfs_storaged
			
			/bin/fdfs_test
			
			/bin/fdfs_trackerd
			
			......
			
			</p>

#### 修改配置
	
	①，fastdfs配置文件：
		
		拷贝一份配置文件，执行命令：
		
			cd /etc/fdfs/
			cp ./client.conf.sample ./client.conf
			cp ./storage.conf.sample ./storage.conf
			cp ./tracker.conf.sample ./tracker.conf
			
		将sample文件放到单独位置，执行命令：
		
			mkdir ./sample
			mv ./*.sample ./sample/
	
	②，创建文件存储目录并配置tracker和storage：
	
		创建存储目录：
		
			cd /usr/local
			
			mkdir fastdfs
			
			cd ./fastdfs
			
			mkdir tracker
			
			mkdir storage
			
			mkdir storage/data
			
			mkdir client
		
		修改tracker配置：
		
			输入命令：
		
				vi /etc/fdfs/tracker.conf
			
			修改配置为：
			
				base_path=/usr/local/fastdfs/tracker
		
		修改storage配置：
		
			输入命令：
			
				vi /etc/fdfs/storage.conf
			
			修改配置为：
								
				base_path=/usr/local/fastdfs/storage
				store_path0=/usr/local/fastdfs/storage/data
				tracker_server=192.168.0.1:22122
		
		修改client配置：
		
			输入命令：
			
				vi /etc/fdfs/client.conf
			
			修改配置为：
				
				base_path=/usr/local/fastdfs/client
				tracker_server=192.168.0.1:22122

#### 优化配置

	max_connections=1024			#最大连接数
	
	accept_threads=2			#接收客户端连接的线程数，默认值为1
	
	work_threads=10				#工作线程用来处理网络IO，默认值为4
	
	disk_rw_separated = true		#磁盘读写是否分离
	
	disk_reader_threads=5			#读取磁盘数据的线程数，默认为1
	
	disk_writer_threads=5			#写磁盘的线程数量，默认为1
	
	use_connection_pool=true		#开启连接池
	
	sync_binlog_buff_interval=2		#将binlog buffer写入磁盘的时间间隔
	
	sync_wait_msec=50			#同步文件轮询时间
	
	sync_interval=0				#同步完一个文件休眠时间

#### 启动测试

	①，fastdfs启动、停止和监控：
		
		启动命令：
		
			/usr/bin/fdfs_trackerd /etc/fdfs/tracker.conf
			/usr/bin/fdfs_storaged /etc/fdfs/storage.conf
			
		停止命令：
			
			/usr/bin/fdfs_trackerd /etc/fdfs/tracker.conf stop
			/usr/bin/fdfs_storaged /etc/fdfs/storage.conf stop
			
		监控命令:
			
			/usr/bin/fdfs_monitor /etc/fdfs/client.conf
			
	②，fastdfs文件上传测试：
		
		cd /usr/local/fastdfs
		
		mkdir test
		
		cd ./test
		
		echo test > test.txt
		
		/usr/bin/fdfs_test /etc/fdfs/client.conf upload ./test.txt
	
	④，编写启动脚本： mrh.github.io/installer/fastdfs

#### 集群配置

	配置2个tracker和3个storage（实际同一台服务器可以存在tracker和storage实例）：
	
		tracker 服务器： 
		
			192.168.140.134
			192.168.140.135
		
		storage 服务器：
	
			192.168.140.136
			192.168.140.137
			192.168.140.138
	
	①，在三台服务器上分别安装好单点fastdfs.
	
	②，修改配置文件 /etc/fdfs/storage.conf 和 /etc/fdfs/client.conf：
	
		tracker_server=192.168.140.136:22122
		tracker_server=192.168.140.137:22122
	
	③，启动tracker集群
	
	④，启动storage集群
	
#### 集群错误

	1， item "group_count" is not found
	
		删掉新加入节点的/data目录，拷贝当前Leader 目录下的 /data/*.dat 文件到新节点目录
		
	2，节点一直处于 WAIT_SYNC 状态
	
		删除storage节点数据，重新启动即可
	



