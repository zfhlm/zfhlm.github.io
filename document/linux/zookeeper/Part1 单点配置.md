
#### 单点配置

    1，安装包

        下载安装包：apache-zookeeper-3.6.1-bin.tar.gz

        上传到服务器目录：/usr/local/backup/

    2，解压缩，输入命令：

        cd /usr/local/

        tar -zxvf ./backup/apache-zookeeper-3.6.1-bin.tar.gz ./

        ln -s apache-zookeeper-3.6.1-bin zookeeper

    3，基本配置，输入命令：

        cd /usr/local/zookeeper/conf

        cp zoo_sample.cfg zoo.cfg

        vi zoo.cfg

        =>

            dataDir=/usr/local/zookeeper/data
            logDir=/usr/local/zookeeper/logs
            admin.serverPort=18080

    4，JVM内存调优配置，输入命令：

        cd /usr/local/zookeeper

        vi ./conf/java.env

        =>

            #!/bin/sh
            export JAVA_HOME=/usr/java/jdk
            export JVMFLAGS="-Xms512m -Xmx1024m $JVMFLAGS"

    5，日志输出方式调优，输入命令：

        cd /usr/local/zookeeper

        vi ./bin/zkEnv.sh

        =>

            if [ "x${ZOO_LOG4J_PROP}" = "x" ]
            then
            #   ZOO_LOG4J_PROP="INFO,CONSOLE"
                ZOO_LOG4J_PROP="INFO,ROLLINGFILE"
            fi

    6，日志级别调优，输入命令：

        cd /usr/local/zookeeper

        vi ./conf/log4j.properties

        =>

            zookeeper.root.logger=INFO, ROLLINGFILE
            log4j.appender.ROLLINGFILE=org.apache.log4j.DailyRollingFileAppender
            log4j.appender.ROLLINGFILE.Threshold=${zookeeper.log.threshold}
            log4j.appender.ROLLINGFILE.File=${zookeeper.log.dir}/${zookeeper.log.file}
            log4j.appender.ROLLINGFILE.DatePattern='.'yyyy-MM-dd

    7，配置文件调优，输入命令：

        cd /usr/local/zookeeper

        vi ./conf/zoo.cfg

        =>

            tickTime=2000                           #维持心跳的时间间隔
            initLimit=5                             #主从之间初始连接时能容忍的最多心跳数
            syncLimit=10                            #主从之间请求和应答之间能容忍的最多心跳数
            maxClientCnxns=2000                     #客户端最大连接数
            autopurge.snapRetainCount=10            #保留的文件数目，默认3个
            autopurge.purgeInterval=1               #自动清理snapshot和事务日志，清理频率，单位是小时
            globalOutstandingLimit=200              #等待处理的最大请求数量
            leaderServes=yes                        #leader是否接受client请求

    8，启停zookeeper，输入命令：

        cd /usr/local/zookeeper/

        ./bin/zkServer.sh start

        ./bin/zkServer.sh status

        ./bin/zkServer.sh stop
