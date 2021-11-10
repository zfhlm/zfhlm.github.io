
# canal

#### 集群 canal

    服务器地址：

        192.168.140.210

        192.168.140.211

        192.168.140.212

    集群依赖 zookeeper 安装：

        (略)

    修改三个节点 canal 配置：

        cd /usr/local/canal

        vi conf/canal.properties

        =>

          canal.zkServers=192.168.140.210:2181,192.168.140.211:2181,192.168.140.212:2181
          canal.instance.global.spring.xml = classpath:spring/default-instance.xml

    修改三个节点 instance 配置：

        vi canal.properties

        =>

          # 节点一配置
          canal.instance.mysql.slaveId = 210
          canal.instance.master.address = 192.168.140.210:3306

          # 节点二配置
          canal.instance.mysql.slaveId = 211
          canal.instance.master.address = 192.168.140.210:3306

          # 节点三配置
          canal.instance.mysql.slaveId = 212
          canal.instance.master.address = 192.168.140.210:3306

    启动集群各个节点，输入命令：

        cd /usr/local/canal

        ./bin/startup.sh

    客户端连接集群示例：

        String zkServers = "192.168.140.210:2181,192.168.140.211:2181,192.168.140.212:2181";
        CanalConnectors.newClusterConnector(zkServers, destination, username, password);
