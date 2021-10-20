
#### 自由化构建任务
	
	1，服务器准备
		
		192.168.140.130		#jenkins服务器
		
		192.168.140.134		#远程服务器一
		
		192.168.140.135		#远程服务器二
		
		搭建一个自由化构建任务，执行远程服务器上面的shell脚本
	
	2，安装jenkins插件
	
		点击【系统管理】-【插件管理】-【可选插件】
		
		搜索插件：Publish over SSH
		
		安装完成并重启
	
	3，添加jenkins远程服务器信息
		
		点击【系统管理】-【系统配置】
		
		找到【Publish over SSH】一栏，填写服务器信息：
		
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
	
	4，创建jenkins自由化构建任务
	
		点击【新建任务】
		
		输入任务名称，例如test-job
		
		选择构建一个自由风格的软件项目，点击【确定】
		
		找到【构建后操作】，选择[Send build artifacts over SSH]，填写【SSH Server】信息：
		
			【Name】：选择服务器
			
			【Source files】：不填写
			
			【Remove prefix】：不填写
			
			【Remote directory】：不填写
			
			【Exec command】：填写  cd /usr/local/remote && sh test.sh
		
		点击【Add Server】，可继续添加远程服务器
		
		点击【保存】，创建测试任务完成
	
	5，远程服务器上统一建立shell脚本，输入命令：
		
		cd /usr/local/remote
		
		vi test.sh
		
		=>
		
			#!/bin/sh
			
			echo helloword > test.log
		
		chmod 777 ./test.sh
	
	6，构建jenkins自由化任务
	
		点击进入测试任务界面
		
		点击【立即构建】
		
		等待构建完成，可以在【Build History】一栏查看到构建日志
		
		提示构建成功则完成构建
	
	6，远程服务器查看执行结果，执行命令：
		
		cd /usr/local/remote
		
		cat ./test.log
		
		-> helloworld


