
# spring cloud gateway 熔断限流 ratelimiter

### 项目源码地址

    https://github.com/zfhlm/mrh-example/tree/main/mrh-spring-cloud

### 官方文档地址

    https://docs.spring.io/spring-cloud-gateway/docs/current/reference/html/#the-requestratelimiter-gatewayfilter-factory

### 限流器 RequestRateLimiter

    官方自带的限流器底层基于 redis 令牌桶实现，当前版本的限流器存在问题，不太建议使用：

        redis 无法连接的时候，限流不生效，也不报错

        redis 版本过低不支持逻辑命令，限流不生效，也不报错

        只返回状态码，不允许配置化抛出异常

    引入 maven 配置：

        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-data-redis-reactive</artifactId>
        </dependency>

    配置示例：

        spring:
          redis:
            host: 192.168.140.144
            port: 6379
            timeout: 2s
            client-type: LETTUCE
            pool:
              max-active: 1000
              max-idle: 8
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

    必须自定义 KeyResolver 获取当前用户的限流标识(默认的实现基本不可用)：

        @Component
        public class GatewayRateLimiterKeyResolver implements KeyResolver {

            @Override
            public Mono<String> resolve(ServerWebExchange exchange) {
                return Mono.just(exchange.getRequest().getRemoteAddress().getAddress().getHostAddress());
            }

        }

    默认的限流过滤器只返回异常状态码(目前版本)，考虑抛出异常修饰为提示信息，可以继承重写过滤器部分逻辑：

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

    将重写部分逻辑的实现配置为 bean：

        @Bean
        public RequestRateLimiterGatewayFilterFactoryAdapter requestRateLimiterGatewayFilterFactoryAdapter(RateLimiter<?> rateLimiter, KeyResolver resolver) {
            return new RequestRateLimiterGatewayFilterFactoryAdapter(rateLimiter, resolver);
        }

    把限流过滤器名称换成 RequestRateLimiterAdapter：

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
