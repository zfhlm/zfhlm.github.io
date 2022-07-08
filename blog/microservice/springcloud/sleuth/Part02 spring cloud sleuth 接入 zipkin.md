
# spring cloud sleuth 接入 zipkin

### 相关文档

  * 官方文档地址：

        https://docs.spring.io/spring-cloud/docs/current/reference/html/

        https://docs.spring.io/spring-cloud-sleuth/docs/current/reference/htmlsingle/spring-cloud-sleuth.html

        https://docs.spring.io/spring-cloud-sleuth/docs/current/reference/htmlsingle/spring-cloud-sleuth.html#common-application-properties

        https://zipkin.io/

        https://github.com/openzipkin/zipkin

  * 示例源码地址：

        https://github.com/zfhlm/mrh-example/tree/main/mrh-spring-cloud

### 关于文档

  * 官方文档上面没发现比较详细的描述，例如配置 zipkin 启动参数

  * 可以解压 zipkin-server.jar 包查看具体提供了哪些配置，或者直接更改 jar 包进行配置，省略了命令行传参：

        zipkin-server.jar!/BOOT-INF/classes/zipkin-server-shared.yml

### 运行 zipkin 服务

  * 下载最新版本源码，使用 maven 编译打包：

        https://codeload.github.com/openzipkin/zipkin/zip/refs/tags/zipkin-0.3.0

        mvn clean package -DskipTests

        zipkin-server-2.23.17-SNAPSHOT-exec.jar

  * 运行 zipkin server：

        java -jar zipkin-server-2.23.17-SNAPSHOT-exec.jar

        curl -x GET http://localhost:9411

### 接入 zipkin 服务

  * 添加 maven 依赖：

        <dependency>
            <groupId>org.springframework.cloud</groupId>
            <artifactId>spring-cloud-sleuth-zipkin</artifactId>
        </dependency>

  * 更改 application.yml 配置：

        spring
          sleuth:
            enabled: true
            trace-id128: false
            sampler:
              # 采样率 0-1 当前 0.1 为采样 10%
              probability: 0.1
              # 每秒最大采样数
              rate: 10
              refresh.enabled: false
          zipkin:
            enabled: true
            sender.type: WEB
            base-url: http://localhost:9411

  * 启动应用并发起请求，即可在 zipkin 后台查看调用链信息

### zipkin 采样发送类型

  * 默认提供了四种类型：

        ACTIVEMQ            # 发送到 activemq

        RABBIT              # 发送到 rabbitmq

        KAFKA               # 发送到 kafka

        WEB                 # 发送到 zipkin 服务

  * 配置发送到 rabbitmq：

        <dependency>
            <groupId>org.springframework.cloud</groupId>
            <artifactId>spring-cloud-starter-stream-rabbit</artifactId>
        </dependency>

        spring:
          sleuth:
            enabled: true
            trace-id128: false
            sampler:
              # 采样率 0-1 当前 0.1 为采样 10%
              probability: 0.1
              # 每秒最大采样数
              rate: 10
              refresh.enabled: false
          zipkin:
            enabled: true
            sender.type: RABBIT
          rabbitmq:
            host: 127.0.0.1
            port: 5672
            username: MjphbXFwLWNuLXRsMzJycmEydzAwMTpMVEFJNXROTWZBZERkNGhvTmQ1MnJ3YkY=
            password: MUY5OTdGOUI2RTNCNkRCMDBEMUY5NkM1RDdGODRBRjM4QTk4MDU4ODoxNjU3MDYyNjkyODU1
            connection-timeout: 0
            publisher-confirms: true
            publisher-returns: true

  * 启动 zipkin 服务时加入启动参数：

        java -jar zipkin-server.jar --zipkin.collector.rabbitmq.addresses=127.0.0.1:5672 \
            --zipkin.collector.rabbitmq.username=MjphbXFwLWNuLXRsMzJycmEydzAwMTpMVEFJNXROTWZBZERkNGhvTmQ1MnJ3YkY= \
            --zipkin.collector.rabbitmq.password=MUY5OTdGOUI2RTNCNkRCMDBEMUY5NkM1RDdGODRBRjM4QTk4MDU4ODoxNjU3MDYyNjkyODU1

### zipkin 采样存储类型

  * 主要支持以下存储中间件：

        In-Memory               # 内存存储，默认的存储方式，重启数据丢失

        Cassandra               # 持久化存储

        Elasticsearch           # 持久化存储

        MySQL                   # 持久化存储

  * 使用 mysql 存储，需要使用建表脚本：

        https://github.com/openzipkin/zipkin/blob/master/zipkin-storage/mysql-v1/src/main/resources/mysql.sql

  * 启动 zipkin 服务时加入启动参数：

        STORAGE_TYPE=mysql \
        MYSQL_USER=root \
        MYSQL_PASS=123456 \
        MYSQL_HOST=127.0.0.1 \
        MYSQL_TCP_PORT=3306 \
        java -jar zipkin-server.jar
