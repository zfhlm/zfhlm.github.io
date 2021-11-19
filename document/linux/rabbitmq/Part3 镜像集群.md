
#### 镜像集群(搭建)

    1，环境准备

        镜像集群基于普通集群进行配置

    2，配置镜像集群

        输入命令：

            cd /usr/local/rabbitmq

            ./sbin/rabbitmqctl set_policy ha-all "^" '{"ha-mode":"all"}'

        参数含义：

            ha-all                 #自定义策略名称

            ^                      #匹配符，^代表匹配所有

            ha-mode                #匹配类型，共3种模式：all-所有，exctly-部分，nodes-指定

    3，登录管理后台查看，各个节点都有了如下信息：

        Name                 Node                     Type      Features    
        test.assign.queue    rabbit@rabbit_node1 +2   classic   D DLX DLK ha-all
        test.fallback.queue  rabbit@rabbit_node1 +2   classic   D ha-all idle    

        数据进入节点一，同时被异步复制到其他节点

#### 高可用集群(haproxy+keepalived)

    1，环境准备

        提前配置好 rabbitmq 镜像集群和 haproxy+keepalived 双主模式

        rabbitmq 镜像集群服务器：

            192.168.140.144        #rabbitmq集群节点一

            192.168.140.145        #rabbitmq集群节点二

            192.168.140.146        #rabbitmq集群节点三

        haproxy+keepalived 双主模式服务器：

            192.168.140.149        #haproxy节点一，代理端口5672

            192.168.140.150        #haproxy节点二，代理端口5672

            192.168.140.202        #keepalived VIP 一

            192.168.140.203        #keepalived VIP 二

    2，配置haproxy负载均衡，修改haproxy配置，输入命令：

        cd /usr/local/haproxy

        vi conf/haproxy.cfg

        =>

            listen stats
            bind *:8888
            mode http
            log 127.0.0.1 local3 err
            stats refresh 60s
            stats uri /stats
            stats realm Haproxy
            stats auth admin:123456
            stats hide-version
            stats admin if TRUE

            listen rabbitmq_cluster
            bind *:5672
            mode tcp
            balance roundrobin
            server rabbitnode1 192.168.140.144:5672 check inter 2000 rise 2 fall 3 weight 1
            server rabbitnode2 192.168.140.145:5672 check inter 2000 rise 2 fall 3 weight 1
            server rabbitnode3 192.168.140.146:5672 check inter 2000 rise 2 fall 3 weight 1

    3，springboot客户端连接，修改连接IP地址为两个VIP地址即可：

        spring.rabbitmq.addresses=192.168.140.202:5672,192.168.140.203:5672
        spring.rabbitmq.username=rabbitmq
        spring.rabbitmq.password=123456
        spring.rabbitmq.connection-timeout=0
        spring.rabbitmq.publisher-confirms=true
        spring.rabbitmq.publisher-returns=true

    4，测试

        使用普通集群的客户端进行测试即可
