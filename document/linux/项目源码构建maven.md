
#### 下载maven安装包

	下载地址： https://maven.apache.org/download.cgi
	
	下载 apache-maven-3.8.3-bin.tar.gz 之后上传到服务器 /usr/local/software 目录

#### 解压配置

	1，解压，输入命令：
	
		cd /usr/local/software
		
		tar -zxvf ./apache-maven-3.8.3-bin.tar.gz
		
		mv ./apache-maven-3.8.3 ../
		
		cd ..
		
		ln -s ./apache-maven-3.8.3 maven
	
	2，更改配置信息：
	
		输入命令：
		
			cd /usr/local/maven
			
			mkdir repo
			
			cd ./conf
			
			vi setting.xml
			
		更改以下信息：
		
			<localRepository>/usr/local/maven/repo</localRepository>
	
	3，添加系统环境变量：
	
		输入命令：
		
			vi /etc/profile
			
		添加以下信息：
		
			export MAVEN_HOME=/usr/local/maven
			export PATH=$PATH:$MAVEN_HOME/bin
		
		保存退出编辑，使环境变量生效：
		
			source /etc/profile
		
	4，测试
	
		输入命令：
		
			mvn -v
			
		控制台输出如下信息则成功安装：
		
			Apache Maven 3.8.3 (ff8e977a158738155dc465c6a97ffaf31982d739)
			Maven home: /usr/local/maven
			Java version: 1.8.0_301, vendor: Oracle Corporation, runtime: /usr/local/jdk1.8.0_301/jre
			Default locale: en_US, platform encoding: UTF-8
			OS name: "linux", version: "3.10.0-1160.el7.x86_64", arch: "amd64", family: "unix"
	

