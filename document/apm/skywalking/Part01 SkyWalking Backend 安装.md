
# SkyWalking Backend 安装

  * 官方文档地址：

        https://skywalking.apache.org/docs/main/latest/en/setup/backend/backend-setup/

        https://skywalking.apache.org/downloads/

        https://skywalking.apache.org/docs/main/latest/en/setup/backend/backend-alarm/

  * 服务器准备：

        129.168.140.129         # backend 节点一

        129.168.140.130         # backend 节点二

        129.168.140.131         # backend 节点三

        192.168.140.193         # elasticsearch 节点一

        192.168.140.194         # elasticsearch 节点二

        192.168.140.195         # elasticsearch 节点三

### 单点配置

  * 解压安装包，输入命令：

        cd /usr/local/software

        tar -zxvf ./apache-skywalking-apm-9.1.0.tar.gz

        mv ./apache-skywalking-apm-bin ../

        cd ..

        ln -s apache-skywalking-apm-bin skywalking

  * 更改日志配置，输入命令：

        cd /usr/local/skywalking/config

        vi log4j2.xml

        =>

          <Property name="log-path">/usr/local/skywalking/logs</Property>

  * 更改backend配置，输入命令：

        cd /usr/local/skywalking/config

        vi application.yml

        =>

            storage:
              selector: ${SW_STORAGE:elasticsearch}
              elasticsearch:
                clusterNodes: ${SW_STORAGE_ES_CLUSTER_NODES:192.168.140.193:9200,192.168.140.194:9200,192.168.140.195:9200}
                indexShardsNumber: ${SW_STORAGE_ES_INDEX_SHARDS_NUMBER:1}
                indexReplicasNumber: ${SW_STORAGE_ES_INDEX_REPLICAS_NUMBER:1}

  * 更改 UI 配置，输入命令：

        cd /usr/local/skywalking/webapp

        vi webapp.yml

        =>

            (按需修改UI后台相关配置，例如端口号)

  * 启动backend，输入命令：

        cd /usr/local/skywalking/bin

        ./startup.sh

  * 访问UI页面：

        http://192.168.140.129:8080

### 集群配置

  * 集群说明：

        注意，集群的注册中心只是作为集群状态记录，集群无法对外提供服务自动发现功能

        集群负载均衡可以使用两种方式实现：

            1，客户端多个APM地址会自动进行负载均衡(资源占用少/性能高)

            2，APM使用keepalived、haproxy、lvs等进行负载均衡(额外中间件/有性能损耗)

  * 三节点安装好单点backend：

        (略)

  * 三节点安装好zookeeper(或者其他可选注册中心)：

        (略)

  * 修改backend配置，输入命令：

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

  * 启动其中一个backend，输入命令：

        cd /usr/local/skywalking

        ./bin/startup.sh

  * 启动另外两个backend，输入命令：

        cd /usr/local/skywalking

        ./bin/oapServiceNoInit.sh

        ./bin/webappService.sh

### 告警配置

  * 更改配置，输入命令：

        cd /usr/local/skywalking

        vi config/alarm-settings.yml

        =>

            rules:

              # 响应时间告警配置
              service_resp_time_rule:
                metrics-name: service_resp_time
                op: ">"
                threshold: 1000
                period: 10
                count: 3
                silence-period: 5
                message: Response time of service {name} is more than 1000ms in 3 minutes of last 10 minutes.

              # 服务调用超时告警配置
              service_instance_resp_time_rule:
                metrics-name: service_instance_resp_time
                op: ">"
                threshold: 1000
                period: 10
                count: 2
                silence-period: 5
                message: Response time of service instance {name} is more than 1000ms in 2 minutes of last 10 minutes

              # 数据库告警配置
              database_access_resp_time_rule:
                metrics-name: database_access_resp_time
                threshold: 1000
                op: ">"
                period: 10
                count: 2
                message: Response time of database access {name} is more than 1000ms in 2 minutes of last 10 minutes

            # 告警回调接口，接口实现通知逻辑
            webhooks:
              - http://127.0.0.1/notify/
