
# 优化配置

#### JVM 参数

    输入命令：

        cd /usr/local/zookeeper

        vi ./conf/java.env

        =>

            #!/bin/sh

            # 根据分配的资源调整各项参数值
            export JVMFLAGS=" \
              -server \
              -Xms1024m \
              -Xmx1024m \
              -Xmn512m \
              -Xss512k \
              -XX:MetaspaceSize=32m \
              -XX:MaxMetaspaceSize=64m \
              -XX:+DisableExplicitGC \
              -XX:+UseG1GC \
              -XX:MaxGCPauseMillis=200 \
              -XX:+PrintGCDetails \
              -XX:+PrintGCDateStamps \
              -XX:+PrintHeapAtGC \
              -XX:+UseGCLogFileRotation \
              -XX:NumberOfGCLogFiles=15 \
              -XX:GCLogFileSize=100M \
              -Xloggc:/usr/local/zookeeper/logs/gc-%t.log \
              $JVMFLAGS"

#### 日志级别

    输入命令：

        cd /usr/local/zookeeper

        vi ./bin/zkEnv.sh

        =>

            if [ "x${ZOO_LOG4J_PROP}" = "x" ]
            then
            #   ZOO_LOG4J_PROP="INFO,CONSOLE"
                ZOO_LOG4J_PROP="INFO,ROLLINGFILE"
            fi

        cd /usr/local/zookeeper

        vi ./conf/log4j.properties

        =>

            zookeeper.root.logger=INFO, ROLLINGFILE
            log4j.appender.ROLLINGFILE=org.apache.log4j.DailyRollingFileAppender
            log4j.appender.ROLLINGFILE.Threshold=${zookeeper.log.threshold}
            log4j.appender.ROLLINGFILE.File=${zookeeper.log.dir}/${zookeeper.log.file}
            log4j.appender.ROLLINGFILE.DatePattern='.'yyyy-MM-dd

#### 配置文件

    更改以下配置：

        clientPort=2181                         #客户端连接端口

        maxClientCnxns=2000                     #客户端最大连接数

        globalOutstandingLimit=200              #等待处理的最大请求数量

        tickTime=2000                           #客户端维持心跳的时间间隔

        dataDir=/usr/local/zookeeper/data       #数据存储目录

        logDir=/usr/local/zookeeper/logs        #日志存储目录

        admin.enableServer=false                #管理器禁用

        admin.serverPort=18080                  #管理器端口

        initLimit=5                             #主从之间初始连接时能容忍的最多心跳数

        syncLimit=10                            #主从之间请求和应答之间能容忍的最多心跳数

        leaderServes=yes                        #leader是否接受client请求

        autopurge.snapRetainCount=10            #保留的快照文件数目，默认3个

        autopurge.purgeInterval=12              #自动清理snapshot和事务日志，清理频率，单位是小时
