
# Neo4j Community 单点配置

  * 下载安装包

        下载地址：https://neo4j.com/download-center/#community

        下载包：neo4j-community-4.4.8-unix.tar.gz

        上传到服务器目录：/usr/local/software

  * 安装依赖环境：

        (jdk11+)

  * 更改系统限制，输入命令：

        vi /etc/security/limits.conf

        =>

            * soft nofile 65535
            * hard nofile 65535
            * soft nproc 4096
            * hard nproc 4096

        reboot

  * 解压 neo4j 安装包，输入命令：

        cd /usr/local/software

        tar -zxvf neo4j-community-4.4.8-unix.tar.gz

        mv neo4j-community-4.4.8 ..

        cd ..

        ln -s neo4j-community-4.4.8 neo4j

  * 更改 neo4j 配置文件，输入命令：

        cd /usr/local/neo4j

        vi conf/neo4j.conf

        =>

            # JVM 初始堆内存
            dbms.memory.heap.initial_size=512m
            # JVM 最大堆内存
            dbms.memory.heap.max_size=512m
            # JVM 可使用最大页缓存，建议设置为 JVM 的一半
            dbms.memory.pagecache.size=256m

            # 网络监听配置
            dbms.connector.bolt.enabled=true
            dbms.connector.bolt.listen_address=:7687
            dbms.default_listen_address=0.0.0.0
            dbms.connector.http.enabled=true
            dbms.connector.http.listen_address=:7474

  * 启动 neo4j 进程，输入命令：

        cd /usr/local/neo4j

        ./bin/neo4j start

        # ./bin/neo4j stop

  * 访问 neo4j web 控制台：

        http://192.168.140.136:7474

        初次连接账号密码 neo4j/neo4j，连接上去后修改密码
