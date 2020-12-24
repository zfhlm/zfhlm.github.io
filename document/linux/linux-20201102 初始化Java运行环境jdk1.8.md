
#### 下载安装包

	在oracle官网下载安装包：jdk-8u161-linux-x64.tar.gz
	
	登录远程账号test，使用ftp工具上传到linux服务器目录：/usr/local/backup/

#### 解压安装

	①，解压jdk文件，执行命令：
	
		cd /usr/local/backup
		
		tar -zxvf ./jdk-8u161-linux-x64.tar.gz
	
	③，移动jdk解压缩目录
	
		sudo mv ./jdk1.8.0_161 ../
		
		cd ..
		
		sudo chown test:test ./jdk1.8.0_161
	
	④，创建jdk目录软引用链接
	
		sudo ln -s ./jdk1.8.0_161 ./jdk

#### 配置环境变量

	①，执行命令进入vim模式：
	
		sudo vi /etc/profile
	
	②，在最后面添加三行配置：
	
		export JAVA_HOME=/usr/local/jdk
		export PATH=$JAVA_HOME/bin:$PATH
		export CLASSPATH=.:$JAVA_HOME/lib/dt.jar:$JAVA_HOME/lib/tools.jar
	
	③，刷新环境变量：
	
		source /etc/profile
		
	④，检查配置是否成功：
	
		java -version

