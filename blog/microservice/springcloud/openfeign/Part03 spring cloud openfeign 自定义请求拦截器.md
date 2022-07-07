
# spring cloud openfeign 自定义请求拦截器

### 相关文档

  * 官方文档地址：

        https://docs.spring.io/spring-cloud/docs/current/reference/html/

        https://docs.spring.io/spring-cloud-openfeign/docs/current/reference/html

        https://docs.spring.io/spring-cloud-openfeign/docs/current/reference/html/appendix.html

  * 示例源码地址：

        https://github.com/zfhlm/mrh-example/tree/main/mrh-spring-cloud

### 标识 openfeign 请求

  * 创建自定义拦截器：

        public class FromFeignRequestInterceptor implements RequestInterceptor {

            public static final String REQUEST_FROM_FEIGN_HEADER = "Request-From-Feign";

            public static final String REQUEST_FROM_FEIGN_VALUE = "true";

            @Override
            public void apply(RequestTemplate template) {
                template.header(REQUEST_FROM_FEIGN_HEADER, REQUEST_FROM_FEIGN_VALUE);
            }

        }

  * 注册为 spring bean 即完成配置：

        @Bean
        public FromFeignRequestInterceptor fromFeignRequestInterceptor() {
            return new FromFeignRequestInterceptor();
        }
