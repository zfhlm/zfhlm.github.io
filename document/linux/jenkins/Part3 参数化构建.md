
#### 参数化构建任务

    1，服务器准备

        192.168.140.130        #jenkins服务器

        192.168.140.134        #远程服务器一

        192.168.140.135        #远程服务器二

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
