
# Jenkins 持续集成 springboot 服务(docker)

  * 持续集成过程：

        ①，jenkins 从 git 仓库拉取指定分支源码

        ②，jenkins 自动使用 maven 打包可执行 jar

        ③，jenkins 执行源码 docker-build.sh 脚本，将生成的镜像上传到指定私库

        ④，jenkins 传输源码 docker-deploy.sh 脚本到 docker 运行节点，并执行启动容器

  * 官方网站地址：

        https://www.jenkins.io/

        https://mirrors.jenkins-ci.org/war/latest/

  * 三台服务器：

        192.168.140.136         # jenkins 服务器

        192.168.140.136         # docker 镜像仓库

        192.168.140.131         # git 源码

        192.168.140.130         # docker 运行节点

### 准备 git springboot 源码

  * springboot git 源码结构 (创建分支的同时，更改分支代码、脚本中的相关版本号)：

        ssh://git@192.168.140.131/home/repo/test.git

            +- src/main/java
            +  +---------------- org.lushen.mrh.test.Application
            +  +---------------- org.lushen.mrh.test.WelcomeController
            +- src/main/resources
            +  +---------------- application.yml
            +- pom.xml
            +- Dockerfile
            +- docker-build.sh
            +- docker-deploy.sh

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

  * springboot Dockerfile :

        FROM openjdk
        WORKDIR /usr/local/application/
        COPY target/application.jar application.jar
        EXPOSE 8888
        ENTRYPOINT ["java", "-jar","/usr/local/application/application.jar"]

  * springboot docker-build.sh 脚本：

        #!/bin/sh

        # 常量定义
        JAR_NAME=app-test
        JAR_VERSION=v1.0
        REGISTRY_ADDR=192.168.140.136:5000

        # 镜像名称
        ORIGIN_IMAGE_NAME=$JAR_NAME:$JAR_VERSION
        TAG_IMAGE_NAME=$REGISTRY_ADDR/$ORIGIN_IMAGE_NAME

        # 构建镜像
        docker build -t $ORIGIN_IMAGE_NAME $(cd $(dirname $0); pwd)

        # 镜像上传到私库
        docker tag $ORIGIN_IMAGE_NAME $TAG_IMAGE_NAME
        docker push $TAG_IMAGE_NAME

  * springboot docker-deploy.sh 脚本：

        #!/bin/sh

        # 常量定义
        JAR_NAME=app-test
        JAR_VERSION=v1.0
        REGISTRY_ADDR=192.168.140.136:5000

        # 镜像容器名称
        TAG_IMAGE_NAME=$REGISTRY_ADDR/$JAR_NAME:$JAR_VERSION
        CONTIANER_SHORT_NAME=$JAR_NAME
        CONTIANER_FULL_NAME=$JAR_NAME"_"$JAR_VERSION

        # 停止运行相同名称容器
        CONTIANER_ID=$(docker ps --filter name=$CONTIANER_SHORT_NAME* -q)
        if [ $CONTIANER_ID != "" ]; then
            echo 'stop docker container id : $CONTIANER_ID'
            docker stop $CONTIANER_ID
        fi

        # 删除名称和版本相同的容器
        CONTIANER_ID=$(docker ps -a --filter name=$CONTIANER_FULL_NAME -q)
        if [ $CONTIANER_ID != "" ]; then
            echo 'remove docker container id : $CONTIANER_ID'
            docker rm $CONTIANER_ID
        fi

        # 拉取当前版本容器并启动
        docker pull $TAG_IMAGE_NAME

        # 启动容器
        docker run -it -d --name $CONTIANER_FULL_NAME -p 8888:8888 $TAG_IMAGE_NAME

        # 输出启动信息
        CONTIANER_ID=$(docker ps -a --filter name=$CONTIANER_FULL_NAME -q)
        echo 'start docker container id : $CONTIANER_ID'

### 初始化 jenkins 服务器

  * 安装 jdk 运行环境：

        (过程略，jdk 路径 /usr/local/jdk )

  * 安装 maven 编译环境：

        (过程略，maven 路径 /usr/local/maven )

  * 安装 git 客户端：

        (过程略，参考 git 安装与配置，git shell 路径 /bin/git，注意，必须配置 ssh 免密访问 git 服务器)

  * 安装 docker 服务：

        (过程略)

  * 安装 docker registry 私库：

        (过程略，注意在 docker 运行节点配置免登录，当前配置三台服务器免登陆)

### 添加 jenkins 服务相关配置

  * 安装 jenkins 插件：

        ①，Maven Integration

        ②，Publish Over SSH

        ③，SSH

        ④，SSH Agent

        ⑤，Build with Parameters

        ⑥，Git parameter

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

            Git

                【Path to Git executable】一栏输入：/usr/bin/git

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

        第二步，【输入一个任务名称】填写 deploy-docker-boot-test-job

        第三步，选择【构建一个maven项目】

        第四步，点击【确定】

        第五步，输入构建相关配置：

            General

                在【描述】一栏输入任务描述信息

                选中【丢弃旧的构建】：

                    【策略】：默认即可

                    【保持构建的天数】：填入 30 或者其他合适的数值

                    【保持构建的最大个数】：填入 10 或者其他合适的数值

                选中【参数化构建】，添加参数，选择【Git参数】：

                    【名称】：填写 branch

                    【描述】：填写 请选择发布分支

                    【参数类型】：选择 分支

            源码管理

                选择【Git】

                    【Repository URL】输入：ssh://git@192.168.140.131/home/repo/test.git

                    【Credentials】一栏选择【-无-】(因为已经配置了 git 免登录)

                    【Branches to build】一栏【指定分支】输入：${branch}

                    【源码库浏览器】一栏，默认即可

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

                点击【Add post-build step】，选择【执行 shell】

                    【命令】输入： chmod 777 docker-build.sh && sh docker-build.sh

                点击【Add post-build step】，选择【Send files or execute commands over SSH】

                在【SSH Publishers】一栏输入应用服务信息：

                    【Name】：选择应用服务器

                    【Transfers】-【Source files】：填入 docker-deploy.sh

                    【Transfers】-【Remove prefix】：不填写

                    【Transfers】-【Remote directory】：填入 /usr/local/springboot/

                    【Transfers】-【Exec command】：填入执行脚本  chmod 777 /usr/local/springboot/docker-deploy.sh && sh /usr/local/springboot/docker-deploy.sh

                可点击【Add Server】多次输入应用服务信息

        第六步，点击【保存】完成配置

### 执行构建任务

  * 开始构建：

        第一步，进入 deploy-docker-boot-test-job 任务界面

        第二步，点击 Build with Parameters

        第三步，选择需要发布的分支，然后点击开始构建

        第四步，点击 #xx 进入构建界面，查看构建情况

        第五步，点击 控制台输出，查看实时构建日志

        第六步，等待构建完成，如果出错，排查错误原因 (第一次构建，由于 maven 初始化，时间会比较长)

  * 访问发布的应用：

        http://192.168.140.130:8888/
