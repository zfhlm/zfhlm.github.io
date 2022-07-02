
# spring cloud gateway 熔断限流 resilience4j

### 项目源码地址

    https://github.com/zfhlm/mrh-example/tree/main/mrh-spring-cloud

### resilience4j 官方文档地址

    https://resilience4j.readme.io/docs/timeout

    https://resilience4j.readme.io/docs/circuitbreaker

    https://resilience4j.readme.io/docs/getting-started-3

### spring cloud gateway resilience4j 过滤器

    查看官方抽象实现和具体实现：

        org.springframework.cloud.gateway.filter.factory.SpringCloudCircuitBreakerFilterFactory

        org.springframework.cloud.gateway.filter.factory.SpringCloudCircuitBreakerResilience4JFilterFactory

    查看 SpringCloudCircuitBreakerFilterFactory 的部分源码：

        @Override
        public GatewayFilter apply(Config config) {
            ReactiveCircuitBreaker cb = reactiveCircuitBreakerFactory.create(config.getId());
            ...
        }

        public static class Config implements HasRouteId {

            private String name;

            private URI fallbackUri;

            private String routeId;

            private Set<String> statusCodes = new HashSet<>();

            private boolean resumeWithoutError = false;

            ....

            public String getId() {
                if (StringUtils.isEmpty(name) && !StringUtils.isEmpty(routeId)) {
                    return routeId;
                }
                return name;
            }

            ....

        }

    以上可以得知，ReactiveCircuitBreakerFactory 根据 routeId 或 name 创建 ReactiveCircuitBreaker，抽象类及其实现类：

        org.springframework.cloud.client.circuitbreaker.ReactiveCircuitBreakerFactory

        org.springframework.cloud.circuitbreaker.resilience4j.ReactiveResilience4JCircuitBreakerFactory

    查看 ReactiveResilience4JCircuitBreakerFactory 的部分源码：

        private Function<String, Resilience4JConfigBuilder.Resilience4JCircuitBreakerConfiguration> defaultConfiguration;

        private CircuitBreakerRegistry circuitBreakerRegistry = CircuitBreakerRegistry.ofDefaults();

        private TimeLimiterRegistry timeLimiterRegistry = TimeLimiterRegistry.ofDefaults();

        public ReactiveResilience4JCircuitBreakerFactory(CircuitBreakerRegistry circuitBreakerRegistry,
                TimeLimiterRegistry timeLimiterRegistry) {
            this.circuitBreakerRegistry = circuitBreakerRegistry;
            this.timeLimiterRegistry = timeLimiterRegistry;
            this.defaultConfiguration = id -> new Resilience4JConfigBuilder(id)
                    .circuitBreakerConfig(this.circuitBreakerRegistry.getDefaultConfig())
                    .timeLimiterConfig(this.timeLimiterRegistry.getDefaultConfig()).build();
        }

    可以看到 ReactiveResilience4JCircuitBreakerFactory 里面存在两个 registry：

        CircuitBreakerRegistry                  # 断路器注册中心，使用 resilience4j 的 circuitbreaker

        TimeLimiterRegistry                     # 限时器注册中心，使用 resilience4j 的 timelimiter

    所以在使用 resilience4j 过滤器的时候，我们只需要配置 resilience4j 的 circuitbreaker 和 timelimiter

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

### 限流器 RequestRateLimiter 配置

    配置示例：

        spring:
          cloud:
            gateway:
              routes:
              - id: baidu
                predicates:
                  - Path=/baidu/**
                filters:
                  - name: RequestRateLimiter
                    args:
                      redis-rate-limiter.replenishRate: 1
                      redis-rate-limiter.burstCapacity: 1
                      redis-rate-limiter.requestedTokens: 1
                  - StripPrefix=1
                uri: https://www.baidu.com

    参数含义：

        replenishRate                   # 每秒产生的令牌数

        burstCapacity                   # 令牌桶大小

        requestedTokens                 # 每次请求消耗令牌数，一般都是设置为 1 个

    需要自定义 KeyResolver 获取当前用户的限流标识：

        @Component
        public class GatewayRateLimiterKeyResolver implements KeyResolver {

            @Override
            public Mono<String> resolve(ServerWebExchange exchange) {
                return Mono.just(exchange.getRequest().getRemoteAddress().getAddress().getHostAddress());
            }

        }

    默认的限流过滤器只返回异常状态码(目前版本)，考虑抛出异常修饰为提示信息，继承重写过滤器部分逻辑，并配置为 bean：

        public class RequestRateLimiterGatewayFilterFactoryAdapter extends RequestRateLimiterGatewayFilterFactory {

            public RequestRateLimiterGatewayFilterFactoryAdapter(RateLimiter<?> defaultRateLimiter, KeyResolver defaultKeyResolver) {
                super(defaultRateLimiter, defaultKeyResolver);
            }

            @Override
            public String name() {
                return "RequestRateLimiterAdapter";
            }

            private <T> T getOrDefault(T configValue, T defaultValue) {
                return (configValue != null) ? configValue : defaultValue;
            }

            @SuppressWarnings("unchecked")
            @Override
            public GatewayFilter apply(Config config) {

                KeyResolver resolver = getOrDefault(config.getKeyResolver(), getDefaultKeyResolver());
                RateLimiter<Object> limiter = getOrDefault(config.getRateLimiter(), getDefaultRateLimiter());
                boolean denyEmpty = getOrDefault(config.getDenyEmptyKey(), isDenyEmptyKey());

                return (exchange, chain) -> resolver.resolve(exchange).defaultIfEmpty(KEY_RESOLVER_KEY).flatMap(key -> {
                    if (KEY_RESOLVER_KEY.equals(key)) {
                        if (denyEmpty) {
                            throw new StatusCodeException(StatusCode.API_NOT_ACCEPTABLE);
                        }
                        return chain.filter(exchange);
                    }
                    String routeId = config.getRouteId();
                    if (routeId == null) {
                        Route route = exchange.getAttribute(ServerWebExchangeUtils.GATEWAY_ROUTE_ATTR);
                        routeId = route.getId();
                    }
                    return limiter.isAllowed(routeId, key).flatMap(response -> {

                        for (Map.Entry<String, String> header : response.getHeaders().entrySet()) {
                            exchange.getResponse().getHeaders().add(header.getKey(), header.getValue());
                        }

                        if (response.isAllowed()) {
                            return chain.filter(exchange);
                        } else {
                            throw new StatusCodeException(StatusCode.USER_FREQUENCY_TOO_QUICKLY);
                        }

                    });
                });
            }

        }

        @Bean
        public RequestRateLimiterGatewayFilterFactoryAdapter requestRateLimiterGatewayFilterFactoryAdapter(RateLimiter<?> rateLimiter, KeyResolver resolver) {
            return new RequestRateLimiterGatewayFilterFactoryAdapter(rateLimiter, resolver);
        }

    以上配置方式一致，只需把限流过滤器名称换成 RequestRateLimiterAdapter 即可：

        spring:
          cloud:
            gateway:
              routes:
              - id: baidu
                predicates:
                  - Path=/baidu/**
                filters:
                  - name: RequestRateLimiterAdapter
                    args:
                      redis-rate-limiter.replenishRate: 1
                      redis-rate-limiter.burstCapacity: 1
                      redis-rate-limiter.requestedTokens: 1
                  - StripPrefix=1
                uri: https://www.baidu.com

    当前版本的限流器存在问题(不太建议使用，可以考虑自己重写所有实现)：

        redis 无法连接的时候，限流不生效，也不报错

        redis 版本过低不支持逻辑命令，限流不生效，也不报错

        只返回状态码，不允许配置化抛出异常
