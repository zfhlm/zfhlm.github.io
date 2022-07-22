
# Jenkins 安装与简单构建

  * 官方网站地址：

        https://www.jenkins.io/

        https://mirrors.jenkins-ci.org/war/latest/

  * 三台服务器：

        192.168.140.136         # jenkins 服务器

        192.168.140.130         # 构建测试服务器1

        192.168.140.131         # 构建测试服务器2

### 启动 jenkins 服务

  * jenkins 服务器，下载安装包，输入命令：

        yum -y install fontconfig

        mkdir /usr/local/jenkins

        cd /usr/local/jenkins

        # 注意 jdk 版本要匹配
        wget https://mirrors.jenkins-ci.org/war/2.346/jenkins.war

  * jenkins 服务器，启动 jenkins 服务，输入命令：

        cd /usr/local/jenkins

        nohup java -jar jenkins.war &

        tail -f nohup.out

  * 使用浏览器访问以下地址，进行初始化：

        http://192.168.140.136:8080/

        -> (注意控制台输出的登录密码，使用该密码初始化登录)

            Please use the following password to proceed to installation:

                943edd753f5b4c6a99198264be580152

            This may also be found at: /root/.jenkins/secrets/initialAdminPassword

  * 初始化配置：

        第一步，选择安装推荐的插件，等待完成安装

        第二步，创建第一个管理员用户，填写必要信息

        第三步，实例配置，可以更改访问地址

        第四步，完成初始化

### 添加构建服务器

  * 安装 jenkins 插件

        第一步，点击【Manage Jenkins】

        第二步，点击【Manage Plugins】

        第三步，点击【可选插件】，输入 Publish over SSH

        第四步，勾选插件，点击【Install without restart】，等待安装完成

  * 添加 jenkins 远程服务器

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

### 自由化构建

  * 构建达成目标

        在两台构建测试服务器 /usr/local/test 目录，输出 hello.log，并写入 hello world

  * 创建自由化构建任务

        第一步，点击【新建Item】

        第二步，输入任务名称，例如 echo-hello-job，选择任务类型，选择 Freestyle job，点击【确定】

        第三步，输入构建必要配置：

            【General】 不填

            【源码管理】 不填

            【构建触发器】 不填

            【构建环境】 不填

            【构建】 选择 [Send files or execute commands over SSH]，填写【SSH Server】信息：

                【Name】：选择服务器 192.168.140.130

                【Source files】：不填写

                【Remove prefix】：不填写

                【Remote directory】：不填写

                【Exec command】：填写 mkdir -p /usr/local/test && echo 'hello world' > /usr/local/test/hello.log

                【Add Server】 重复以上步骤配置 192.168.140.131

        第四步，【保存】返回构建界面

  * 执行自由化构建任务

        第一步，进入 echo-hello-job 构建界面

        第二步，点击【立即构建】

        第三步，等待构建完成，可以在【Build History】一栏查看到构建日志

  * 构建测试服务器查看结果：

        cd /usr/local/test

        cat hello.log

        ->

            hello world

### 参数化构建

  * 构建达成目标

        在两台构建测试服务器 /usr/local/test 目录，输出 hello.log，并写入构建参数传递的字符串

  * 安装参数化构建插件

        第一步，点击【Manage Jenkins】

        第二步，点击【Manage Plugins】

        第三步，点击【可选插件】，输入 Build With Parameters

        第四步，勾选插件，点击【Install without restart】，等待安装完成

  * 创建参数化构建任务

        第一步，点击【新建Item】

        第二步，输入任务名称，例如 echo-hello-parameter-job，选择任务类型，选择 Freestyle job，点击【确定】

        第三步，输入构建必要配置：

            【General】 选中 [This project is parameterized]，点击【添加参数】选择 [String Parameter]

                【名称】： 自定义的名称，例如 message

                【默认值】：可不填写

                【描述】：输入描述信息

            【源码管理】 不填

            【构建触发器】 不填

            【构建环境】 不填

            【构建】 选择 [Send files or execute commands over SSH]，填写【SSH Server】信息：

                【Name】：选择服务器 192.168.140.130

                【Source files】：不填写

                【Remove prefix】：不填写

                【Remote directory】：不填写

                【Exec command】：填写 mkdir -p /usr/local/test && echo ${message} > /usr/local/test/hello.log

                【Add Server】 重复以上步骤配置 192.168.140.131

        第四步，【保存】返回构建界面

  * 执行自由化构建任务

        第一步，进入 echo-hello-parameter-job 构建界面

        第二步，点击【Build with parameters】

        第三步，输入参数 message 的值，例如 zhangsan，点击【开始构建】

        第四步，等待构建完成，可以在【Build History】一栏查看到构建日志

  * 构建测试服务器查看结果：

        cd /usr/local/test

        cat hello.log

        ->

            zhangsan
