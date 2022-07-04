
# spring cloud consul 配置中心

### 相关文档

  * 官方文档地址：

        https://docs.spring.io/spring-cloud/docs/current/reference/html/

        https://docs.spring.io/spring-cloud-consul/docs/current/reference/html/#spring-cloud-consul-config

  * 示例源码地址：

        https://github.com/zfhlm/mrh-example/tree/main/mrh-spring-cloud

### consul 服务端

  * consul 三节点集群，使用 nginx 对外发布为一个地址：

        192.168.140.130:8500        consul agent 节点一

        192.168.140.131:8500        consul agent 节点二

        192.168.140.132:8500        consul agent 节点三

        192.168.140.130:18500       nginx 负载均衡 consul 三节点集群

  * 控制台添加配置文件到 consul key/value，key 值：

        config/mrh-spring-cloud-service-consul:dev/data

  * 控制台添加配置文件到 consul key/value，value 值，选择 yaml 格式：

        logging:
          config: classpath:log4j2-spring.xml

        server:
          port: 8899
          servlet:
            context-path: /

        spring:
          application:
            name: mrh-spring-cloud-service-consul
          jackson:
            date-format: 'yyyy-MM-dd HH:mm:ss'
            joda-date-time-format: 'yyyy-MM-dd HH:mm:ss'
            time-zone: 'GMT+8'
            default-property-inclusion: NON_NULL
            serialization:
              WRITE_DATES_AS_TIMESTAMPS: false
            deserialization:
              FAIL_ON_UNKNOWN_PROPERTIES: false
              READ_DATE_TIMESTAMPS_AS_NANOSECONDS: false
            visibility:
              GETTER: NONE
              SETTER: NONE
              FIELD: ANY

### consul 客户端

  * 添加服务 maven 依赖：

        <dependency>
            <groupId>org.springframework.cloud</groupId>
            <artifactId>spring-cloud-starter-consul-config</artifactId>
        </dependency>
        <dependency>
            <groupId>org.springframework.cloud</groupId>
            <artifactId>spring-cloud-starter-bootstrap</artifactId>
        </dependency>

  * 创建服务 bootstrap.yml 引导配置文件：

        spring:
          application:
            name: mrh-spring-cloud-service-consul
          profiles:
            active: dev
          cloud:
            consul:
              enabled: true
              host: 192.168.140.130
              port: 18500
              config:
                enabled: true
                format: yaml
                prefixes: config
                default-context: ${spring.application.name}
                profile-separator: ':'
                data-key: data
                acl-token: d5ab2ee4-ace6-f70f-fd34-2e25e009dfc4
                watch.enabled: false

  * 配置中心 consul key 与 服务配置 对应关系：

        spring cloud consul config key 命名规则：

            <prefixes>/<default-context><profile-separator><spring.profiles.active>/<data-key>

        例如当前服务的 key 值：

            config/mrh-spring-cloud-service-consul:dev/data
