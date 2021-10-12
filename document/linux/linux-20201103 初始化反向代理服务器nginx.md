
#### 下载安装包

	提前准备好安装包：
	
		pcre-8.41.tar.gz
		
		zlib-1.2.11.tar.gz
		
		openssl-fips-2.0.16.tar.gz
		
		nginx-1.9.9.tar.gz
	
	远程root账号登录，用ftp工具上传到服务器目录：/usr/local/backup

#### 解压编译

	①，初始化编译环境：
	
		yum install gcc-c++
	
	②，安装依赖包：
	
		cd /usr/local/backup
		
		tar -zxvf openssl-fips-2.0.16.tar.gz
		
		cd ./openssl-fips-2.0.16
		
		./config && make && make install
		
		cd /usr/local/backup
		
		tar -zxvf pcre-8.41.tar.gz
		
		cd ./pcre-8.41
		
		./configure && make && make install
		
		cd /usr/local/backup
		
		tar -zxvf zlib-1.2.11.tar.gz
		
		cd ./zlib-1.2.11
		
		./configure && make && make install
		
	③，安装Nginx：
	
		cd /usr/local/backup
		
		tar -zxvf ./nginx-1.9.9.tar.gz
		
		cd nginx-1.9.9
		
		./configure --prefix=/usr/local/nginx --with-http_ssl_module
		
		make && make install

#### 启动测试

	①，启动
	
		cd /usr/local/nginx
		
		./sbin/nginx
	
	②，访问：
	
		http://host:port/

#### 参数配置

	1，worker进程
	
		worker_processes 			#启动几个工作进程
		
		worker_rlimit_nofile		#最大可用的文件描述符个数，需要配合系统的最大描述符
	
	2，http和tcp连接
		
		use epoll					#使用epoll模式的事件
		
		multi_accept on				#使每个worker进程可以同时处理多个客户端请求。
		
		sendfile on					#使用内核的FD文件传输功能
		
		tcp_nopush on				#调用tcp_cork方法进行数据传输。
		
		tcp_nodelay on				#不缓存data-sends
		
		keepalive_timeout			#定义长连接的超时时间
		
		keepalive_requests			#客户端和服务端处于长连接的情况下，每个客户端最多可以请求多少次
		
		reset_timeout_connection	#设置为on的话，当客户端不再向服务端发送请求时，允许服务端关闭该连接
		
		client_body_timeout			#客户端如果在该指定时间内没有加载完body数据，则断开连接
		
		send_timeout				#发送响应的超时时间
	
	3，buffer和cache
	
		client_body_buffer_size		#POST方法提交一些数据到服务端时如果buffer写满会写到临时文件里，建议调整为128k
		
		client_max_body_size		#限制请全体大小
		
		client_header_buffer_size	#设置客户端header的buffer大小，建议4k。
		
		open_file_cache				#设定缓存文件的数量经过多长时间文件没被请求后删除缓存。
		
		open_file_cache_valid		#指多长时间检查一次缓存的有效信息
		
		open_file_cache_min_uses	#文件在inactive时间内一次都没被使用将被移除
	
	4，压缩
	
	　　gzip on;					#开启gzip功能
	
	　　gzip_min_length 1024; 	#设置请求资源超过该数值才进行压缩，单位字节
	
	　　gzip_buffers 16 8k;		#设置压缩使用的buffer大小，第一个数字为数量，第二个为每个buffer的大小
	
	　　gzip_comp_level 6;		#设置压缩级别，范围1-9,9压缩级别最高，也最耗费CPU资源
	
	　　gzip_types text/plain;	#指定哪些类型的文件需要压缩
	
	5，错误日志级别调高，比如crit级别，尽量少记录无关紧要的日志
	
	6，开启ssl缓存，简化服务端和客户端的握手过程
	
	　　ssl_session_cache shared:SSL:10m;		#缓存为10M
		
	　　ssl_session_timeout 10m;				#会话超时时间为10分钟
