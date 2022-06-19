
#### 界面管理工具cmak

    1，下载 cmak：

        https://github.com/yahoo/CMAK/releases

        下载安装包：cmak-3.0.0.5.zip

        上传到 192.168.140.141 服务器

    2，解压安装包，输入命令：

        cd /usr/local/software

        unzip ./cmak-3.0.0.5.zip

        mv ./cmak-3.0.0.5 /usr/local

        cd /usr/local

        ln -s ./cmak-3.0.0.5 cmak

    3，更改配置，输入命令：

        cd /usr/local/cmak/conf

        vi application.conf

        =>

            kafka-manager.zkhosts="192.168.140.141:2181,192.168.140.142:2181,192.168.140.143:2181"
            cmak.zkhosts="192.168.140.141:2181,192.168.140.142:2181,192.168.140.143:2181"

    4，指定运行jdk版本

        官方最新版本需要jdk11及以上版本，如果服务器版本更低，需要下载jdk然后指定版本运行

        下载jdk11并解压，输入命令：

            cd /usr/local/software

            tar -zxvf jdk-11.0.12_linux-x64_bin.tar.gz

            mv ./jdk-11.0.12 /usr/local

            ln -s ./jdk-11.0.12 jdk11

        更改 cmak 启动脚本，输入命令：

            cd /usr/local/cmak/bin

            vi cmak

            =>

                export JAVA_HOME=/usr/local/jdk11/
                export JRE_HOME=${JAVA_HOME}/jre
                export CLASSPATH=.:${JAVA_HOME}/lib:${JRE_HOME}/lib
                export PATH=.:${JAVA_HOME}/bin:$PATH

    5，启动cmak，输入命令：

        cd /usr/local/cmak/bin

        ./cmak

    6，添加需要管理的kafka集群：

        访问web页面 http://192.168.140.141:9000/

        点击界面【Cluster】

        选择【Add Cluster】

        输入创建信息：

            【Cluster Name】：kafka集群名称

            【Cluster Zookeeper Hosts】：kafka集群地址，例如 192.168.140.141:2181,192.168.140.142:2181,192.168.140.143:2181

            【Kafka Version】：kafka版本

            【Enable JMX Polling】：按需开启，如果开启则kafka必须开启JMX功能，这样可以获取更多信息

            其他信息按需配置

        点击【Save】提交保存

        回到监控界面，查看和管理kafka集群
