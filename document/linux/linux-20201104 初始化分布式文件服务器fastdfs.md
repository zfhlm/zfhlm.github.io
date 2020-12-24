
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

#### 编写启动脚本

	脚本目录： mrh.github.io/installer/fastdfs

#### 集群配置

	


