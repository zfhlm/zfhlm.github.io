
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

#### 安装插件

	1，安装maven插件
	
		点击【系统管理】
		
		点击【插件管理】
		
		点击【可选插件】
		
		搜索框根据名称查找插件，选中 Maven Integration plugin 插件
		
		点击【Install without retstart】执行安装
	
	2，安装ssh插件
	
		根据以上步骤，搜索 Publish over SSH 插件并安装

#### ssh执行远程shell命令测试任务

	如果未安装 Publish over SSH 插件，请先安装插件
	
	1，添加服务器信息
	
		点击【系统管理】
		
		点击【系统配置】
		
		找到【Publish over SSH】一栏
		
		填写服务器信息：
		
			【Passphrase】：单个或多个服务器登录密码
			
			【Path to key】：不使用私钥不填写
			
			【Key】：不使用私钥不填写
			
			【SSH Servers】：服务器批量地址
			
				【Name】：服务器名称，填写IP地址即可
				
				【Hostname】：服务器地址，填写IP地址即可
				
				【Username】：登录账号
				
				【Remote Directory】：远程工作目录，可在服务上创建一个，例如 /usr/local/remote
			
			点击【Test Configuration】测试服务器连接是否成功
		
		如果需要配置多个服务器，点击【新增】继续填写服务器信息
		
		点击【保存】，然后回到主界面
	
	2，各个服务器上统一建立shell脚本：
		
		cd /usr/local/remote
		
		vi test.sh
		
		输入测试脚本信息：
		
			#!/bin/sh
			echo helloword
		
		chmod 777 ./test.sh
		
	3，创建测试任务
	
		点击【新建任务】
		
		输入任务名称，例如test-job，选择构建一个自由风格的软件项目，点击【确定】
		
		找到【构建环境】一栏，选择 [Send files or execute commands over SSH after the build runs]
		
		填写【SSH Server】信息：
		
			【Name】：选择服务器
			
			【Source files】：不填写
			
			【Remove prefix】：不填写
			
			【Remote directory】：不填写
			
			【Exec command】：输入多行脚本命令
			
				cd /usr/local/remote
				sh test.sh
			
		点击【Add Server】，可继续添加任务服务器
		
		点击【保存】，创建测试任务完成
	
	4，执行测试任务
	
		点击进入测试任务界面
		
		点击【立即构建】
		
		等待构建完成，可以在【Build History】一栏查看到构建日志
		