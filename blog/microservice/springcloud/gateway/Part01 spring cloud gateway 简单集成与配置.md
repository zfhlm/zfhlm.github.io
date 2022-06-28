
# spring cloud gateway 简单集成与配置

### 相关依赖

    spring cloud 版本号：2021.0.3

    spring boot 版本号：2.6.9

    spring cloud 注册中心：zookeeper

    官方文档地址：https://docs.spring.io/spring-cloud-gateway/docs/current/reference/html/

    spring cloud 与 spring boot 适配版本，查看文档首页 https://spring.io/projects/spring-cloud

### 创建项目

    相关 maven 依赖配置：

        <dependency>
            <groupId>org.springframework.cloud</groupId>
            <artifactId>spring-cloud-starter-gateway</artifactId>
        </dependency>
        <dependency>
            <groupId>org.springframework.cloud</groupId>
            <artifactId>spring-cloud-starter-zookeeper-discovery</artifactId>
        </dependency>

    相关 application.yml 配置：

        # server 配置
        server:
          port: 8081
          servlet:
            context-path: /

        # spring 配置
        spring:
          application:
            name: mrh-spring-cloud-gateway
          cloud:
            # 注册中心配置
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
            # 网关配置，禁用默认路由
            gateway:
              discovery:
                locator:
                  enabled: false

### 路由配置

    gateway 路由配置示例：

        # 静态地址路由，不依赖注册中心，接收到请求先截取 /baidu 路径前缀，再转发到 https://www.baidu.com/**
        # 例如 http://localhost:8081/baidu/s -> https://www.baidu.com/s
        spring:
          cloud:
            gateway:
              routes:
              - id: baidu
                predicates:
                  - Path=/baidu/**
                filters:
                  - StripPrefix=1
                uri: https://www.baidu.com

        # 从注册中心订阅服务，接收到请求先截取 /admin 路径前缀，再转发到某个 mrh-spring-cloud-api-admin 服务
        # 例如 http://localhost:8081/admin/api/welcome -> http://<service-ip>:<service-port>/api/welcome
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
                register: true
                root: /cloud
            gateway:
              routes:
              - id: api-admin
                predicates:
                  - Path=/admin/**
                filters:
                  - StripPrefix=1
                uri: lb://mrh-spring-cloud-api-admin

    gateway routes 路由配置，主要包含以下四个部分：

        id                              # 路由唯一ID

        predicates                      # 路由转发匹配规则，可指定多个

        filters                         # 路由转发过滤器，可指定多个

        uri                             # 路由转发目标地址

    routes predicates 官方提供了以下几种规则：

        After                           # 匹配时间之后

        Before                          # 匹配时间之前

        Between                         # 匹配时间范围

        Cookie                          # 匹配 cookie 请求头

        Header                          # 匹配请求头

        Host                            # 匹配请求host

        Method                          # 匹配请求方法

        Path                            # 匹配请求路径

        Query                           # 匹配请求路径参数

        RemoteAddr                      # 匹配请求客户端地址

        (注意，可以配合使用一个到多个，多个匹配条件为 and 逻辑，必须满足这些条件才使用此路由)

    routes filters 官方提供的常用过滤器(查看官方文档)：

        AddRequestHeader                # 添加请求头

        AddRequestParameter             # 添加请求路径参数

        AddResponseHeader               # 添加响应头

        DedupeResponseHeader            # 去除重复响应头

        CircuitBreaker                  # 熔断限流

        PrefixPath                      # 添加请求路径

        RedirectTo                      # 重定向

        RemoveRequestHeader             # 移除请求头

        RemoveRequestParameter          # 移除请求路径参数

        RequestHeaderSize               # 请求头报文大小限制

        RewritePath                     # 重写请求路径

        RequestSize                     # 请求报文大小限制

        StripPrefix                     # 移除请求路径

    routes uri 可以指定以下路由转发规则：

        ws://<ws-service>               # 转发到指定 websocket 地址服务

        http://host:port                # 转发到指定 http/https 地址服务

        lb://<service-name>             # 转发到指定服务(从注册中心获取)
