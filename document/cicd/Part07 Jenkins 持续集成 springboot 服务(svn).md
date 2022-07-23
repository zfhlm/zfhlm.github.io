
# Jenkins 持续集成 springboot 服务(svn)

  * 持续集成过程

        ①，jenkins 从 svn 仓库拉取指定分支源码

        ②，jenkins 自动使用 maven 打包可执行 jar

        ③，jenkins 远程发布 jar 包到目标服务器

        ④，jenkins 远程执行目标服务器 shell 脚本，启动 springboot 服务

        (以下操作与 git 类似，区别在于不需要 git 客户端，以及源码库差异)

  * 官方网站地址：

        https://www.jenkins.io/

        https://mirrors.jenkins-ci.org/war/latest/

  * 三台服务器：

        192.168.140.136         # jenkins 服务器

        192.168.140.130         # springboot 服务器1

        192.168.140.131         # springboot 服务器2

        192.168.140.131         # svn 服务器

### 准备 git springboot 源码

  * springboot 项目相关类：

        @SpringBootApplication
        @ComponentScan(basePackageClasses=Application.class)
        public class Application {

            public static void main(String[] args) {
                SpringApplication.run(Application.class, args);
            }

        }

        @RestController
        @RequestMapping
        public class WelcomeController {

            @GetMapping(path="/")
            public String index() throws IOException {
                return "success";
            }

        }

  * springboot 项目配置：

        server:
          port: 8888
          servlet:
            context-path: /

  * springboot 项目依赖：

        <parent>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-parent</artifactId>
            <version>2.6.0</version>
        </parent>
        <dependencies>
            <dependency>
                <groupId>org.springframework.boot</groupId>
                <artifactId>spring-boot-starter-web</artifactId>
            </dependency>
        </dependencies>
        <build>
            <finalName>application</finalName>
            <plugins>
                <plugin>
                    <groupId>org.springframework.boot</groupId>
                    <artifactId>spring-boot-maven-plugin</artifactId>
                </plugin>
            </plugins>
        </build>

  * 上传到 git 服务器：

        主干地址 svn://192.168.140.131/test/trunk

            +- src/main/java
            +  +---------------- org.lushen.mrh.test.Application
            +  +---------------- org.lushen.mrh.test.WelcomeController
            +- src/main/resources
            +  +---------------- application.yml
            +- pom.xml

        分支地址 svn://192.168.140.131/test/branches/{branch-name}

            +- src/main/java
            +  +---------------- org.lushen.mrh.test.Application
            +  +---------------- org.lushen.mrh.test.WelcomeController
            +- src/main/resources
            +  +---------------- application.yml
            +- pom.xml

### 初始化 springboot 服务器

  * 创建远程执行目录、重启服务的脚本文件：

        mkdir -p /usr/local/springboot

        cd /usr/local/springboot

        # 注意，脚本执行不能出现阻塞操作，否则会使 jenkins 构建任务卡死
        vi startup.sh

        =>

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

            CheckProcess "/usr/local/springboot/application.jar"
            CheckQQ_RET=$?
            if [ "$CheckQQ_RET" = "0" ];
            then
                echo "restart test ..."
                kill -9 $(ps -ef|grep /usr/local/springboot/application.jar |gawk '$0 !~/grep/ {print $2}' |tr -s '\n' ' ')
                sleep 1
                exec nohup /usr/local/jdk/bin/java -jar /usr/local/springboot/application.jar >/dev/null 2>&1 &
                echo "restart test success..."
            else
                echo "restart test..."
                exec nohup /usr/local/jdk/bin/java -jar /usr/local/springboot/application.jar >/dev/null 2>&1 &
                echo "restart test success..."
            fi

        chmod 777 startup.sh

### 初始化 jenkins 服务器

  * 安装 jdk 运行环境：

        (过程略，jdk 路径 /usr/local/jdk )

  * 安装 maven 编译环境：

        (过程略，maven 路径 /usr/local/maven )

### 添加 jenkins 服务相关配置

  * 安装 jenkins 插件：

        ①，Maven Integration

        ②，Publish Over SSH

        ③，SSH

        ④，SSH Agent

        ⑤，Build with Parameters

        ⑥，Subversion

  * 更改 jenkins 全局配置：

        第一步，点击【Manage Jenkins】

        第二步，点击【Global Tool Configuration】

        第三步，填写相关配置：

            Maven 配置

                【默认 settings 提供】一栏选择【文件系统中的setting文件】

                【文件路径】输入：/usr/local/maven/conf/settings.xml

                【默认全局 settings 提供】一栏选择【文件系统中的setting文件】

                【文件路径】输入：/usr/local/maven/conf/settings.xml

            JDK

                【JDK 安装】点击【新增JDK】

                【别名】输入：jdk11

                【JAVA_HOME】输入：/usr/local/jdk

                【自动安装】去除选中状态

            Maven

                【新增Maven】

                【Name】输入：maven-3.8.3

                【MAVEN_HOME】输入：/usr/local/maven

                【自动安装】去除选中状态

        第四步，点击【保存】，至此完成全局工具配置

  * 添加 jenkins 构建远程服务器：

        第一步，点击【Manage Jenkins】

        第二步，点击【Configure System】

        第三步，下拉找到【Publish over SSH】一栏，填写服务器信息：

            【Passphrase】：服务器登录密码，例如 123456

            【Path to key】：不填

            【Key】：不填

            【SSH Servers】：服务器批量地址

                【Name】：服务器名称，例如 192.168.140.130

                【Hostname】：服务器地址，例如 192.168.140.130

                【Username】：登录账号，例如 root

                【Remote Directory】：远程工作目录，例如 /

            点击【Test Configuration】测试服务器连接是否成功

        第四步，如果需要配置多个服务器，点击【新增】，重复第三步操作

        第五步，点击【保存】，然后回到主界面

  * 创建构建任务

        第一步，点击【新增Item】

        第二步，【输入一个任务名称】填写 deploy-svn-boot-test-job

        第三步，选择【构建一个maven项目】

        第四步，点击【确定】

        第五步，输入构建相关配置：

            General

                在【描述】一栏输入任务描述信息

                选中【丢弃旧的构建】：

                    【策略】：默认即可

                    【保持构建的天数】：填入 30

                    【保持构建的最大个数】：填入 10

                选中【参数化构建】，添加参数，选择【List Subversion tags】：

                    【Name】：填写 branch

                    【Repository URL】：填写 svn://192.168.140.131/test/branches

                    【Credentials】：选择 svn 账号密码，如果不存在则添加

                        【Domain】：默认即可

                        【类型】：选择 SSH Username with password

                        【范围】：默认即可

                        【用户名】：填入 svn 用户例如 admin

                        【密码】：填入 svn 密码例如 admin

                        【ID】：填入例如 admin

                        【描述】：填入描述信息例如 svn admin

                        点击【添加】，完成创建私钥信息

                    【Sort Z to A】选中，分支显示倒序

            源码管理

                选择【Subversion】

                在【Repository URL】输入：svn://192.168.140.131/test/branches/${branch}

                在【Credentials】一栏选择刚刚添加的 svn 凭证

                其他信息栏，默认或按需调整

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

                    【Transfers】-【Remote directory】：填入 /usr/local/springboot/

                    【Transfers】-【Exec command】：填入执行脚本  sh /usr/local/springboot/startup.sh

                可点击【Add Server】多次输入应用服务信息

        第六步，点击【保存】完成配置

### 执行构建任务

  * 开始构建：

        第一步，进入 deploy-svn-boot-test-job 任务界面

        第二步，点击 Build with Parameters

        第三步，选择需要发布的分支，然后点击开始构建

        第四步，点击 #xx 进入构建界面，查看构建情况

        第五步，点击 控制台输出，查看实时构建日志

        第六步，等待构建完成，如果出错，排查错误原因 (第一次构建，由于 maven 初始化，时间会比较长)

  * 访问发布的应用：

        http://192.168.140.130:8888/

        http://192.168.140.131:8888/
