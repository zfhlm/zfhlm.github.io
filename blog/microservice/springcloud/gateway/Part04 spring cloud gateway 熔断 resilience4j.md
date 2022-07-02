
# spring cloud gateway 熔断 resilience4j

### 项目源码地址

    https://github.com/zfhlm/mrh-example/tree/main/mrh-spring-cloud

### 官方文档地址

    https://docs.spring.io/spring-cloud-gateway/docs/current/reference/html/#spring-cloud-circuitbreaker-filter-factory

    https://resilience4j.readme.io/docs/timeout

    https://resilience4j.readme.io/docs/circuitbreaker

    https://resilience4j.readme.io/docs/getting-started-3

### spring cloud gateway resilience4j 过滤器

    查看官方抽象实现和具体实现：

        org.springframework.cloud.gateway.filter.factory.SpringCloudCircuitBreakerFilterFactory

        org.springframework.cloud.gateway.filter.factory.SpringCloudCircuitBreakerResilience4JFilterFactory

        org.springframework.cloud.client.circuitbreaker.ReactiveCircuitBreakerFactory

        org.springframework.cloud.circuitbreaker.resilience4j.ReactiveResilience4JCircuitBreakerFactory

    实现基于 resilience4j 的 circuitbreaker 和 timelimiter，源码可见 ReactiveResilience4JCircuitBreakerFactory：

        CircuitBreakerRegistry                  # 断路器注册中心，使用 resilience4j 的 circuitbreaker

        TimeLimiterRegistry                     # 限时器注册中心，使用 resilience4j 的 timelimiter

    引入 maven 依赖：

        <dependency>
            <groupId>org.springframework.cloud</groupId>
            <artifactId>spring-cloud-starter-circuitbreaker-reactor-resilience4j</artifactId>
        </dependency>

### resilience4j 限时器 timelimiter 配置

    查看 resilience4j-spring-boot2-1.7.0.jar 中的配置类可以看到各配置项：

        io.github.resilience4j.timelimiter.autoconfigure.TimeLimiterAutoConfiguration

        io.github.resilience4j.timelimiter.autoconfigure.TimeLimiterProperties

    假设我们使用以下两个路由：

        spring:
          cloud:
            gateway:
              routes:
              - id: baidu
                predicates:
                  - Path=/baidu/**
                filters:
                  - name: CircuitBreaker
                    args:
                      name: circuit-baidu
                      fallbackUri: forward:/baidu/fallback
                  - StripPrefix=1
                uri: https://www.baidu.com
              - id: jianshu
                predicates:
                  - Path=/baidu/**
                filters:
                  - name: CircuitBreaker
                    args:
                      name: circuit-jianshu
                      fallbackUri: forward:/jianshu/fallback
                  - StripPrefix=1
                uri: https://www.jianshu.com

    限时器如下示例配置：

        resilience4j:
          timelimiter:
            instances:
              # 注意，这里的名称要和 CircuitBreaker 过滤器的 args.name 对应
              circuit-baidu:
                # 超时时间 30s
                timeoutDuration: 30s
                # 超时允许中断执行
                cancelRunningFuture: true
              circuit-jianshu:
                timeoutDuration: 30s
                cancelRunningFuture: true

    另一种继承配置的写法示例：

        resilience4j:
          timelimiter:
            # 定义可用于继承的配置，示例定义了 default 名称的配置，可以自定义其他名称的多项配置
            configs:
              default:
                timeoutDuration: 30s
                cancelRunningFuture: true
            instances:
              # 这里使用 baseConfig 继承上面定义的配置
              circuit-baidu:
                baseConfig: default
              circuit-jianshu:
                baseConfig: default

### resilience4j 断路器 circuitbreaker 配置

    查看 resilience4j-spring-boot2-1.7.0.jar 中的配置类可以看到各配置项：

        io.github.resilience4j.circuitbreaker.autoconfigure.CircuitBreakerAutoConfiguration

        io.github.resilience4j.circuitbreaker.autoconfigure.CircuitBreakerProperties

    断路器主要配置项：

        failureRateThreshold                    # 故障率百分比阈值，open 状态 [n, 100]，close 状态 [0, n)，默认 50

        slowCallRateThreshold                   # 慢调用百分比阈值，open 状态 [n, 100]，close 状态 [0, n)，默认 100

        slowCallDurationThreshold               # 慢调用被标记时长阈值，默认 60s

        waitDurationInOpenState                 # open 状态进入到 half open 状态应等待时长，默认 60s

        permittedNumberOfCallsInHalfOpenState   # half open 状态允许进入多少请求并计算失败率，默认 10

        slidingWindowType                       # 状态收集器类型，基于时间 TIME_BASED 或计数 COUNT_BASED，默认为 COUNT_BASED

        slidingWindowSize                       # 状态收集器大小，收集多少请求用于计算失败率，默认 100

        minimumNumberOfCalls                    # 状态收集器计算失败率最少达到数量，默认 100

        ignoreExceptions                        # 状态收集器不计入计算的异常

        baseConfig                              # 用于继承指定名称的配置

    沿用两个路由，断路器如下示例配置：

        resilience4j:
          circuitbreaker:
            configs:
              default:
                failureRateThreshold: 50
                slowCallRateThreshold: 100
                slowCallDurationThreshold: 60s
                waitDurationInOpenState: 30s
                permittedNumberOfCallsInHalfOpenState: 10
                slidingWindowType: COUNT_BASED
                slidingWindowSize: 100
                minimumNumberOfCalls: 10
                ignoreExceptions:
                  - org.lushen.mrh.cloud.reference.supports.StatusCodeException
            instances:
              baidu:
                baseConfig: default
              jianshu:
                baseConfig: default
