
#### web控制台配置

    1，下载源码包

        下载地址：https://github.com/apache/rocketmq-dashboard/releases/

        下载包：rocketmq-dashboard-rocketmq-dashboard-1.0.0.tar.gz

        上传到服务器目录：/usr/local/software

    2，解压编译，输入命令：

        cd /usr/local/software

        tar -zxvf ./rocketmq-dashboard-rocketmq-dashboard-1.0.0.tar.gz

        cd ./rocketmq-dashboard-rocketmq-dashboard-1.0.0

        mvn clean package -Dmaven.test.skip=true

        mkdir /usr/local/dashboard-rocketmq/

        mv ./target/rocketmq-dashboard-1.0.0.jar /usr/local/dashboard-rocketmq/

    3，启动控制台进程，输入命令：

        cd /usr/local/dashboard-rocketmq/

        nohup java -jar rocketmq-dashboard-1.0.0.jar &

    4，修改配置，更改jar配置文件：

        rocketmq-dashboard-1.0.0.jar/BOOT-INF/classes/application.properties
