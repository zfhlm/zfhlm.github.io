
# spring cloud gateway 限流 ratelimiter

### 相关文档

  * 官方文档地址：

        https://docs.spring.io/spring-cloud/docs/current/reference/html/

        https://docs.spring.io/spring-cloud-gateway/docs/current/reference/html/

  * 示例源码地址：

        https://github.com/zfhlm/mrh-example/tree/main/mrh-spring-cloud

  * 直至当前最新版本(spring cloud 2021.0.3)，存在的问题：

        限流器仅支持 redis 令牌桶实现

        限流成功，只返回状态码，不允许配置化抛出异常

        redis 无法连接的时候，请求创建连接阻塞，限流不生效，也不报错

        redis 版本过低不支持逻辑命令，请求不阻塞，限流不生效，也不报错

  * 多种限流器可以组合使用：

        对单个用户、单个IP地址进行限流，防止恶意请求耗光令牌，使用 redis ratelimiter(集群级别)

        对指定路由进行限流，使用其他类型限流器(应用级别)

### 网关 RequestRateLimiter 限流配置

  * 引入 maven 依赖：

        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-data-redis-reactive</artifactId>
        </dependency>

  * 限流配置参数含义：

        replenishRate                   # 每秒产生的令牌数

        burstCapacity                   # 令牌桶大小

        requestedTokens                 # 每次请求消耗令牌数，一般都是设置为 1 个

  * 自定义 KeyResolver 获取限流标识，这里定义为客户端 IP 地址：

        @Bean("hostKeyResolver")
        public KeyResolver hostKeyResolver() {
            return exchange -> Mono.just(exchange.getRequest().getRemoteAddress().getAddress().getHostAddress());
        }

  * 添加 application.yml 配置：

        spring:
          # redis 配置，默认基于 redis 实现
          redis:
            host: 192.168.140.144
            port: 6379
            timeout: 2s
            client-type: LETTUCE
            pool:
              max-active: 1000
              max-idle: 8
          # 网关配置
          cloud:
            gateway:
              routes:
              - id: baidu
                predicates:
                  - Path=/baidu/**
                filters:
                  # 引入限流过滤器
                  - name: RequestRateLimiter
                    args:
                      key-resolver: "#{@hostKeyResolver}"
                      redis-rate-limiter.replenishRate: 1
                      redis-rate-limiter.burstCapacity: 1
                      redis-rate-limiter.requestedTokens: 1
                  - StripPrefix=1
                uri: https://www.baidu.com
