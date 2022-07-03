
# spring cloud gateway 集成与配置

### 相关文档

* 官方文档地址：

        https://docs.spring.io/spring-cloud/docs/current/reference/html/

        https://docs.spring.io/spring-cloud-gateway/docs/current/reference/html/

* 示例源码地址：

        https://github.com/zfhlm/mrh-example/tree/main/mrh-spring-cloud

### 网关配置项

* 网关 routes 路由配置，主要包含以下四个部分：

        id                              # 路由唯一ID

        predicates                      # 路由转发匹配规则，可指定多个

        filters                         # 路由转发过滤器，可指定多个

        uri                             # 路由转发目标地址

* 网关 routes predicates 官方提供了以下几种规则：

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

* 网关 routes filters 官方提供的常用过滤器(查看官方文档)：

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

* 网关 routes uri 可以指定以下路由转发规则：

        ws://<websocket-service>        # 转发到指定 websocket 地址服务

        http://host:port                # 转发到指定 http/https 地址服务

        lb://<service-name>             # 转发到指定服务(从注册中心获取)

### 创建网关 mrh-spring-cloud-gateway 项目

* 引入 maven 依赖：

        <dependency>
            <groupId>org.springframework.cloud</groupId>
            <artifactId>spring-cloud-starter-gateway</artifactId>
        </dependency>

* 添加 application.yml 配置：

        server:
          port: 8081
          servlet:
            context-path: /
        spring:
          application:
            name: mrh-spring-cloud-gateway

* 创建启动类：

        @SpringBootApplication
        @ComponentScan(basePackageClasses=GatewayStarter.class)
        public class GatewayStarter {
            public static void main(String[] args) {
                SpringApplication.run(GatewayStarter.class, args);
            }
        }

### 配置网关静态路由

* 添加 application.yml 配置：

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

* 启动网关，使用浏览器发起请求：

        http://localhost:8081/baidu/s

        -> (显示百度首页)

### 配置网关动态路由

* 创建路由目标服务：

        引入 maven 依赖：

            <dependency>
                <groupId>org.springframework.boot</groupId>
                <artifactId>spring-boot-starter-web</artifactId>
            </dependency>
            <dependency>
                <groupId>org.springframework.cloud</groupId>
                <artifactId>spring-cloud-starter-zookeeper-discovery</artifactId>
            </dependency>

        添加 application.yml 配置：

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

        创建测试使用 controller 接口：

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

* 配置网关动态路由

        添加 maven 配置：

            <dependency>
                <groupId>org.springframework.cloud</groupId>
                <artifactId>spring-cloud-starter-zookeeper-discovery</artifactId>
            </dependency>

        添加 application.yml 配置：

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
                  # 自定义路由配置
                  routes:
                  - id: api-admin
                    predicates:
                      - Path=/admin/**
                    filters:
                      - StripPrefix=1
                    uri: lb://mrh-spring-cloud-api-admin

* 启动测试

        启动网关和路由目标服务，使用浏览器发起请求：

            http://localhost:8081/admin/api/welcome

            -> {"errcode":0, "errmsg": "success"}
