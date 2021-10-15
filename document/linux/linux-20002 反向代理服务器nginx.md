
#### 下载安装包

	提前准备好安装包：
	
		pcre-8.41.tar.gz
		
		zlib-1.2.11.tar.gz
		
		openssl-fips-2.0.16.tar.gz
		
		nginx-1.9.9.tar.gz
		
		perl-5.34.0.tar.gz
		
	准备好两台服务器：
	
		192.168.140.147
		
		192.168.140.148
	
	远程root账号登录，用ftp工具上传到服务器目录：/usr/local/backup

#### 解压编译

	①，初始化编译环境：
	
		yum install gcc-c++
	
	②，安装依赖包：
	
		cd /usr/local/backup
		
		tar -zxvf ./perl-5.34.0.tar.gz
		
		cd ./perl-5.34.0
		
		./Configure -des -Dprefix=/usr/local/perl
		
		make && make test && make install
		
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
	
		http://192.168.140.147
		
		http://192.168.140.148

#### 配置运行参数

	1，worker进程
	
		worker_processes 			#启动几个工作进程
		
		worker_rlimit_nofile			#最大可用的文件描述符个数，需要配合系统的最大描述符
	
	2，http和tcp连接
		
		use epoll				#使用epoll模式的事件
		
		multi_accept on				#使每个worker进程可以同时处理多个客户端请求。
		
		sendfile on				#使用内核的FD文件传输功能
		
		tcp_nopush on				#调用tcp_cork方法进行数据传输。
		
		tcp_nodelay on				#不缓存data-sends
		
		keepalive_timeout			#定义长连接的超时时间
		
		keepalive_requests			#客户端和服务端处于长连接的情况下，每个客户端最多可以请求多少次
		
		reset_timeout_connection		#设置为on的话，当客户端不再向服务端发送请求时，允许服务端关闭该连接
		
		client_body_timeout			#客户端如果在该指定时间内没有加载完body数据，则断开连接
		
		send_timeout				#发送响应的超时时间
	
	3，buffer和cache
	
		client_body_buffer_size			#POST方法提交一些数据到服务端时如果buffer写满会写到临时文件里，建议调整为128k
		
		client_max_body_size			#限制请全体大小
		
		client_header_buffer_size		#设置客户端header的buffer大小，建议4k。
		
		open_file_cache				#设定缓存文件的数量经过多长时间文件没被请求后删除缓存。
		
		open_file_cache_valid			#指多长时间检查一次缓存的有效信息
		
		open_file_cache_min_uses		#文件在inactive时间内一次都没被使用将被移除
	
	4，压缩
	
	　　gzip on;					#开启gzip功能
	
	　　gzip_min_length 1024; 			#设置请求资源超过该数值才进行压缩，单位字节
	
	　　gzip_buffers 16 8k;				#设置压缩使用的buffer大小，第一个数字为数量，第二个为每个buffer的大小
	
	　　gzip_comp_level 6;				#设置压缩级别，范围1-9,9压缩级别最高，也最耗费CPU资源
	
	　　gzip_types text/plain;			#指定哪些类型的文件需要压缩
	
	5，错误日志级别调高，比如crit级别，尽量少记录无关紧要的日志
	
	6，开启ssl缓存，简化服务端和客户端的握手过程
	
	　　ssl_session_cache shared:SSL:10m;			#缓存为10M
		
	　　ssl_session_timeout 10m;				#会话超时时间为10分钟

#### 主备模式(nginx+keepalived)

	1，配置前准备工作
	
		master服务器： 192.168.140.147
		
		backup服务器： 192.168.140.148
		
		VIP：192.168.140.200
		
		两台服务器都安装好 nginx、keepalived
		
		启动nginx服务，将 nginx 的 index.html 都加上各自的IP地址
	
	2，配置 master 服务器 keepalived
	
		输入命令编辑配置文件：
		
			vi /etc/keepalived/keepalived.conf
		
		粘贴以下内容到配置文件：
		
			! Configuration File for keepalived
			
			#全局配置
			global_defs {
			
			    #服务标识符
			    router_id nginx_keepalived_master
			
			}
			
			#定义监控nginx脚本
			vrrp_script chk_nginx {
			
			    #脚本位置
			    script "/etc/keepalived/check_nginx.sh"
			
			    #执行间隔2秒钟
			    interval 2
			
			    #脚本优先级
			    weight -5
			
			    #确定2次失败才算失败
			    fall 2
			
			    #确顶1次成功就算成功
			    rise 1
			
			}
			
			#定义vrrp实例
			vrrp_instance VI_1 {
			
			    #定义为主服务器
			    state MASTER
			
			    #网络接口
			    interface ens33
				
			    #发送多播数据包时的源IP地址，填写master服务器IP地址
			    mcast_src_ip 192.168.140.147
				
			    #虚拟路由标识，MASTER和BACKUP必须一致
			    virtual_router_id 51
			
			    #优先级，MASTER必须大于BACKUP
			    priority 101
			
			    #主备之间同步检查的时间间隔秒
			    advert_int 1  
			
			    #设置主从验证信息
			    authentication {
			
			        #使用密码验证 
			        auth_type PASS
			
			        #验证密码
			        auth_pass 123456
			
			    }
			
			    #设置VIP地址
			    virtual_ipaddress {
			        192.168.140.200
			    }
			
			    #执行nginx检测脚本
			    track_script {
			
			       #引用nginx监控脚本
			       chk_nginx
			
			    }
			
			}
	
	3，配置 backup 服务器 keepalived
		
		输入命令编辑配置文件：
		
			vi /etc/keepalived/keepalived.conf
		
		粘贴以下内容到配置文件：
			
			! Configuration File for keepalived
			
			#全局配置
			global_defs {
			
			    #服务标识符
			    router_id nginx_keepalived_backup
			
			}
			
			#定义监控nginx脚本
			vrrp_script chk_nginx {
			
			    #脚本位置
			    script "/etc/keepalived/check_nginx.sh"
			
			    #执行间隔2秒钟
			    interval 2
			
			    #脚本优先级
			    weight -5
			
			    #确定2次失败才算失败
			    fall 2
			
			    #确顶1次成功就算成功
			    rise 1
			
			}
			
			#定义vrrp实例
			vrrp_instance VI_1 {
			
			    #定义为备用服务器
			    state BACKUP
			
			    #网络接口
			    interface ens33
			
			    #发送多播数据包时的源IP地址，填写backup服务器IP地址
			    mcast_src_ip 192.168.140.148
			
			    #虚拟路由标识，MASTER和BACKUP必须一致
			    virtual_router_id 51
			
			    #优先级，MASTER必须大于BACKUP
			    priority 100
			
			    #主备之间同步检查的时间间隔秒
			    advert_int 1  
			
			    #设置主从验证信息
			    authentication {
			
			        #使用密码验证 
			        auth_type PASS
			
			        #验证密码
			        auth_pass 123456
			
			    }
			
			    #设置VIP地址
			    virtual_ipaddress {
			        192.168.140.200
			    }
			
			    #执行nginx检测脚本
			    track_script {
			
			       #引用nginx监控脚本
			       chk_nginx
			
			    }
			
			}
	
	4，配置主备服务器的nginx监控脚本
	
		输入命令：
		
			cd /etc/keepalived/
			
			touch check_nginx.sh
			
			chmod 777 ./check_nginx.sh
			
			vi ./check_nginx.sh
		
		将以下内容粘贴到脚本内容：
		
			#!/bin/sh
			A=`ps -C nginx --no-header |wc -l`
			if [ $A -eq 0 ]
			then
			  /usr/sbin/nginx
			  sleep 1
			  A2=`ps -C nginx --no-header |wc -l`
			  if [ $A2 -eq 0 ]
			  then
			    systemctl stop keepalived
			  fi
			fi
		
		脚本含义：如果 nginx 停止运行，尝试启动，但是如果无法启动，则杀死本机的 keepalived 进程
	
	5，启动主备服务器的keepalived
	
		主备服务器都执行命令：
			
			service keepalived start
	
	6，使用VIP访问nginx
	
		浏览器输入地址：
		
			http://192.168.140.200/
			
		可以看到浏览器界面显示的是 master服务器 192.168.140.147 nginx欢迎页
	
	7，测试主备keepalived功能
	
		关闭 master服务器 192.168.140.147 上的nginx
		
		刷新浏览器地址：
		
			http://192.168.140.200/
		
		可以看到浏览器界面显示 backup服务器  192.168.140.148 nginx欢迎页
		
		重新启动master服务器 192.168.140.147 上的nginx和keepalived，输入命令：
		
			cd /usr/local/nginx
			
			./sbin/nginx
			
			service keepalived start
		
		刷新浏览器地址：
		
			http://192.168.140.200/
		
		可以看到显示界面已经切换回master服务器
	
	8，至此完成了nginx的主备模式配置

#### 双主模式(nginx+keepalived)




