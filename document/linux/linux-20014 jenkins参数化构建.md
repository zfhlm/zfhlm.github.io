
#### jenkins参数化构建
	
	搭建一个参数化构建任务，在执行构建的时候输入参数，将参数传递给远程执行的 shell 脚本命令，然后输出到文件中
	
	1，jenkins安装插件
	
		点击【系统管理】-【插件管理】-【可选插件】
		
		搜索插件：Build With Parameters
		
		安装完成并重启
	
	2，添加远程服务器信息
	
		按 [jenkins自由化构建]里描述的方式添加即可
	
	3，远程服务器上统一建立shell脚本：
		
		cd /usr/local/remote
		
		vi parameter.sh
		
		输入测试脚本信息：
		
			#!/bin/sh
			echo ${1} > parameter.log
		
		chmod 777 ./parameter.sh
	
	4，创建参数化构建任务
				
		点击【新建任务】
		
		输入任务名称，例如 parameter-job
		
		选择构建一个自由风格的软件项目，点击【确定】
		
		找到【General】，选中【参数化构建过程】，输入以下信息：
		
			【文本参数】-【名称】： 自定义的名称，这里示例取名 message
			
			【文本参数】-【默认值】：可不填写
			
			【文本参数】-【描述】：输入描述信息
		
		找到【构建后操作】，选择[Send build artifacts over SSH]，填写【SSH Server】信息：
		
			【Name】：选择服务器
			
			【Source files】：不填写
			
			【Remove prefix】：不填写
			
			【Remote directory】：不填写
			
			【Exec command】：输入多行脚本命令
			
				cd /usr/local/remote
				sh paramter.sh ${message}
				
			注意引用参数的方式为 ${}
		
		点击【Add Server】，可继续添加远程服务器
		
		点击【保存】，创建测试任务完成
	
	5，执行测试任务
	
		点击进入测试任务界面
		
		点击【Build with Parameters】，输入message传递信息：hello
		
		点击【开始构建】
		
		等待构建完成，可以在【Build History】一栏查看到构建日志
		
		提示构建成功则完成构建
	
	6，查看执行结果
	
		回到远程服务器，执行命令：
		
			cd /usr/local/remote
			
			cat ./parameter.log
		
		可以看到里面的hello文本，远程执行脚本成功

#### 参数化构建解决的问题

	一个非参数化构建项目，如果项目构建有所变动，需要更改构建配置，再去立即构建。
	
	参数化构建可以简化构建的流程，例如版本号升级之后，构建配置需要更改，只需更改参数去控制构建配置的变动。



