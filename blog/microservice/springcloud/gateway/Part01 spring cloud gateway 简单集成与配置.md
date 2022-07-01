
# spring cloud gateway 简单集成与配置

### 项目源码地址

    https://github.com/zfhlm/mrh-example/tree/main/mrh-spring-cloud

### 路由配置

    网关 routes 路由配置，主要包含以下四个部分：

        id                              # 路由唯一ID

        predicates                      # 路由转发匹配规则，可指定多个

        filters                         # 路由转发过滤器，可指定多个

        uri                             # 路由转发目标地址

    网关 routes predicates 官方提供了以下几种规则：

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

    网关 routes filters 官方提供的常用过滤器(查看官方文档)：

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

    网关 routes uri 可以指定以下路由转发规则：

        ws://<websocket-service>        # 转发到指定 websocket 地址服务

        http://host:port                # 转发到指定 http/https 地址服务

        lb://<service-name>             # 转发到指定服务(从注册中心获取)

### 创建网关 mrh-spring-cloud-gateway

    maven 配置：

        <dependency>
            <groupId>org.springframework.cloud</groupId>
            <artifactId>spring-cloud-starter-gateway</artifactId>
        </dependency>

    application.yml 配置：

        # server 配置
        server:
          port: 8081
          servlet:
            context-path: /

        # spring 配置
        spring:
          application:
            name: mrh-spring-cloud-gateway

    启动类：

        @SpringBootApplication
        @ComponentScan(basePackageClasses=GatewayStarter.class)
        public class GatewayStarter {
            public static void main(String[] args) {
                SpringApplication.run(GatewayStarter.class, args);
            }
        }

### 静态路由配置示例

    mrh-spring-cloud-gateway 配置文件 application.yml 添加以下配置项：

        # /baidu/** 路由到 https://www.baidu.com/**
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

    mrh-spring-cloud-gateway 启动，浏览器访问如下地址：

        http://localhost:8081/baidu/s

        -> (显示百度首页)

### 创建服务 mrh-spring-cloud-api-admin

    maven 配置：

        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-web</artifactId>
        </dependency>
        <dependency>
            <groupId>org.springframework.cloud</groupId>
            <artifactId>spring-cloud-starter-zookeeper-discovery</artifactId>
        </dependency>

    application.yml 配置：

        server:
          port: 8888
        spring:
          application:
            name: mrh-spring-cloud-api-admin
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

    测试 controller 示例：

        @RestController
        @RequestMapping("api/welcome")
        public class WelcomeController {

            @RequestMapping(path="")
            public ViewResult index(HttpServletResponse response) {
                return ViewResult.create(0, "success");
            }

        }

    创建启动类，并启动服务：

        @SpringBootApplication
        @ComponentScan(basePackageClasses=ApplicationStarter.class)
        public class ApplicationStarter {
            public static void main(String[] args) {
                SpringApplication.run(ApplicationStarter.class, args);
            }
        }

### 动态路由配置示例

    配置网关 mrh-spring-cloud-gateway 路由到服务 mrh-spring-cloud-api-admin

    mrh-spring-cloud-gateway 添加 maven 配置：

        <dependency>
            <groupId>org.springframework.cloud</groupId>
            <artifactId>spring-cloud-starter-zookeeper-discovery</artifactId>
        </dependency>

    mrh-spring-cloud-gateway 添加 application.yml 配置：

        # /admin/** 路由到 mrh-spring-cloud-api-admin 服务的 http://ip:port/**
        spring:
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
            # 网关配置
            gateway:
              # 禁用默认服务发现路由配置
              discovery:
                locator:
                  enabled: false
              routes:
              - id: api-admin
                predicates:
                  - Path=/admin/**
                filters:
                  - StripPrefix=1
                uri: lb://mrh-spring-cloud-api-admin

    mrh-spring-cloud-gateway 启动，使用浏览器访问地址：

        http://localhost:8081/admin/api/welcome

        -> {"errcode":0, "errmsg": "success"}
