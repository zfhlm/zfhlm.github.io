
# spring cloud gateway 自定义过滤器

### 过滤器类型

    gateway 过滤器有两种类型：

        GlobalFilter                # 全局过滤器，对所有路由生效

        GatewayFilter               # 网关过滤器，一般使用 GatewayFilterFactory 进行创建，根据路由配置生效

    gateway 过滤器选择：

        官方用于实现路由的转发、负载均衡等逻辑，不建议使用

        业务一般使用 GatewayFilterFactory 创建 GatewayFilter，路由配置自由度更高

### 过滤器执行顺序

    启动 gateway 使用如下配置：

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

    查看 org.springframework.cloud.gateway.handler.FilteringWebHandler 源码，可以看到过滤器排序处理逻辑：

        private static List<GatewayFilter> loadFilters(List<GlobalFilter> filters) {
            return filters.stream().map(filter -> {
                GatewayFilterAdapter gatewayFilter = new GatewayFilterAdapter(filter);
                if (filter instanceof Ordered) {
                    int order = ((Ordered) filter).getOrder();
                    return new OrderedGatewayFilter(gatewayFilter, order);
                }
                return gatewayFilter;
            }).collect(Collectors.toList());
        }

        @Override
        public Mono<Void> handle(ServerWebExchange exchange) {
            Route route = exchange.getRequiredAttribute(GATEWAY_ROUTE_ATTR);
            List<GatewayFilter> gatewayFilters = route.getFilters();

            List<GatewayFilter> combined = new ArrayList<>(this.globalFilters);
            combined.addAll(gatewayFilters);
            // TODO: needed or cached?
            AnnotationAwareOrderComparator.sort(combined);

            if (logger.isDebugEnabled()) {
                logger.debug("Sorted gatewayFilterFactories: " + combined);
            }

            return new DefaultGatewayFilterChain(combined).filter(exchange);
        }

    将日志 debug 打开，并发起一次请求，日志如下显示：

        2022-06-28 10:55:50.351 DEBUG org.springframework.cloud.gateway.handler.FilteringWebHandler - Sorted gatewayFilterFactories:
        [
          [GatewayFilterAdapter{delegate=org.springframework.cloud.gateway.filter.RemoveCachedBodyFilter@da28d03}, order = -2147483648],
          [GatewayFilterAdapter{delegate=org.springframework.cloud.gateway.filter.AdaptCachedBodyGlobalFilter@23da79eb}, order = -2147482648],
          [GatewayFilterAdapter{delegate=org.springframework.cloud.gateway.filter.NettyWriteResponseFilter@2007435e}, order = -1],
          [GatewayFilterAdapter{delegate=org.springframework.cloud.gateway.filter.ForwardPathFilter@4d157493}, order = 0],
          [[SpringCloudCircuitBreakerResilience4JFilterFactory name = 'api-admin', fallback = forward:/fallback], order = 1],
          [[StripPrefix parts = 1], order = 2],
          [GatewayFilterAdapter{delegate=org.springframework.cloud.gateway.filter.RouteToRequestUrlFilter@ebda593}, order = 10000],
          [GatewayFilterAdapter{delegate=org.springframework.cloud.gateway.filter.ReactiveLoadBalancerClientFilter@485caa8f}, order = 10150],
          [GatewayFilterAdapter{delegate=org.springframework.cloud.gateway.filter.LoadBalancerServiceInstanceCookieFilter@2703d91}, order = 10151],
          [GatewayFilterAdapter{delegate=org.springframework.cloud.gateway.filter.WebsocketRoutingFilter@54c622a7}, order = 2147483646],
          [GatewayFilterAdapter{delegate=org.springframework.cloud.gateway.filter.NettyRoutingFilter@5be052ca}, order = 2147483647],
          [GatewayFilterAdapter{delegate=org.springframework.cloud.gateway.filter.ForwardRoutingFilter@5792c08c}, order = 2147483647]
        ]

    可以得知过滤器 order 处理逻辑：

        GolbalFilter 的 order 根据实现接口 Ordered 定义

        GatewayFilter 的 order 根据包装类 OrderedGatewayFilter 定义

        如果未根据以上规则定义 order，则从 1 ... n 根据顺序指定其 order

        合并所有 GolbalFilter、GatewayFilter 为一个过滤链，根据 order 对所有 filter 进行排序

    自定义过滤器的顺序问题：

        一般不需要指定其 order，在配置文件中按顺序配置即可，例如：登录验证过滤器，写在权限验证过滤器之前

        如果确实需要指定，必须考虑是否影响默认的过滤器

### 自定义过滤器

    创建一个打印请求 method、path、query 信息的过滤器，实现代码：

        public class LogLineGatewayFilterFactory extends AbstractGatewayFilterFactory<Config>  {

            private final Log log = LogFactory.getLog("log-request-filter");

            public LogLineGatewayFilterFactory() {
                super(Config.class);
            }

            @Override
            public GatewayFilter apply(Config config) {
                return new GatewayFilter() {
                    @Override
                    public Mono<Void> filter(ServerWebExchange exchange, GatewayFilterChain chain) {
                        ServerHttpRequest originRequest = exchange.getRequest();
                        String method = originRequest.getMethodValue();
                        String path = originRequest.getPath().value();
                        String query = originRequest.getURI().getRawQuery();
                        if(query != null) {
                            log.info(String.format("request line : %s %s - %s", method, path, query));
                        } else {
                            log.info(String.format("request line : %s %s", method, path));
                        }
                        return chain.filter(exchange.mutate().request(originRequest).build());
                    }
                    @Override
                    public String toString() {
                        return filterToStringCreator(LogLineGatewayFilterFactory.this).toString();
                    }
                };
            }

            public static class Config {}

        }

        @Configuration
        public class GatewayFilterConfiguration {

            @Bean
            public LogLineGatewayFilterFactory logLineGatewayFilterFactory() {
                return new LogLineGatewayFilterFactory();
            }

        }

    注意，过滤器 name 为实现类去除 "GatewayFilterFactory" 后缀，或重写 public String name() 方法返回一个指定的 name

    配置自定义过滤器：

        spring:
          cloud:
            gateway:
              routes:
              - id: api-admin
                predicates:
                  - Path=/admin/**
                filters:
                  - LogLine
                  - StripPrefix=1
                uri: lb://mrh-spring-cloud-api-admin
