
#### 下载安装包

	在国内镜像网站下载安装包：http://mirrors.jenkins-ci.org/war/
	
	下载最后一个版本/war/latest/jenkins.war，要求服务器环境JDK1.8以上

#### 上传启动jenkins

	远程创建服务器目录：
	
		cd /usr/local
		
		mkdir jenkins
		
	上传 jenkins.war 到服务器目录 /usr/local/jenkins
	
	启动 jenkins：
	
		cd /usr/local/jenkins
	
		java -jar jenkins.war

#### 初始化jenkins

	1，浏览器访问jenkins管理界面 http://{ip}:8080
	
	2，选择安装推荐的插件，等待完成安装
	
	3，创建第一个管理员用户，填写必要信息
	
	4，实例配置，可以更改访问地址
	
	5，完成初始化

