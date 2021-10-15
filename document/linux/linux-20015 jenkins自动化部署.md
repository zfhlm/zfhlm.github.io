
#### 搭建准备

	基于 jenkins、maven、git、ssh 的自动化部署环境搭建.
	
	已有四台服务器：
	
		192.168.140.134		#应用服务器一
		
		192.168.140.135		#应用服务器二
		
		192.168.140.130		#jenkins服务器
		
		192.168.140.139		#git服务器

#### 应用服务器配置

	1，应用服务器一：
	
		安装配置好JDK1.8
		
		路径 /usr/local/jdk
			
	2，应用服务器二：
	
		安装配置好JDK1.8
		
		路径 /usr/local/jdk
	
	3，准备好远程执行目录：
	
		cd /usr/local
		
		mkdir remote

#### jenkins服务器配置

	1，安装配置好JDK1.8：
		
		路径 /usr/local/jdk
	
	2，安装配置好maven：
	
		路径 /usr/local/maven
			
	3，安装 git ：
	
		使用yum安装git
		
		说明：jenkins要连接git服务器使用 git shell，而不是在jenkins作为git仓库使用
	
	4，下载并运行jenkins，安装推荐插件，进入后安装以下插件：
	
		Maven Integration plugin
		
		Publish Over SSH
		
		SSH plugin
		
		SSH Agent Plugin
		
		Build with Parameters

#### git服务器配置

	1，使用yum安装git
	
	2，配置好账号git
	
	3，配置项目仓库

#### 第一步，jenkins全局工具配置：

	1，Maven 配置
	
		在【默认 settings 提供】一栏选择【文件系统中的setting文件】
		
		在【文件路径】输入：/usr/local/maven/conf/settings.xml
		
		在【默认全局 settings 提供】一栏选择【文件系统中的setting文件】
		
		在【文件路径】输入：/usr/local/maven/conf/settings.xml
		
	2，JDK
	
		点击【JDK 安装】下的【新增JDK】
		
		在【别名】输入：jdk1.8
		
		在【JAVA_HOME】输入：/usr/local/jdk
		
		去除【自动安装】选中状态
	
	3，Git
	
		在jenkins服务器使用 find / -name git 命令，可以查看到 git的执行文件路径 /usr/bin/git
		
		在【Path to Git executable】一栏输入：/usr/bin/git
		
	4，Gradle
	
		不用作配置
	
	5，Ant
	
		不用作配置
		
	6，Maven
	
		点击【新增Maven】
		
		在【Name】输入：maven-x.x.x
		
		在【MAVEN_HOME】输入：/usr/local/maven
		
		去除【自动安装】选中状态
	
	7，点击【保存】，至此完成全局工具配置

#### 第二步，jenkins系统配置

	1，点击【系统管理】-【系统配置】，找到【Publish over SSH】一栏
	
	2，配置两台应用服务器：
	
		在【Passphrase】中输入应用服务器密码
		
		不填写【Path to key】
		
		不填写【Key】
		
		在【SSH Servers】一栏点击【新增】
		
		在【Name】一栏输入应用服务器IP地址
		
		在【Hostname】一栏输入应用服务器IP地址
		
		在【Username】一栏输入应用服务器登录账号
		
		在【Remote Directory】 一栏输入远程执行目录，填入之前创建好的目录 /usr/local/remote
		
		点击【Test Configuration】测试应用服务器信息是否填写正确
	
		重复动作创建第二台应用服务器信息
	
	3，点击【保存】，至此完成系统配置

#### 第三步，jenkins服务器配置ssh免密访问git服务器

	1，在jenkins服务器生成ssh公钥和私钥，输入命令：
	
		su - root
		
		cd ~/.ssh
		
		ssh-genkey -t rsa
		
		回车三次确认，可以看到生成了两个文件：私钥文件id_rsa、公钥文件id_rsa.pub
	
	2，登录git服务器，添加刚刚生成的公钥，输入命令：
	
		su - git
		
		cd ~/.ssh
		
		vi authorized_keys
		
		将jenkins服务器上生成的公钥 id_rsa.pub，以一行的方式追加到 authorized_keys 文件中
		
		如果服务器没有此文件，查看[git搭建文档#配置ssh免登陆]
	
	3，至此配置完成

#### 第三步，jenkins新建任务

	1，点击主界面【新建任务】，在【输入一个任务名称】一栏填入项目名称，然后选中【构建一个maven项目】，点击【确定】
	
	2，General
	
		在【描述】一栏输入任务描述信息
		
		选中【丢弃旧的构建】：
		
			【策略】：默认即可
			
			【保持构建的天数】：填入合适的天数
			
			【保持构建的最大个数】：填入合适的个数
	
	2，源码管理
	
		选择【Git】
		
		在【Repository URL】输入：ssh://git@192.168.140.139/home/repository/test
		
		在【Credentials】一栏点击【添加】-【jenkins】
		
		在弹出框中输入jenkins私钥信息：
		
			【Domain】：默认即可
			
			【类型】：选择 SSH Username with primary key
			
			【范围】：默认即可
			
			【ID】：填入 自定义唯一私钥ID即可
			
			【描述】：填入描述信息
			
			【Username】：填入git用户
			
			【Private Key】选中【Enter directly】，点击【Add】，使用文本工具打开私钥文件，将私钥文本粘贴到里面
			
			点击【添加】，完成创建私钥信息
		
		在【Credentials】一栏选中刚刚添加的私钥
		
		在【Branches to build】一栏【指定分支】输入：*/master
		
		在【源码库浏览器】一栏，默认即可
		
	3，构建触发器
	
		去除所有选中状态
		
	4，构建环境
	
		去除所有选中状态
	
	5，Pre Steps
	
		不添加信息
	
	6，Build
	
		在【Root POM】一栏输入：pom.xml
		
		在【Goals and options】一栏输入：clean package -Dmaven.test.skip=true
	
	7，Post Steps
	
		选中【Run only if build succeeds】
		
		点击【Add post-build step】，选择【Send files or execute commands over SSH】
		
		在【SSH Publishers】一栏输入应用服务信息：
		
			【Name】：选择应用服务器
			
			【Transfers】-【Source files】：填入 target/*.jar
			
			【Transfers】-【Remove prefix】：填入target
			
			【Transfers】-【Remote directory】：这里不填写，因为在系统配置应用服务器时，已经填写了地址
			
			【Transfers】-【Exec command】：填入执行脚本  sh /usr/local/remote/startup.sh
		
		可点击【Add Server】多次输入应用服务信息
	
	8，点击【保存】完成配置

#### 第四步，创建git项目

	使用 eclipse 创建一个 springboot 项目
	
	1，springboot启动类：
	
		@Controller
		@RequestMapping
		@SpringBootApplication
		public class Application {
		
			public static void main(String[] args) {
				SpringApplication.run(Application.class, args);
			}
		
			@GetMapping(path="/")
			@ResponseBody
			public String index() {
				return "success";
			}
		
		}
	
	2，application.properties 配置文件：
	
		server.port=8888
	
	3，maven 依赖配置 pom.xml：
	
			<groupId>org.lushen.test</groupId>
			<artifactId>test</artifactId>
			<version>1.0.1.RELEASE</version>
		
			<properties>
				<project.build.sourceEncoding>UTF-8</project.build.sourceEncoding>
				<maven-jar-plugin.version>2.6</maven-jar-plugin.version>
			</properties>
		
			<parent>
				<groupId>org.springframework.boot</groupId>
				<artifactId>spring-boot-starter-parent</artifactId>
				<version>2.1.9.RELEASE</version>
			</parent>
		
			<dependencies>
				<dependency>
					<groupId>org.springframework.boot</groupId>
					<artifactId>spring-boot-starter-web</artifactId>
				</dependency>
			</dependencies>
			
			<build>
				<plugins>
					<plugin>
						<groupId>org.apache.maven.plugins</groupId>
						<artifactId>maven-compiler-plugin</artifactId>
						<configuration>
							<source>1.8</source>
							<target>1.8</target>
							<encoding>UTF-8</encoding>
						</configuration>
					</plugin>
				</plugins>
			</build>
	
	4，将test项目上传到 git服务器：
	
		在项目 test 同级目录打开 git bash，执行命令：
		
			git clone git@192.168.140.139:/home/repo/test.git
			
			git add .
			
			git commit -m '初始提交测试项目'
			
			git push origin master
	
	5，至此完成测试 git 项目的创建和提交

#### 第五步，编写应用服务器脚本

	1，创建脚本文件
	
		cd /usr/local/remote
		
		touch startup.sh
		
		chmod 777 ./startup.sh
	
	2，编写脚本文件：
		
		cd /usr/local/remote
		
		vi startup.sh
		
	3，粘贴以下内容到脚本：
	
		#!/bin/sh
		CheckProcess()
		{
			if [ "$1" = "" ];
			then
				return 1
			fi
		
			PROCESS_NUM=$(ps -ef|grep "$1"|grep -v "grep"|wc -l)
			if [ "$PROCESS_NUM" = "1" ];
			then
				return 0
			else
				return 1
			fi
		}
		
		CheckProcess "/usr/local/remote/test-1.0.1.RELEASE.jar"
		CheckQQ_RET=$?
		if [ "$CheckQQ_RET" = "0" ];
		then
			echo "restart test ..."
			kill -9 $(ps -ef|grep /usr/local/remote/test-1.0.1.RELEASE.jar |gawk '$0 !~/grep/ {print $2}' |tr -s '\n' ' ')
			sleep 1
			exec nohup /usr/local/jdk/bin/java -jar /usr/local/remote/test-1.0.1.RELEASE.jar >/dev/null 2>&1 &
			echo "restart test success..."
		else
			echo "restart test..."
			exec nohup /usr/local/jdk/bin/java -jar /usr/local/remote/test-1.0.1.RELEASE.jar >/dev/null 2>&1 &
			echo "restart test success..."
		fi
		
	4，注意：脚本执行不能出现阻塞操作，否则会使jenkins构建任务卡死

#### 第六步，jenkins构建

	1，点击立即构建，等待完成构建任务，可以边查看输出日志
	
	2，在应用服务器使用命令查看 java 进程启动成功： ps -ef | grep java
	
	3，使用浏览器访问自动化部署的应用
	
		http://192.168.140.134:8888/
		
		http://192.168.140.135:8888/

#### 注意

	以上示例都未引入参数化构建
	
	实际的运行环境中，考虑到版本的升级、版本回退、拉取git分支等，一般都会加入参数化去控制整个构建流程

