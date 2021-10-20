
# 双主模式(haproxy+keepalived)

### 服务器准备

	192.168.140.149		#haproxy节点一，负载均衡代理端口9050
	
	192.168.140.150		#haproxy节点二，负载均衡代理端口9050
	
	192.168.140.149		#tcp应用节点一，服务端口9000
	
	192.168.140.150		#tcp应用节点二，服务端口9000
	
	192.168.140.202		#keepalived VIP 一
	
	192.168.140.203		#keepalived VIP 二
	
	复用四层tcp负载均衡搭建的环境
	
	双主服务器都安装好 keepalived

### 配置主服务器一 keepalived
	
	输入命令编辑配置文件：
		
		vi /etc/keepalived/keepalived.conf
	
		=>
			
			! Configuration File for keepalived
			
			global_defs {
			    router_id hka_149
			}
			
			# 如果haproxy进程存在，不做任何操作；如果haproxy进程不存在，杀死keepalived
			vrrp_script chk_haproxy {
			    script "/usr/bin/pkill -0 haproxy || systemctl stop keepalived"
			    interval 2
			    weight -5
			    fall 2
			    rise 1
			}
			
			vrrp_instance VI_1 {
			
			    state MASTER
			    interface ens33
			    mcast_src_ip 192.168.140.149
			    virtual_router_id 51
			    priority 101
			    advert_int 1  
			
			    authentication {
			        auth_type PASS
			        auth_pass haproxy123456
			    }
			
			    virtual_ipaddress {
			        192.168.140.202
			    }
			
			    track_script {
			       chk_haproxy
			    }
			
			}
			
			vrrp_instance VI_2 {
			
			    state BACKUP
			    interface ens33
			    mcast_src_ip 192.168.140.149
			    virtual_router_id 52
			    priority 100
			    advert_int 1  
			
			    authentication {
			        auth_type PASS
			        auth_pass haproxy456789
			    }
			
			    virtual_ipaddress {
			        192.168.140.203
			    }
			
			    track_script {
			       chk_haproxy
			    }
			
			}
	
### 配置主服务器二 keepalived
	
	输入命令编辑配置文件：
		
		vi /etc/keepalived/keepalived.conf
		
		=>
						
			! Configuration File for keepalived
			
			global_defs {
			    router_id hka_150
			}
			
			# 如果haproxy进程存在，不做任何操作；如果haproxy进程不存在，杀死keepalived
			vrrp_script chk_haproxy {
			    script "/usr/bin/pkill -0 haproxy || systemctl stop keepalived"
			    interval 2
			    weight -5
			    fall 2
			    rise 1
			}
			
			vrrp_instance VI_1 {
			
			    state BACKUP
			    interface ens33
			    mcast_src_ip 192.168.140.150
			    virtual_router_id 51
			    priority 100
			    advert_int 1  
				
			    authentication {
			        auth_type PASS
			        auth_pass haproxy123456
			    }
			
			    virtual_ipaddress {
			        192.168.140.202
			    }
			
			    track_script {
			       chk_haproxy
			
			    }
			
			}
			
			vrrp_instance VI_2 {
				
			    state MASTER
			    interface ens33
			    mcast_src_ip 192.168.140.150
			    virtual_router_id 52
			    priority 101
			    advert_int 1  
			
			    authentication {
			        auth_type PASS
			        auth_pass haproxy456789
			    }
				
			    virtual_ipaddress {
			        192.168.140.203
			    }
			
			    track_script {
			       chk_haproxy
			    }
			
			}

### 启动keepalived

	双主服务器都输入命令：
		
		service keepalived start

### 连接测试
	
	使用四层tcp负载均衡示例的客户端进行测试，选择以下地址：
	
		192.168.140.202		#端口9050
		
		192.168.140.203		#端口9050
	
	先对两个地址的tcp代理进行测试
	
	再关闭其中一个keepalived，对VIP转移进行测试


