
# keepalived 单点配置

### 下载安装包

	下载地址：https://www.keepalived.org/download.html
	
	下载包：keepalived-2.2.4.tar.gz
	
	下载后上传到服务器目录：/usr/local/software

#### 编译安装

	yum install -y gcc-c++
	
	yum install -y openssl openssl-devel
	
	yum install -y libnl*
	
	cd /usr/local/software
	
	tar -zxvf ./keepalived-2.2.4.tar.gz
	
	cd ./keepalived-2.2.4
	
	./configure --prefix=/usr/local/keepalived
	
	make && make install
	
### 注册系统服务
	
	cd /usr/local/software/keepalived-2.2.4
	
	cp ./keepalived/etc/init.d/keepalived /etc/init.d/
	
	chmod 755 /etc/init.d/keepalived
	
	cd /usr/local/keepalived
	
	mkdir -p /etc/keepalived/
	
	cp ./etc/keepalived/keepalived.conf /etc/keepalived/keepalived.conf
	
	mkdir -p /etc/sysconfig/
	
	cp ./etc/sysconfig/keepalived /etc/sysconfig/keepalived
	
### 配置服务开机自启动
	
	chkconfig –add keepalived
	
	chkconfig keepalived on
	
	chkconfig –list
	
### 启动keepalived

	启动前需要根据配合使用的 nginx、mysql、HA-Proxy等各自做进一步的配置
	
	启动命令： service keepalived start
		
	停止命令： service keepalived stop


