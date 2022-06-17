
# skywalking 集群backend配置

    注意，集群的注册中心只是作为集群状态记录，集群无法对外提供服务自动发现功能

    集群负载均衡可以使用两种方式实现：

        1，客户端多个APM地址会自动进行负载均衡(资源占用少/性能高)

        2，APM使用keepalived、haproxy、lvs等进行负载均衡(额外中间件/有性能损耗)

### 依赖安装

    服务器信息：

        129.168.140.129

        129.168.140.130

        129.168.140.131

    三节点安装好单点backend：

        (略)

    三节点安装好zookeeper(或者其他可选注册中心)：

        (略)

### 集群配置

    修改backend配置，输入命令：

        cd /usr/local/skywalking

        vi ./config/application.yml

        =>

            # 集群注册中心，使用zookeeper
            cluster:
            #   standalone
              selector: ${SW_CLUSTER:zookeeper}
              zookeeper:
                namespace: ${SW_NAMESPACE:""}
                hostPort: ${SW_CLUSTER_ZK_HOST_PORT:129.168.140.129:2181,129.168.140.130:2181,129.168.140.131:2181}

    启动其中一个backend，输入命令：

        cd /usr/local/skywalking

        ./bin/startup.sh

    启动另外两个backend，输入命令：

        cd /usr/local/skywalking

        ./bin/oapServiceNoInit.sh

        ./bin/webappService.sh
