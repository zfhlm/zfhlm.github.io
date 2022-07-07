
# spring cloud openfeign 服务容错隔离

### 相关文档

  * 官方文档地址：

        https://docs.spring.io/spring-cloud/docs/current/reference/html/

        https://docs.spring.io/spring-cloud-openfeign/docs/current/reference/html

        https://docs.spring.io/spring-cloud-openfeign/docs/current/reference/html/appendix.html

        https://docs.spring.io/spring-cloud-circuitbreaker/docs/current/reference/html/

        https://docs.spring.io/spring-cloud-circuitbreaker/docs/current/reference/html/#bulkhead-pattern-supporting

        https://resilience4j.readme.io/docs

  * 示例源码地址：

        https://github.com/zfhlm/mrh-example/tree/main/mrh-spring-cloud

### 容错隔离说明

  * 基于 resilience4j bulkhead 实现，需要引入 maven 依赖：

        <dependency>
            <groupId>io.github.resilience4j</groupId>
            <artifactId>resilience4j-bulkhead</artifactId>
        </dependency>

  * 提供了两种隔离方式：

        FixedThreadPoolBulkhead             # 固定数量线程池隔离，默认使用此方式

        SemaphoreBulkhead                   # 基于信号量进行隔离

  * 当 feign.circuitbreaker.group.enabled=false 时，每个 熔断限时实例 作为一个隔离仓：

        ①，如果实例生效范围是 service 级别，那每个 service 一个隔离仓

        ②，如果实例生效范围是 client 级别，那么每个 client 一个隔离仓

        ③，如果实例生效范围是 method 级别，那么每个 method 一个隔离仓

        隔离仓的名称 = 实例名称

  * 当 feign.circuitbreaker.group.enabled=true 时，每个 client 作为一个隔离仓：

        ①，如果实例生效范围是 service 级别，仍然是每个 client 作为一个隔离仓

        ②，如果实例生效范围是 client 级别，仍然是每个 client 作为一个隔离仓

        ③，如果实例生效范围是 method 级别，仍然是每个 client 作为一个隔离仓

        隔离仓的名称 = @FeignClient#contextId()

  * 线程池隔离必须考虑的问题：

        每个隔离仓都有自己单独一个线程池，必须防止线程池数量过多，性能急剧下降

### 容错隔离配置

  * 线程池隔离，添加 application.yml 配置：

        spring:
          cloud:
            circuitbreaker:
              bulkhead:
                resilience4j:
                  enabled: true
              resilience4j:
                enableSemaphoreDefaultBulkhead: false

        feign:
          circuitbreaker:
            group:
              enabled: true
        resilience4j:
          thread-pool-bulkhead:
            configs:
              default:
                maxThreadPoolSize: 20
                coreThreadPoolSize: 1
                queueCapacity: 5
            instances:
              # 隔离仓名称
              organ-client:
                baseConfig: default

  * 信号量隔离，添加 application.yml 配置：

        spring:
          cloud:
            circuitbreaker:
              bulkhead:
                resilience4j:
                  enabled: true
              resilience4j:
                enableSemaphoreDefaultBulkhead: true

        feign:
          circuitbreaker:
            group:
              enabled: true
        resilience4j:
          bulkhead:
            configs:
              default:
                maxConcurrentCalls: 30
            instances:
              # 隔离仓名称
              organ-client:
                baseConfig: default

### 全局默认配置

  * 创建覆盖默认配置的 Customizer 实现：

        public class ConfigureDefaultBulkheadProviderCustomizer implements Customizer<Resilience4jBulkheadProvider> {

            private static final String name = "default";    // 默认配置名称

            private ThreadPoolBulkheadProperties threadPoolBulkheadProperties;

            private BulkheadProperties bulkheadProperties;

            public ConfigureDefaultBulkheadProviderCustomizer(
                    ThreadPoolBulkheadProperties threadPoolBulkheadProperties,
                    BulkheadProperties bulkheadProperties) {
                super();
                this.threadPoolBulkheadProperties = threadPoolBulkheadProperties;
                this.bulkheadProperties = bulkheadProperties;
            }

            @Override
            public void customize(Resilience4jBulkheadProvider provider) {

                // 线程池隔离默认配置
                ThreadPoolBulkheadConfig defaultThreadPoolBulkheadConfig = Optional.ofNullable(this.threadPoolBulkheadProperties.getConfigs().get(name))
                        .map(properties -> this.threadPoolBulkheadProperties.createThreadPoolBulkheadConfig(name, new CompositeCustomizer<>(Collections.emptyList())))
                        .orElse(ThreadPoolBulkheadConfig.ofDefaults());

                // 信号量隔离默认配置
                BulkheadConfig defaultBulkheadConfig = Optional.ofNullable(this.bulkheadProperties.getConfigs().get(name))
                        .map(properties -> this.bulkheadProperties.createBulkheadConfig(properties, new CompositeCustomizer<>(Collections.emptyList()), name))
                        .orElse(BulkheadConfig.ofDefaults());

                // 添加到默认配置
                provider.configureDefault(id -> new Resilience4jBulkheadConfigurationBuilder()
                        .bulkheadConfig(defaultBulkheadConfig)
                        .threadPoolBulkheadConfig(defaultThreadPoolBulkheadConfig)
                        .build());

            }

        }

  * 注册 Customizer 为 bean：

        @Bean
        public ConfigureDefaultBulkheadProviderCustomizer configureDefaultBulkheadProviderCustomizer(
                ThreadPoolBulkheadProperties threadPoolBulkheadProperties,
                BulkheadProperties bulkheadProperties) {
            return new ConfigureDefaultBulkheadProviderCustomizer(threadPoolBulkheadProperties, bulkheadProperties);
        }

### 线程池隔离仓 线程上下文传递

  * 查看 openfeign circuitbreaker 相关实现：

        org.springframework.cloud.openfeign.FeignCircuitBreakerInvocationHandler


        private Supplier<Object> asSupplier(final Method method, final Object[] args) {
            final RequestAttributes requestAttributes = RequestContextHolder.getRequestAttributes();
            return () -> {
                try {
                    RequestContextHolder.setRequestAttributes(requestAttributes);
                    return dispatch.get(method).invoke(args);
                }
                catch (RuntimeException throwable) {
                    throw throwable;
                }
                catch (Throwable throwable) {
                    throw new RuntimeException(throwable);
                }
            };
        }

        可以发现默认已经对 RequestAttributes 线程上下文进行了传递

  * 如果需要对其他线程上下文进行传递，需要重写并替换相关实现：

        org.springframework.cloud.openfeign.FeignCircuitBreaker
