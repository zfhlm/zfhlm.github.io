
#### Java运行环境配置

  * 下载安装包：

        在oracle官网下载安装包 jdk-8u161-linux-x64.tar.gz

        上传到服务器目录 /usr/local/backup/

  * 解压安装包，输入命令：

        cd /usr/local/backup

        tar -zxvf ./jdk-8u161-linux-x64.tar.gz

        chown root:root ./jdk1.8.0_161

        mv ./jdk1.8.0_161 ../

        ln -s ./jdk1.8.0_161 ./jdk

  * 配置环境变量，输入命令：

        vi /etc/profile

        =>

            export JAVA_HOME=/usr/local/jdk
            export PATH=$JAVA_HOME/bin:$PATH
            export CLASSPATH=.:$JAVA_HOME/lib/dt.jar:$JAVA_HOME/lib/tools.jar

        source /etc/profile

        java -version

#### Java8 JVM 内存模型

  * JVM 内存划分：

        程序计数寄存器：当前线程所执行的Java字节码的行号指示器

        虚拟机栈：每个方法执行的同时都会创建一个栈帧，用于存储局部变量表、操作数栈、动态链接、方法出口等信息

        本地方法栈：与虚拟机栈类似，作用于 native 方法

        元数据空间：用于存储类信息、编译后的代码数据等

        堆空间：分为新生代、老年代，而新生代又分为 1个 Eden 区和 2个 Survivor 区

  * 垃圾回收：

        Young GC：只收集young gen的GC

        Old GC：只收集old gen的GC，只有CMS的concurrent collection是这个模式

        Mixed GC：收集整个young gen以及部分old gen的GC，只有G1有这个模式

        Full GC：收集整个堆，包括young gen、old gen、perm gen（如果存在的话）等所有部分的模式

        Major GC：通常是跟full GC是等价的，收集整个GC堆

#### 生产环境调优

  * 启动参数：

        -server                                       #使用服务器模式启动

        -Xms1024m                                     #堆空间初始值，默认为物理内存的1/64，一般设置为可使用内存的 5/8

        -Xmx1024m                                     #堆空间最大值，默认为物理内存的1/4，一般设置为可使用内存的 5/8

        -Xmn512m                                      #堆空间新生代大小，默认新生代/老年代=1/2，新生代+老年代=堆空间内存，根据实际情况调整

        -Xss256k                                      #线程栈内存大小，默认linux 64bit系统下为1m

        -XX:MetaspaceSize=64m                         #元空间初始值，默认不限制，根据实际情况调整

        -XX:MaxMetaspaceSize=128m                     #元空间最大值，默认无限，根据实际情况调整

        -XX:+DisableExplicitGC                        #忽略应用程序调用GC

        -XX:+UseG1GC                                  #使用G1垃圾收集器

        -XX:MaxGCPauseMillis=200                      #使用G1垃圾收集器期望停顿时间

        -XX:+PrintGCDetails                           #打印GC详细日志

        -XX:+PrintGCDateStamps                        #打印GC的日期时间戳

        -XX:+PrintHeapAtGC                            #打印GC前后堆信息

        -XX:+UseGCLogFileRotation                     #打印GC日志启用分割

        -XX:NumberOfGCLogFiles=15                     #打印GC日志文件数量限制

        -XX:GCLogFileSize=100M                        #打印GC日志文件大小限制

        -Xloggc:/usr/local/logs/gc-%t.log             #打印GC日志位置，名称携带时间戳

        -XX:+HeapDumpOnOutOfMemoryError               #打印内存溢出错误日志

        -XX:HeapDumpPath=/usr/local/logs/heap.dump    #打印内存溢出错误日志位置

  * 使用示例：

        nohup java -jar
            -server
            -Xms1024m
            -Xmx1024m
            -Xmn512m
            -Xss512k
            -XX:MetaspaceSize=64m
            -XX:MaxMetaspaceSize=128m
            -XX:+DisableExplicitGC
            -XX:+UseG1GC
            -XX:MaxGCPauseMillis=200
            -XX:+PrintGCDetails
            -XX:+PrintGCDateStamps
            -XX:+PrintHeapAtGC
            -XX:+UseGCLogFileRotation
            -XX:NumberOfGCLogFiles=15
            -XX:GCLogFileSize=100M
            -Xloggc:/usr/local/logs/gc-%t.log
            -XX:+HeapDumpOnOutOfMemoryError
            -XX:HeapDumpPath=/usr/local/logs/heap.dump
        application.jar > /dev/null 2>&1 &

#### 实时监控工具 jvisualvm

  * Windows 系统直接启动 JDK 目录下的可执行文件 bin/jvisualvm.exe

  * Linux 系统无法通过图形化界面查看，可开启 JMX 后远程连接查看，加入启动参数：

        -Dcom.sun.management.jmxremote=true
        -Dcom.sun.management.jmxremote.authenticate=false
        -Dcom.sun.management.jmxremote.ssl=false
        -Djava.rmi.server.hostname=192.168.140.200
        -Dcom.sun.management.jmxremote.port=8060

  * 然后本地打开 jvisualvm 客户端，添加远程 JMX 连接：

        192.168.140.200:8060

#### GC 日志分析工具

  * 可以使用以下两种类型的工具：

        gceasy，web在线分析工具，访问地址：https://gceasy.io/

        gcplot，离线分析工具，GitHub地址：https://github.com/GCPlot/gcplot
