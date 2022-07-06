
# spring cloud gateway 自定义路由判定规则

### 相关文档

  * 官方文档地址：

        https://docs.spring.io/spring-cloud/docs/current/reference/html/

        https://docs.spring.io/spring-cloud-gateway/docs/current/reference/html/

  * 示例源码地址：

        https://github.com/zfhlm/mrh-example/tree/main/mrh-spring-cloud

### 网关路由断言扩展

  * 实现 AbstractRoutePredicateFactory 自定义路由断言，示例为绝对匹配 path 前缀：

        public class PathStartWithRoutePredicateFactory extends AbstractRoutePredicateFactory<Config> {

            public PathStartWithRoutePredicateFactory() {
                super(Config.class);
            }

            @Override
            public Predicate<ServerWebExchange> apply(Config config) {

                return (exchange -> {

                    if(config.getPaths() == null || config.getPaths().isEmpty()) {
                        return false;
                    }

                    String path = exchange.getRequest().getURI().getRawPath();
                    for(String prefixPath : config.getPaths()) {
                        if(path.startsWith(prefixPath)) {
                            String routeId = (String) exchange.getAttributes().get(GATEWAY_PREDICATE_ROUTE_ATTR);
                            if (routeId != null) {
                                exchange.getAttributes().put(GATEWAY_PREDICATE_MATCHED_PATH_ROUTE_ID_ATTR, routeId);
                            }
                            return true;
                        }
                    }

                    return false;

                });

            }

            @Override
            public List<String> shortcutFieldOrder() {
                return Arrays.asList("paths");
            }

            public static class Config {

                private List<String> paths;

                public List<String> getPaths() {
                    return paths;
                }

                public void setPaths(List<String> paths) {
                    this.paths = paths;
                }

            }

        }

  * 注册自定义路由断言工厂：

        @Bean
        public PathStartWithRoutePredicateFactory pathStartWithRoutePredicateFactory() {
            return new PathStartWithRoutePredicateFactory();
        }

  * 使用自定义路由断言：

        spring:
          cloud:
            gateway:
              routes:
              - id: baidu
                predicates:
                  - PathStartWith=/baidu/
                filters:
                  - StripPrefix=1
                uri: https://www.baidu.com
