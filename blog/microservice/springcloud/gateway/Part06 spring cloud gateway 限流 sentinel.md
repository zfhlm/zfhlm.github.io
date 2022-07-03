
# spring cloud gateway 限流 sentinel

### 相关文档

  * 官方文档地址：

        https://docs.spring.io/spring-cloud/docs/current/reference/html/

        https://docs.spring.io/spring-cloud-gateway/docs/current/reference/html/

        https://sentinelguard.io/zh-cn/docs/flow-control.html

        https://github.com/alibaba/Sentinel/wiki/API-Gateway-Flow-Control

  * 示例源码地址：

        https://github.com/zfhlm/mrh-example/tree/main/mrh-spring-cloud

### 网关 sentinel 限流配置

  * 引入 maven 依赖：

        <dependency>
            <groupId>com.alibaba.csp</groupId>
            <artifactId>sentinel-spring-cloud-gateway-adapter</artifactId>
        </dependency>

  * 重写过滤器(自定义顺序和配置注入)：

        public class SentinelGatewayFilterFactory extends AbstractGatewayFilterFactory<NameConfig> implements InitializingBean {

            private Set<GatewayFlowRule> rules = new HashSet<GatewayFlowRule>();

            public SentinelGatewayFilterFactory() {
                super(NameConfig.class);
            }

            @Override
            public void afterPropertiesSet() throws Exception {
                GatewayRuleManager.loadRules(this.rules);
            }

            @Override
            public GatewayFilter apply(NameConfig config) {
                return (exchange, chain) -> new SentinelGatewayFilter().filter(exchange, chain);
            }

            public Set<GatewayFlowRule> getRules() {
                return rules;
            }

            public void setRules(Set<GatewayFlowRule> rules) {
                this.rules = rules;
            }

        }

  * 注册过滤器工厂 bean：

        @Bean
        @ConfigurationProperties(prefix="sentinel.gateway.flow")
        public SentinelGatewayFilterFactory SentinelConfiguration() {
            return new SentinelGatewayFilterFactory();
        }

  * 添加 application.yml 限流配置：

        spring:
          cloud:
            gateway:
              routes:
              - id: baidu
                predicates:
                  - Path=/baidu/**
                filters:
                  - Sentinel
                  - StripPrefix=1
                uri: https://www.baidu.com
        sentinel:
          gateway:
            flow:
              rules:
              - resource: baidu
                count: 1
                interval-sec: 1

  * 更改 sentinel 输出日志目录，二选一配置：

        // 添加 java 启动参数
        -Dcsp.sentinel.log.dir=/usr/local/logs/csp/

        // 启动类 main 最前面添加如下代码
        System.setProperty("csp.sentinel.log.dir", "/usr/local/logs/csp/");
