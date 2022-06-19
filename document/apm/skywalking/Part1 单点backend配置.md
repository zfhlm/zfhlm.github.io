
# skywalking 单点backend配置

### 服务器

    APM 服务器：

        129.168.140.129

    Elasticsearch 服务器：

        192.168.140.193:9200

        192.168.140.194:9200

        192.168.140.195:9200

### APM 安装包下载

    下载安装包：

        官方文档：https://skywalking.apache.org/docs/main/latest/en/setup/backend/backend-setup/

        下载地址：https://skywalking.apache.org/downloads/

        下载包：apache-skywalking-apm-9.1.0.tar.gz

        上传到服务器目录：/usr/local/software

    解压安装包，输入命令：

        cd /usr/local/software

        tar -zxvf ./apache-skywalking-apm-9.1.0.tar.gz

        mv ./apache-skywalking-apm-bin ../

        cd ..

        ln -s apache-skywalking-apm-bin skywalking

### APM 依赖安装

    安装 JDK：

        (版本 1.8+)

    安装 elasticsearch 集群：

        (版本 6.X、7.X、8.X)

### APM 配置更改

    更改日志配置，输入命令：

        cd /usr/local/skywalking/config

        vi log4j2.xml

        =>

          <Property name="log-path">/usr/local/skywalking/logs</Property>

    更改backend配置，输入命令：

        cd /usr/local/skywalking/config

        vi application.yml

        =>

            storage:
              selector: ${SW_STORAGE:elasticsearch}
              elasticsearch:
                clusterNodes: ${SW_STORAGE_ES_CLUSTER_NODES:192.168.140.193:9200,192.168.140.194:9200,192.168.140.195:9200}
                indexShardsNumber: ${SW_STORAGE_ES_INDEX_SHARDS_NUMBER:1}
                indexReplicasNumber: ${SW_STORAGE_ES_INDEX_REPLICAS_NUMBER:1}

    更改 UI 配置，输入命令：

        cd /usr/local/skywalking/webapp

        vi webapp.yml

        =>

            (按需修改UI后台相关配置，例如端口号)

### APM 启动运行

    启动backend，输入命令：

        cd /usr/local/skywalking/bin

        ./startup.sh

    访问UI页面：

        http://192.168.140.129:8080
