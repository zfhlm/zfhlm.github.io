
#### 安装jenkins

	1，下载安装包
	
		下载地址 http://mirrors.jenkins-ci.org/war/
		
		下载包 /war/latest/jenkins.war
		
		上传到服务器目录 /usr/local/jenkins/
	
	2，运行环境准备
	
		服务器必须配置jdk1.8
	
	3，启动jenkins，输入命令：
	
		cd /usr/local/jenkins
	
		java -jar jenkins.war
	
	4，初始化jenkins：
		
		浏览器访问jenkins管理界面 http://{ip}:8080
		
		选择安装推荐的插件，等待完成安装
		
		创建第一个管理员用户，填写必要信息
		
		实例配置，可以更改访问地址
		
		完成初始化


