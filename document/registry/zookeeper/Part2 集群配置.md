
#### 集群配置

    1，服务器准备

        192.168.0.1        #已配置单点zk

        192.168.0.2        #已配置单点zk

        192.168.0.3        #已配置单点zk

    2，配置节点信息，输入命令：

        cd /usr/local/zookeeper

        mkdir data

        # 192.168.0.1
        echo 1 > ./data/myid

        # 192.168.0.2
        echo 2 > ./data/myid

        # 192.168.0.3
        echo 3 > ./data/myid

    3，配置文件添加集群配置，输入命令：

        vi /usr/local/zookeeper/conf/zoo.cfg

        =>

            server.1=192.168.0.1:2888:3888
            server.2=192.168.0.2:2888:3888
            server.3=192.168.0.3:2888:3888

    4，启动集群，输入命令：

        cd /usr/local/zookeeper/

        ./bin/zkServer.sh start

        ./bin/zkServer.sh status
