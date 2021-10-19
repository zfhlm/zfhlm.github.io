
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

#### 参数化构建任务
	
	1，服务器准备
		
		192.168.140.130		#jenkins服务器
		
		192.168.140.134		#远程服务器一
		
		192.168.140.135		#远程服务器二
		
		搭建一个参数化构建任务，在执行构建的时候输入参数，将参数传递给远程执行的 shell 脚本命令，然后输出到文件中
	
	2，安装jenkins插件
	
		点击【系统管理】-【插件管理】-【可选插件】
		
		搜索插件：Build With Parameters
		
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
	
	4，创建jenkins参数化构建任务
				
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
			
			【Exec command】：填写 cd /usr/local/remote && sh paramter.sh ${message}
			
			注意引用参数的方式为 ${}
		
		点击【Add Server】，可继续添加远程服务器
		
		点击【保存】，创建测试任务完成
		
	5，远程服务器上统一建立shell脚本，输入命令：
		
		cd /usr/local/remote
		
		vi parameter.sh
		
		=>
		
			#!/bin/sh
			echo ${1} > parameter.log
		
		chmod 777 ./parameter.sh
	
	6，构建jenkins参数化任务
	
		点击进入测试任务界面
		
		点击【Build with Parameters】，输入message传递信息：hello
		
		点击【开始构建】
		
		等待构建完成，可以在【Build History】一栏查看到构建日志
		
		提示构建成功则完成构建
	
	7，远程服务器查看执行结果，输入命令：
	
		cd /usr/local/remote
		
		cat ./parameter.log
		
		-> hello

#### 自动化部署(jenkins+maven+git+ssh)

	1，服务器准备
	
		192.168.140.134		#应用服务器一，配置好jdk1.8
		
		192.168.140.135		#应用服务器二，配置好jdk1.8
		
		192.168.140.130		#jenkins服务器，配置好jdk1.8、maven、 git shell
		
		192.168.140.139		#git服务器，远程访问用户git
	
	2，安装jenkins服务器插件
		
		Maven Integration plugin
		
		Publish Over SSH
		
		SSH plugin
		
		SSH Agent Plugin
		
		Build with Parameters
	
	3，jenkins全局工具配置
		
		Maven 配置
	
			在【默认 settings 提供】一栏选择【文件系统中的setting文件】
			
			在【文件路径】输入：/usr/local/maven/conf/settings.xml
			
			在【默认全局 settings 提供】一栏选择【文件系统中的setting文件】
			
			在【文件路径】输入：/usr/local/maven/conf/settings.xml
		
		JDK
	
			点击【JDK 安装】下的【新增JDK】
			
			在【别名】输入：jdk1.8
			
			在【JAVA_HOME】输入：/usr/local/jdk
			
			去除【自动安装】选中状态
	
		Git
	
			在jenkins服务器使用 find / -name git 命令，可以查看到 git的执行文件路径 /usr/bin/git
			
			在【Path to Git executable】一栏输入：/usr/bin/git
		
		Maven
	
			点击【新增Maven】
			
			在【Name】输入：maven-x.x.x
			
			在【MAVEN_HOME】输入：/usr/local/maven
			
			去除【自动安装】选中状态
	
		点击【保存】，至此完成全局工具配置
	
	4，jenkins系统配置
		
		点击【系统管理】-【系统配置】，找到【Publish over SSH】一栏
	
		配置两台应用服务器：
	
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
	
		点击【保存】，至此完成系统配置
		
	5，jenkins服务器配置ssh免密访问git服务器
	
		在jenkins服务器生成ssh公钥和私钥，输入命令：
	
			su - root
			
			cd ~/.ssh
			
			ssh-genkey -t rsa
		
		回车三次确认，可以看到生成了两个文件：私钥文件id_rsa、公钥文件id_rsa.pub
	
		登录git服务器，添加刚刚生成的公钥，输入命令：
	
			su - git
			
			mkdir -p ~/.ssh
			
			vi ~/.ssh/authorized_keys
			
			=> 
				
				将jenkins服务器上生成的公钥 id_rsa.pub，以一行的方式追加到 authorized_keys 文件中
			
			chmod 700 -R ~/.ssh
			
			chmod 600 ~/.ssh/authorized_keys
	
	6，jenkins新建任务
	
		点击主界面【新建任务】，在【输入一个任务名称】一栏填入项目名称，然后选中【构建一个maven项目】，点击【确定】
		
		General
		
			在【描述】一栏输入任务描述信息
			
			选中【丢弃旧的构建】：
			
				【策略】：默认即可
				
				【保持构建的天数】：填入合适的天数
				
				【保持构建的最大个数】：填入合适的个数
		
		源码管理
		
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
			
		构建触发器
		
			去除所有选中状态
			
		构建环境
		
			去除所有选中状态
		
		Pre Steps
		
			不添加信息
		
		Build
		
			在【Root POM】一栏输入：pom.xml
			
			在【Goals and options】一栏输入：clean package -Dmaven.test.skip=true
		
		Post Steps
		
			选中【Run only if build succeeds】
			
			点击【Add post-build step】，选择【Send files or execute commands over SSH】
			
			在【SSH Publishers】一栏输入应用服务信息：
			
				【Name】：选择应用服务器
				
				【Transfers】-【Source files】：填入 target/*.jar
				
				【Transfers】-【Remove prefix】：填入target
				
				【Transfers】-【Remote directory】：这里不填写，因为在系统配置应用服务器时，已经填写了地址
				
				【Transfers】-【Exec command】：填入执行脚本  sh /usr/local/remote/startup.sh
			
			可点击【Add Server】多次输入应用服务信息
		
		点击【保存】完成配置
	
	7，创建git项目
		
		使用 eclipse 创建一个 springboot 项目
		
		springboot启动类：
		
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
		
		application.properties 配置文件：
		
			server.port=8888
		
		maven 依赖配置 pom.xml：
		
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
		
		将test项目上传到 git服务器：
		
			在项目 test 同级目录打开 git bash，执行命令：
			
				git clone git@192.168.140.139:/home/repo/test.git
				
				git add .
				
				git commit -m '初始提交测试项目'
				
				git push origin master
		
		至此完成测试 git 项目的创建和提交
		
	8，编写应用服务器脚本
		
		创建脚本文件
		
			cd /usr/local/remote
			
			touch startup.sh
			
			chmod 777 ./startup.sh
		
		编写脚本文件：
			
			cd /usr/local/remote
			
			vi startup.sh
			
		粘贴以下内容到脚本：
		
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
			
		注意：脚本执行不能出现阻塞操作，否则会使jenkins构建任务卡死
	
	9，jenkins构建
		
		点击立即构建，等待完成构建任务，可以边查看输出日志
		
		在应用服务器使用命令查看 java 进程启动成功： ps -ef | grep java
		
		使用浏览器访问自动化部署的应用
		
			http://192.168.140.134:8888/
			
			http://192.168.140.135:8888/
		
		以上示例都未引入参数化构建
	
		实际的运行环境中，考虑到版本的升级、版本回退、拉取git分支等，一般都会加入参数化去控制整个构建流程


