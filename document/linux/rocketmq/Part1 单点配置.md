
#### 单点配置

    1，下载安装包

        文档地址：https://rocketmq.apache.org/docs/quick-start/

        下载地址：https://github.com/apache/rocketmq/releases

        下载安装包：rocketmq-rocketmq-all-4.9.1.tar.gz

        上传到服务器目录：/usr/local/software

    2，环境准备

        安装配置好jdk-1.8

        安装配置好maven-3.8.3

    3，解压编译，输入命令：

        cd /usr/local/software

        tar -zxvf ./rocketmq-rocketmq-all-4.9.1.tar.gz

        cd rocketmq-rocketmq-all-4.9.1

        mvn -Prelease-all -DskipTests clean install -U

        cd ./distribution/target/rocketmq-4.9.1

        mv ./rocketmq-4.9.1/ /usr/local/

        cd /usr/local

        ln -s ./rocketmq-4.9.1 rocketmq

        cd /usr/local/software/

        rm -rf ./rocketmq-rocketmq-all-4.9.1

    4，启动 Name Server，输入命令：

        cd /usr/local/rocketmq

        nohup sh bin/mqnamesrv &

        tail -f ~/logs/rocketmqlogs/namesrv.log

    5，启动 Broker，输入命令：

        cd /usr/local/rocketmq

        nohup sh bin/mqbroker -n localhost:9876 &

        tail -f ~/logs/rocketmqlogs/broker.log

    6，停止 Name Server 和 Broker，输入命令：

        cd /usr/local/rocketmq

        sh bin/mqshutdown broker

        sh bin/mqshutdown namesrv

    7，调整JVM内存占用，输入命令：

        cd /usr/local/rocketmq

        vi ./bin/runserver.sh

        =>

            JAVA_OPT="${JAVA_OPT} -server -Xms4g -Xmx4g -Xmn2g -XX:MetaspaceSize=128m -XX:MaxMetaspaceSize=320m"

        cd /usr/local/rocketmq

        vi ./bin/runbroker.sh

        =>

            JAVA_OPT="${JAVA_OPT} -server -Xms8g -Xmx8g"

    8，配置Broker，输入命令：

        cd /usr/local/rocketmq

        vi conf/broker.conf

        常用配置参数含义：

            namesrvAddr                           #NameServer地址，多个用分号隔开

            brokerClusterName                     #Broker所属集群名称，同一集群名称一致

            brokerName                            #Broker名称，主备名称一致

            brokerId                              #0为Master，大于0为 Slave，Slave多个可以不同数值进行区别

            listenPort                            #监听的端口

            brokerIP1                             #IP地址，多个分号隔开

            storePathCommitLog                    #提交日志保存目录

            storePathConsumerQueue                #队列消费记录保存目录

            mapedFileSizeCommitLog                #mapped file文件大小

            deleteWhen                            #当天几点删除过期提交日志

            fileReserverdTime                     #提交日志过期时间小时

            brokerRole                            #Broker角色，可选 SYNC_MASTER/ASYNC_MASTER/SLAVE

            flushDiskType                         #刷盘策略，可选 SYNC_FLUSH/ASYNC_FLUSH
