
# spring boot admin 监控 springcloud 服务

### 配置 spring boot admin server 应用

    注意，基于 Part1 中的 spring boot admin server 进行配置

    引入如下 maven 依赖：

        <!-- spring boot admin -->
        <dependency>
            <groupId>de.codecentric</groupId>
            <artifactId>spring-boot-admin-server-cloud</artifactId>
        </dependency>

        <!-- spring cloud -->
        <dependency>
            <groupId>org.springframework.cloud</groupId>
            <artifactId>spring-cloud-starter-zookeeper-discovery</artifactId>
        </dependency>

    添加如下配置到 application.yml ：

        # 不注册自己，即忽略监控自己
        spring:
          cloud:
            zookeeper:
              enabled: true
              connect-string: localhost:2181
              prefer-ip-address: true
              max-retries: 10
              max-sleep-ms: 500
              discovery:
                enabled: true
                register: false
                root: /cloud

### 创建 spring cloud client 应用

    引入如下 maven 依赖：

        <!-- springboot -->
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-actuator</artifactId>
        </dependency>

        <!-- spring boot admin -->
        <dependency>
            <groupId>de.codecentric</groupId>
            <artifactId>spring-boot-admin-client</artifactId>
        </dependency>

        <!-- spring cloud -->
        <dependency>
            <groupId>org.springframework.cloud</groupId>
            <artifactId>spring-cloud-starter-zookeeper-discovery</artifactId>
        </dependency>

    添加如下配置到 application.yml ：

        server:
          port: 8889

        spring:
          application:
            name: mrh-spring-boot-admin-client-cloud
          cloud:
            zookeeper:
              enabled: true
              connect-string: localhost:2181
              prefer-ip-address: true
              max-retries: 10
              max-sleep-ms: 500
              discovery:
                enabled: true
                register: true
                root: /cloud

        management:
          endpoints:
            jmx:
              exposure:
                include: "*"
            web:
              exposure:
                include: '*'

    启动应用，即可在 spring boot admin server 的后台查看监控信息
