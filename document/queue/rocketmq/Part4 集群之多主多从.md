
#### 集群-多主多从模式

    异步复制：主备有短暂消息延迟，出现磁盘故障消息丢失的非常少，且消息实时性不会受影响

    同步双写：只有主备都写成功，才向应用返回成功，消息与服务都无单点故障，性能略低

    1，服务器准备

        Broker Master1    192.168.140.156

        Broker Slave1     192.168.140.157

        Broker Master2    192.168.140.158

        Broker Slave2     192.168.140.159

        Name Server1      192.168.140.157

        Name Server2      192.168.140.159

    2，分别修改 Broker Master 配置

        brokerClusterName=rocketmq-cluster
        brokerName=broker-node1
        brokerId=0
        namesrvAddr=192.168.140.157:9876;192.168.140.159:9876
        brokerRole=ASYNC_MASTER

        brokerClusterName=rocketmq-cluster
        brokerName=broker-node2
        brokerId=0
        namesrvAddr=192.168.140.157:9876;192.168.140.159:9876
        brokerRole=ASYNC_MASTER

    3，分别修改 Broker Slave 配置

        brokerClusterName=rocketmq-cluster
        brokerName=broker-node1
        brokerId=1
        namesrvAddr=192.168.140.157:9876;192.168.140.159:9876
        brokerRole=SLAVE

        brokerClusterName=rocketmq-cluster
        brokerName=broker-node2
        brokerId=1
        namesrvAddr=192.168.140.157:9876;192.168.140.159:9876
        brokerRole=SLAVE

    3，启动 Broker 和 Name Server

        nohup sh bin/mqnamesrv &

        nohup sh bin/mqbroker &

    4，同步双写和异步复制

        两者配置的区别在于 Broker Master 节点 brokerRole 配置不同：

        brokerRole=SYNC_MASTER         #同步双写

        brokerRole=ASYNC_MASTER        #异步复制
