
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
			
			cp /etc/keepalived/keepalived.conf /etc/keepalived/keepalived.conf.bak
			
			vi /etc/keepalived/keepalived.conf
		
		粘贴以下内容到配置文件：
		
			! Configuration File for keepalived
			
			global_defs {
			    router_id nka_master
			}
			
			vrrp_script promise_nginx_or_kill_myself {
			    script "/etc/keepalived/promise_nginx_or_kill_myself.sh"
			    interval 2
			    weight -5
			    fall 2
			    rise 1
			}
			
			vrrp_instance VI_1 {
			
			    state MASTER
			    interface ens33
			    mcast_src_ip 192.168.140.147
			    virtual_router_id 51
			    priority 101
			    advert_int 1  
			
			    authentication {
			        auth_type PASS
			        auth_pass nginx123456
			    }
			
			    virtual_ipaddress {
			        192.168.140.200
			    }
			
			    track_script {
			       promise_nginx_or_kill_myself
			    }
			
			}
	
	3，配置 backup 服务器 keepalived
		
		输入命令编辑配置文件：
			
			cp /etc/keepalived/keepalived.conf /etc/keepalived/keepalived.conf.bak
			
			vi /etc/keepalived/keepalived.conf
		
		粘贴以下内容到配置文件：
			
			! Configuration File for keepalived
			
			global_defs {
			    router_id nka_backup
			}
			
			vrrp_script promise_nginx_or_kill_myself {
			    script "/etc/keepalived/promise_nginx_or_kill_myself.sh"
			    interval 2
			    weight -5
			    fall 2
			    rise 1
			}
			
			vrrp_instance VI_1 {
				
			    state BACKUP
			    interface ens33
			    mcast_src_ip 192.168.140.148
			    virtual_router_id 51
			    priority 100
			    advert_int 1  
				
			    authentication {
			        auth_type PASS
			        auth_pass nginx123456
			
			    }
				
			    virtual_ipaddress {
			        192.168.140.200
			    }
				
			    track_script {
			       promise_nginx_or_kill_myself
			    }
			
			}
	
	4，配置主备服务器检测脚本
	
		脚本的作用：
		
			检测本机nginx的存活状况，如果nginx非存活状态，尝试启动nginx
			
			如果启动本机nginx不成功，将keepalived进程杀死，使VIP转移到另一台服务器
		
		输入命令：
		
			cd /etc/keepalived/
			
			touch promise_nginx_or_kill_myself.sh
			
			chmod 777 ./promise_nginx_or_kill_myself.sh
			
			vi ./promise_nginx_or_kill_myself.sh
		
		将以下内容粘贴到脚本内容：
		
			#!/bin/sh
			if [ $(ps -C nginx --no-header |wc -l) -eq 0 ]
			then
				/usr/local/nginx/sbin/nginx
				sleep 1
				if [ $(ps -C nginx --no-header |wc -l) -eq 0 ]
				then
					systemctl stop keepalived
				fi
			fi
		
	5，启动主备服务器的keepalived
	
		主备服务器都执行命令：
		
			service keepalived start
		
		浏览器访问以下地址：
		
			http://192.168.140.200/
		
		可以看到浏览器界面显示的是 master服务器nginx欢迎页
	
	7，测试主备keepalived功能
	
		关闭 master服务器 nginx 或杀死 master 服务器keepalived，刷新浏览器地址：http://192.168.140.200/
		
		可以看到浏览器界面显示 backup服务器nginx欢迎页
		
		重启master服务器nginx和keepalived，刷新浏览器地址：http://192.168.140.200/
		
		可以看到显示界面已经切换回master服务器nginx欢迎页

#### 双主模式(nginx+keepalived)

	1，配置前准备工作
		
		主服务器一： 192.168.140.147
		
		主服务器二： 192.168.140.148
		
		双机VIP：192.168.140.200、192.168.140.201
		
		两台服务器都安装好 nginx、keepalived
		
		启动nginx服务，将 nginx 的 index.html 都加上各自的IP地址
	
	2，配置主服务器一 keepalived
	
		输入命令编辑配置文件：
			
			vi /etc/keepalived/keepalived.conf
		
		粘贴以下内容到配置文件：
			
			! Configuration File for keepalived
			
			global_defs {
			    router_id nka_master_147
			}
			
			vrrp_script promise_nginx_or_kill_myself {
			    script "/etc/keepalived/promise_nginx_or_kill_myself.sh"
			    interval 2
			    weight -5
			    fall 2
			    rise 1
			}
			
			vrrp_instance VI_1 {
				
			    state MASTER
			    interface ens33
			    mcast_src_ip 192.168.140.147
			    virtual_router_id 51
			    priority 101
			    advert_int 1  
				
			    authentication {
			        auth_type PASS
			        auth_pass 123456
			    }
				
			    virtual_ipaddress {
			        192.168.140.200
			    }
				
			    track_script {
			       promise_nginx_or_kill_myself
			    }
			
			}
			
			vrrp_instance VI_2 {
				
			    state BACKUP
			    interface ens33
			    mcast_src_ip 192.168.140.147
			    virtual_router_id 52
			    priority 100
			    advert_int 1  
				
			    authentication {
			        auth_type PASS
			        auth_pass 456789
			    }
				
			    virtual_ipaddress {
			        192.168.140.201
			    }
				
			    track_script {
			       promise_nginx_or_kill_myself
			    }
			
			}
	
	2，配置主服务器二 keepalived
	
		输入命令编辑配置文件：
			
			vi /etc/keepalived/keepalived.conf
		
		粘贴以下内容到配置文件：
				
			! Configuration File for keepalived
			
			global_defs {
			    router_id nka_master_148
			}
			
			vrrp_script promise_nginx_or_kill_myself {
			    script "/etc/keepalived/promise_nginx_or_kill_myself.sh"
			    interval 2
			    weight -5
			    fall 2
			    rise 1
			}
			
			vrrp_instance VI_1 {
				
			    state BACKUP
			    interface ens33
			    mcast_src_ip 192.168.140.148
			    virtual_router_id 51
			    priority 100
			    advert_int 1  
				
			    authentication {
			        auth_type PASS
			        auth_pass 123456
			    }
				
			    virtual_ipaddress {
			        192.168.140.200
			    }
				
			    track_script {
			       promise_nginx_or_kill_myself
			    }
			
			}
			
			vrrp_instance VI_2 {
				
			    state MASTER
			    interface ens33
			    mcast_src_ip 192.168.140.148
			    virtual_router_id 52
			    priority 101
			    advert_int 1  
				
			    authentication {
			        auth_type PASS
			        auth_pass 456789
			    }
				
			    virtual_ipaddress {
			        192.168.140.201
			    }
				
			    track_script {
			       promise_nginx_or_kill_myself
			    }
			
			}
	
	4，配置双主服务器检测脚本
	
		(配置方式和主备模式一致)
	
	5，启动双主服务器的keepalived
	
		服务器都执行命令：
		
			service keepalived start
		
		浏览器访问以下地址：
		
			http://192.168.140.200/
		
			http://192.168.140.201/
		
		可以看到浏览器界面显示分别显示两台服务器的欢迎页
	
	7，测试双主keepalived功能
	
		关闭 主服务器一 nginx和keepalived，刷新浏览器地址：http://192.168.140.200/
		
		可以看到浏览器界面显示 主服务器二nginx欢迎页
		
		重启主服务器一 nginx和keepalived，刷新浏览器地址：http://192.168.140.200/
		
		可以看到显示界面已经切换回主服务器一nginx欢迎页

