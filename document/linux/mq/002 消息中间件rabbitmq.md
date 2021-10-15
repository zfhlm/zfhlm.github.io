
#### 安装准备

	访问地址：https://www.rabbitmq.com/news.html
	
	查看最新版本 RabbitMQ 3.9.7 release24 描述：
	
		This release requires Erlang/OTP 23.2 and supports Erlang 24.
	
	该安装包依赖 Erlang 23.2版本
	
	假设服务器IP地址：192.168.140.144

#### 安装erlang

	1，下载安装包
	
		地址：https://www.erlang.org/downloads
		
		下载包：otp_src_23.2.tar.gz
		
		下载完成上传到服务器目录：/usr/local/software
	
	2，安装依赖库，输入命令：
		
		yum -y install make gcc gcc-c++ kernel-devel m4 ncurses-devel openssl-devel 
		
		yum -y install unixODBC-devel libtool libtool-ltdl-devel
	
	3，解压配置：
	
		输入命令：
		
			cd /usr/local/software
			
			tar -zxvf ./otp_src_23.2.tar.gz
			
			cd ./otp_src_23.2
			
			./configure --prefix=/usr/local/erlang-23.2 --without-javac
			
			make && make install
			
			cd ..
			
			rm -rf ./otp_src_23.2
			
			cd /usr/local
			
			ln -s ./erlang-23.2 erlang
		
		配置环境变量，输入命令：
		
			vi /etc/profile
			
			添加以下信息：
				
				export PATH=$PATH:/usr/local/erlang/bin
			
			source /etc/profile
		
	4，测试是否配置成功：
	
		输入命令：
		
			erl -version
		
		输出如下信息安装成功：
		
			Erlang (SMP,ASYNC_THREADS,HIPE) (BEAM) emulator version 11.1.4

#### 安装rabbitmq

	1，下载安装包：
	
		地址：https://github.com/rabbitmq/rabbitmq-server/releases
		
		下载包：rabbitmq-server-generic-unix-3.9.7.tar.xz
		
		下载完成上传到服务器目录：/usr/local/software
	
	2，解压配置：
	
		输入命令：
		
			cd /usr/local/software
			
			tar -xvf ./rabbitmq-server-generic-unix-3.9.7.tar.xz
			
			mv ./rabbitmq_server-3.9.7/ ../
			
			cd ..
			
			ln -s ./rabbitmq_server-3.9.7 rabbitmq
	
	3，启动与停止：
	
		启动命令：
		
			./sbin/rabbitmq-server -detached
		
		停止命令：
		
			./sbin/rabbitmqctl stop
	
	4，用户配置：
		
		创建用户rabbitmq/123456，输入命令：
			
			./sbin/rabbitmqctl add_user rabbitmq 123456
		
		配置rabbitmq管理员权限：
		
			./sbin/rabbitmqctl set_user_tags rabbitmq administrator
			
			./sbin/rabbitmqctl set_permissions -p / rabbitmq '.*' '.*' '.*'
	
	5，开启web管理界面：
		
		输入命令，启用管理界面相关插件(注意，只需执行一次命令，后面不需要再执行)：
		
			./sbin/rabbitmq-plugins enable rabbitmq_management
				
		访问管理界面，使用刚刚创建的rabbitmq账号登录：
		
			http://192.168.140.144:15672/

#### 配置文件

	最新版本的rabbitmq没有自带配置文件，需要自己下载
	
	1，访问官方文档地址：
	
		https://www.rabbitmq.com/configure.html#config-file
		
	2，浏览之后找到示例配置文件下载地址：
	
		https://github.com/rabbitmq/rabbitmq-server/blob/v3.8.x/deps/rabbit/docs/rabbitmq.conf.example
	
	3，服务器输入命令下载：
	
		cd /usr/local/rabbitmq
		
		wget https://github.com/rabbitmq/rabbitmq-server/blob/v3.8.x/deps/rabbit/docs/rabbitmq.conf.example
		
		cp rabbitmq.conf.example rabbitmq.conf
	
	4，重启rabbitmq，输入命令：
	
		./sbin/rabbitmqctl stop
		
		./sbin/rabbitmq-server -detached

#### 安装插件

	假设需要安装延迟队列插件：rabbitmq_delayed_message_exchange
	
	访问地址获取插件下载相关信息：https://www.rabbitmq.com/community-plugins.html
	
	1，下载插件
	
		下载地址：https://github.com/rabbitmq/rabbitmq-delayed-message-exchange/releases
		
		下载文件：rabbitmq_delayed_message_exchange-3.9.0.ez
		
		下载完成上传到rabbitmq插件目录：/usr/local/rabbitmq/plugins
	
	2，启用插件：
	
		输入命令：
		
			cd /usr/local/rabbitmq
			
			./sbin/rabbitmq-plugins enable rabbitmq_delayed_message_exchange
		
		至此完成插件配置

#### 主备模式(haproxy+rabbitmq)

	

#### 镜像模式(haproxy+keepalive+rabbitmq)

	
