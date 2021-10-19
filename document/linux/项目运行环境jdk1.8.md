
#### 配置JDK

	1，下载安装包：
	
		在oracle官网下载安装包 jdk-8u161-linux-x64.tar.gz
		
		上传到服务器目录 /usr/local/backup/
	
	2，解压安装包，输入命令：
	
		cd /usr/local/backup
		
		tar -zxvf ./jdk-8u161-linux-x64.tar.gz
		
		chown root:root ./jdk1.8.0_161
		
		mv ./jdk1.8.0_161 ../
		
		ln -s ./jdk1.8.0_161 ./jdk
	
	3，配置环境变量，输入命令：
	
		vi /etc/profile
	
		=>
			
			export JAVA_HOME=/usr/local/jdk
			export PATH=$JAVA_HOME/bin:$PATH
			export CLASSPATH=.:$JAVA_HOME/lib/dt.jar:$JAVA_HOME/lib/tools.jar
		
		source /etc/profile
		
		java -version


