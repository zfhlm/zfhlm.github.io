
# spring cloud alibaba nacos 配置中心

### 相关文档

  * 官方文档地址：

        https://docs.spring.io/spring-cloud/docs/current/reference/html/

        https://spring-cloud-alibaba-group.github.io/github-pages/2021/en-us/index.html

  * 示例源码地址：

        https://github.com/zfhlm/mrh-example/tree/main/mrh-spring-cloud

### nacos 服务端

  * 创建配置文件：

        Data ID: mrh-spring-cloud-service-nacos-dev.yml

        Group: DEFAULT_GROUP

        配置格式: YAML

        配置内容:

            logging:
              config: classpath:log4j2-spring.xml

            server:
              port: 8899
              servlet:
                context-path: /

            spring:
              application:
                name: mrh-spring-cloud-service-nacos
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

### nacos 客户端

  * 引入 maven 依赖：

        <dependency>
            <groupId>com.alibaba.cloud</groupId>
            <artifactId>spring-cloud-starter-alibaba-nacos-config</artifactId>
        </dependency>

  * 创建 bootstrap.yml 引导配置：

        spring:
          application:
            name: mrh-spring-cloud-service-nacos
          profiles:
            active: dev
          cloud:
            nacos:
              config:
                server-addr: 192.168.140.210:8848
                file-extension: yml
                username: nacos
                password: nacos
