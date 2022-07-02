
# spring cloud gateway 限流 guava

### 项目源码地址

    https://github.com/zfhlm/mrh-example/tree/main/mrh-spring-cloud

### guava 路由应用级别限流

    引入 maven 依赖：

        <dependency>
            <groupId>com.google.guava</groupId>
            <artifactId>guava</artifactId>
        </dependency>

    编写过滤器工厂：

        public class GuavaRateLimiterGatewayFilterFactory extends AbstractGatewayFilterFactory<Config> {

            private static final int defaultPermitsPerSecond = 50;

            private final ConcurrentMap<String, RateLimiter> rateLimiters = new ConcurrentHashMap<>();

            public GuavaRateLimiterGatewayFilterFactory() {
                super(Config.class);
            }

            @Override
            public GatewayFilter apply(Config config) {
                return (exchange, chain) -> {
                    // 获取当前路由限流器
                    Route route = exchange.getAttribute(GATEWAY_ROUTE_ATTR);
                    RateLimiter rateLimiter = rateLimiters.computeIfAbsent(route.getId(), k -> {
                        if(config.getPermitsPerSecond() != null && config.getPermitsPerSecond() > 0) {
                            return RateLimiter.create(config.getPermitsPerSecond());
                        } else {
                            return RateLimiter.create(defaultPermitsPerSecond);
                        }
                    });
                    // 根据获取令牌结果，决定执行或抛出异常
                    if(rateLimiter.tryAcquire()) {
                        return chain.filter(exchange);
                    } else {
                        throw new StatusCodeException(StatusCode.SERVER_BUSINESS);
                    }
                };
            }

            @Override
            public List<String> shortcutFieldOrder() {
                return Arrays.asList("permitsPerSecond");
            }

            public static class Config {

                // 每秒产生多少个令牌
                private Integer permitsPerSecond;

                public Integer getPermitsPerSecond() {
                    return permitsPerSecond;
                }

                public void setPermitsPerSecond(Integer permitsPerSecond) {
                    this.permitsPerSecond = permitsPerSecond;
                }

            }

        }

    注册过滤器工厂 bean：

        @Bean
        public GuavaRateLimiterGatewayFilterFactory guavaRateLimiterGatewayFilterFactory() {
            return new GuavaRateLimiterGatewayFilterFactory();
        }

    过滤器配置示例：

        # 每秒允许最大 10 个请求
        spring:
          cloud:
            gateway:
              routes:
              - id: baidu
                predicates:
                  - Path=/baidu/**
                filters:
                  - GuavaRateLimiter=10
                  - StripPrefix=1
                uri: https://www.baidu.com
