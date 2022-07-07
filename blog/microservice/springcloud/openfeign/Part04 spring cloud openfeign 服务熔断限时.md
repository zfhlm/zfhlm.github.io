
# spring cloud openfeign 服务熔断限时

### 相关文档

  * 官方文档地址：

        https://docs.spring.io/spring-cloud/docs/current/reference/html/

        https://docs.spring.io/spring-cloud-openfeign/docs/current/reference/html

        https://docs.spring.io/spring-cloud-openfeign/docs/current/reference/html/appendix.html

        https://docs.spring.io/spring-cloud-circuitbreaker/docs/current/reference/html/

        https://resilience4j.readme.io/docs

  * 示例源码地址：

        https://github.com/zfhlm/mrh-example/tree/main/mrh-spring-cloud

### 服务熔断限时

  * 服务熔断，考虑到多层依赖：

            service-A                                   service-B                                service-C
        .................................             .................................             .............
        ||--------------|               |             ||--------------|               |             |           |
        || circuit open |               |             || circuit open |               |             |           |
        ||<-------------|               |             ||<-------------|               |             |           |
        || circuit half |               |------------>|| circuit half |               |------------>|           |
        ||<-------------| half or close |             ||<-------------| half or close |             |           |
        ||              |-------------->|             ||              |-------------->|             |           |
        ||                              |             ||                              |             |           |
        ||                  http 200    |<------------||                  http 200    |<------------|           |
        ||              |<--------------|             ||              |<--------------|             |           |
        ||              |  decode error |             ||              |  decode error |             |           |
        ||    calculate |<--------------|             ||    calculate |<--------------|             |           |
        ||<-------------|               |             ||<-------------|               |             |           |
        .................................             .................................             .............

        (calculate 统计响应结果，根据结果统计值转换 open、half open、close 三种熔断状态)

        ①，服务有使用 openfeign 进行远程调用才开启熔断，例如 service-C 无远程调用则无需开启

        ②，熔断默认统计所有异常，可以自定义异常解码器抛出不同类型异常，然后忽略统计某些异常

        ③，熔断异常应该在服务内部被处理完成，不宜再往上传递，否则会导致调用链每层都触发熔断

  * 服务限时，限制请求最大等待时间，超过则中断请求并抛出异常

### 服务调用开启熔断限时

  * 引入 maven 依赖：

        <dependency>
            <groupId>org.springframework.cloud</groupId>
            <artifactId>spring-cloud-starter-circuitbreaker-resilience4j</artifactId>
        </dependency>

  * 手动注册 FallbackFactory (也可以使用自动扫描注入)：

        @Configuration
        public class FallbackConfiguration {

            @Bean
            public OrganClientFallbackFactory organClientFallbackFactory() {
                return new OrganClientFallbackFactory();
            }

        }

  * 添加 application.yml 配置开启熔断：

        feign:
          circuitbreaker:
            enabled: true
            group.enabled: false
            alphanumeric-ids.enabled: false

### 熔断限时默认配置

  * 默认的熔断、限时配置不一定合理，复用 resilience4j 注入配置，从中读取以下两个配置，作为熔断、限时默认配置：

        resilience4j.circuitbreaker.configs.default

        resilience4j.timelimiter.configs.default

  * 创建覆盖默认配置 bean 实现：

        public class ConfigureDefaultCircuitBreakerFactoryCustomizer implements Customizer<Resilience4JCircuitBreakerFactory> {

            private static final String name = "default";    // 默认配置名称

            private CircuitBreakerProperties circuitBreakerProperties;

            private TimeLimiterProperties timeLimiterProperties;

            public ConfigureDefaultCircuitBreakerFactoryCustomizer(
                    CircuitBreakerProperties circuitBreakerProperties,
                    TimeLimiterProperties timeLimiterProperties) {
                super();
                this.circuitBreakerProperties = circuitBreakerProperties;
                this.timeLimiterProperties = timeLimiterProperties;
            }

            @Override
            public void customize(Resilience4JCircuitBreakerFactory circuitBreakerFactory) {

                // 读取熔断默认配置
                CircuitBreakerConfig defaultCircuitBreakerConfig = Optional.ofNullable(this.circuitBreakerProperties.getConfigs().get(name))
                        .map(properties -> this.circuitBreakerProperties.createCircuitBreakerConfig(name, properties, new CompositeCustomizer<>(Collections.emptyList())))
                        .orElse(CircuitBreakerConfig.ofDefaults());

                // 读取限时默认配置
                TimeLimiterConfig defaultTimeLimiterConfig = Optional.ofNullable(this.timeLimiterProperties.getConfigs().get(name))
                        .map(properties -> this.timeLimiterProperties.createTimeLimiterConfig(name, properties, new CompositeCustomizer<>(Collections.emptyList())))
                        .orElse(TimeLimiterConfig.ofDefaults());

                // 配置到断路器工厂
                circuitBreakerFactory.configureDefault(id -> new Resilience4JConfigBuilder(id)
                        .circuitBreakerConfig(defaultCircuitBreakerConfig)
                        .timeLimiterConfig(defaultTimeLimiterConfig)
                        .build());
            }

        }

  * 注入覆盖默认配置 bean 实现：

        @Bean
        public ConfigureDefaultCircuitBreakerFactoryCustomizer configureDefaultCircuitBreakerFactoryCustomizer(
                CircuitBreakerProperties circuitBreakerProperties,
                TimeLimiterProperties timeLimiterProperties) {
            return new ConfigureDefaultCircuitBreakerFactoryCustomizer(circuitBreakerProperties, timeLimiterProperties);
        }

  * 如果以下配置存在，则会覆盖默认配置：

        # 这里不再解释参数，查看 resilience4j 官方文档，或查看博客 [spring cloud gateway 熔断 resilience4j]
        resilience4j:
          circuitbreaker:
            configs:
              default:
                failureRateThreshold: 50
                slowCallRateThreshold: 100
                slowCallDurationThreshold: 60s
                waitDurationInOpenState: 60s
                permittedNumberOfCallsInHalfOpenState: 10
                slidingWindowType: COUNT_BASED
                slidingWindowSize: 100
                minimumNumberOfCalls: 10
                ignoreExceptions:
                  - org.lushen.mrh.cloud.reference.supports.ServiceBusinessException
          timelimiter:
            configs:
              default:
                timeoutDuration: 5s
                cancelRunningFuture: true

### 熔断实例配置

  * 熔断自动配置类，可以看到使用了 resilience4j 的 circuitBreaker、timeLimiter 和 Bulkhead(非必须，限流相关)：

        org.springframework.cloud.circuitbreaker.resilience4j.Resilience4JAutoConfiguration

  * 熔断默认基于方法级别，每个方法作为一个熔断实例，实例名称解析实现，可查看源码：

        org.springframework.cloud.openfeign.FeignAutoConfiguration.CircuitBreakerPresentFeignTargeterConfiguration.DefaultCircuitBreakerNameResolver

        org.springframework.cloud.openfeign.FeignAutoConfiguration.CircuitBreakerPresentFeignTargeterConfiguration.AlphanumericCircuitBreakerNameResolver

        (因为 resilience4j 配置文件注入不支持非字母、数字、横杠连接符之外字符，所以提供了 alphanumeric-ids 实例名称解析器，具体查看官方文档)

  * 创建自定义熔断实例名称解析器，例如每个 openfeign remote service 作为一个熔断实例：

        public class ServiceNameCircuitBreakerNameResolver implements CircuitBreakerNameResolver {

            @Override
            public String resolveCircuitBreakerName(String feignClientName, Target<?> target, Method method) {
                return target.name();
            }

        }

  * 创建自定义熔断实例名称解析器，例如每个 openfeign client 作为一个熔断实例：

        public class ClientNameCircuitBreakerNameResolver implements CircuitBreakerNameResolver {

            private final Map<String, String> mappings = new ConcurrentHashMap<>();

            @Override
            public String resolveCircuitBreakerName(String feignClientName, Target<?> target, Method method) {
                return mappings.computeIfAbsent(feignClientName, k -> {
                    // guava 库
                    return CaseFormat.LOWER_CAMEL.to(CaseFormat.LOWER_HYPHEN, feignClientName.replaceAll("[^a-zA-Z0-9\\-]", ""));
                });
            }

        }

  * 创建自定义熔断实例名称解析器，例如每个 openfeign method 作为一个熔断实例(自定义名称生成方式)：

        public class MethodNameCircuitBreakerNameResolver implements CircuitBreakerNameResolver {

            @Override
            public String resolveCircuitBreakerName(String feignClientName, Target<?> target, Method method) {

                StringBuilder builder = new StringBuilder();

                // 客户端名称
                for(char ch : feignClientName.toCharArray()) {
                    if(Character.isLetter(ch) || Character.isDigit(ch) || ch == '-') {
                        builder.append(ch);
                    }
                }

                // 连接符
                if(builder.charAt(builder.length()-1) != '-') {
                    builder.append('-');
                }

                // 方法名称
                for(char ch : method.getName().toCharArray()) {
                    if(Character.isLetter(ch) || Character.isDigit(ch)) {
                        builder.append(ch);
                    }
                }

                // guava 库，统一转换
                return CaseFormat.LOWER_CAMEL.to(CaseFormat.LOWER_HYPHEN, builder.toString());

            }

        }

  * 注册自定义解析器 bean (注册一个即可，这里使用 每个 openfeign client 作为一个熔断实例)：

        @Bean
        public ClientNameCircuitBreakerNameResolver clientNameCircuitBreakerNameResolver() {
            return new ClientNameCircuitBreakerNameResolver();
        }

  * 添加 application.yml 熔断实例配置：

        # 这里不再解释参数，查看 resilience4j 官方文档，或查看博客 [spring cloud gateway 熔断 resilience4j]
        resilience4j:
          circuitbreaker:
            configs:
              default:
                failureRateThreshold: 50
                slowCallRateThreshold: 100
                slowCallDurationThreshold: 60s
                waitDurationInOpenState: 60s
                permittedNumberOfCallsInHalfOpenState: 10
                slidingWindowType: COUNT_BASED
                slidingWindowSize: 100
                minimumNumberOfCalls: 10
                ignoreExceptions:
                  - org.lushen.mrh.cloud.reference.supports.ServiceBusinessException
            instances:
              organ-client:
                baseConfig: default
          timelimiter:
            configs:
              default:
                timeoutDuration: 5s
                cancelRunningFuture: true
            instances:
              organ-client:
                baseConfig: default
