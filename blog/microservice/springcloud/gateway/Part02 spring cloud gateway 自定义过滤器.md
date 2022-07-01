
# spring cloud gateway 自定义过滤器

### 项目源码地址

    https://github.com/zfhlm/mrh-example/tree/main/mrh-spring-cloud

### mrh-spring-cloud-gateway 自定义过滤器

    创建 example filter factory，实现代码：

        public class ExampleGatewayFilterFactory extends AbstractGatewayFilterFactory<NameConfig> {

            private final Log log = LogFactory.getLog("ExampleFilter");

            public ExampleGatewayFilterFactory() {
                super(NameConfig.class);
            }

            // 过滤器名称，不重写默认为当前类名去除“GatewayFilterFactory”之后作为过滤器名称
            @Override
            public String name() {
                return "Example";
            }

            @Override
            public GatewayFilter apply(NameConfig config) {
                return (exchange, chain) -> {
                    log.info("example");
                    return chain.filter(exchange);
                };
            }

        }

    注入 bean 配置：

        @Configuration
        public class GatewayFilterConfiguration {

            @Bean
            public ExampleGatewayFilterFactory exampleGatewayFilterFactory() {
                return new ExampleGatewayFilterFactory();
            }

        }

    application.yml 添加自定义过滤器：

        spring:
          cloud:
            gateway:
              routes:
              - id: api-admin
                predicates:
                  - Path=/admin/**
                filters:
                  - Example
                  - StripPrefix=1
                uri: lb://mrh-spring-cloud-api-admin

    启动 mrh-spring-cloud-gateway 和 mrh-spring-cloud-api-admin，再访问如下地址：

        http://localhost:8081/admin/api/welcome

        -> (接口响应内容：{"errcode":0, "errmsg": "success"})

        -> (控制台输出：ExampleFilter - example)

### 过滤器执行顺序

    网关过滤器有两种类型：

        GlobalFilter                # 全局过滤器，对所有路由生效，官方用于实现路由的转发、负载均衡等逻辑，不建议业务扩展使用

        GatewayFilter               # 网关过滤器，一般使用 GatewayFilterFactory 创建 GatewayFilter，业务一般基于此进行扩展

    将 mrh-spring-cloud-gateway 日志调整到 debug 级别，并发起一次网关代理请求，日志输出：

        2022-06-28 10:55:50.351 DEBUG org.springframework.cloud.gateway.handler.FilteringWebHandler - Sorted gatewayFilterFactories:
        [
          [GatewayFilterAdapter{delegate=org.springframework.cloud.gateway.filter.RemoveCachedBodyFilter@da28d03}, order = -2147483648],
          [GatewayFilterAdapter{delegate=org.springframework.cloud.gateway.filter.AdaptCachedBodyGlobalFilter@23da79eb}, order = -2147482648],
          [GatewayFilterAdapter{delegate=org.springframework.cloud.gateway.filter.NettyWriteResponseFilter@2007435e}, order = -1],
          [GatewayFilterAdapter{delegate=org.springframework.cloud.gateway.filter.ForwardPathFilter@4d157493}, order = 0],
          [[Example], order = 1],
          [[StripPrefix parts = 1], order = 2],
          [GatewayFilterAdapter{delegate=org.springframework.cloud.gateway.filter.RouteToRequestUrlFilter@ebda593}, order = 10000],
          [GatewayFilterAdapter{delegate=org.springframework.cloud.gateway.filter.ReactiveLoadBalancerClientFilter@485caa8f}, order = 10150],
          [GatewayFilterAdapter{delegate=org.springframework.cloud.gateway.filter.LoadBalancerServiceInstanceCookieFilter@2703d91}, order = 10151],
          [GatewayFilterAdapter{delegate=org.springframework.cloud.gateway.filter.WebsocketRoutingFilter@54c622a7}, order = 2147483646],
          [GatewayFilterAdapter{delegate=org.springframework.cloud.gateway.filter.NettyRoutingFilter@5be052ca}, order = 2147483647],
          [GatewayFilterAdapter{delegate=org.springframework.cloud.gateway.filter.ForwardRoutingFilter@5792c08c}, order = 2147483647]
        ]

    查看 org.springframework.cloud.gateway.handler.FilteringWebHandler 源码，可以看到过滤器排序逻辑
