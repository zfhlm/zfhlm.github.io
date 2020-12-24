
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

	(请求体限制，zip压缩，http编码，连接超时时间等)

