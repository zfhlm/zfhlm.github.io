
# spring cloud discovery 注册中心 simple

### 相关文档

  * 官方文档地址：

        https://docs.spring.io/spring-cloud/docs/current/reference/html/

        https://docs.spring.io/spring-cloud-commons/docs/current/reference/html/#simplediscoveryclient

  * 示例源码地址：

        https://github.com/zfhlm/mrh-example/tree/main/mrh-spring-cloud

### 服务发现客户端

  * DiscoveryClient 有以下几种实现：

        ZookeeperDiscoveryClient                # zookeeper 注册中心服务发现客户端

        ConsulDiscoveryClient                   # consul 注册中心服务发现客户端

        EurekaDiscoveryClient                   # eureka 注册中心服务发现客户端

        NacosDiscoveryClient                    # nacos 注册中心服务发现客户端

        SimpleDiscoveryClient                   # 静态地址服务发现客户端，适用于开发环境、直调第三方API服务等

        CompositeDiscoveryClient                # 多注册中心服务发现客户端，所有客户端最终都会包装为一个客户端

  * CompositeDiscoveryClient 用于自动包装所有服务发现客户端，不用作任何配置，源码可见：

        @Configuration(proxyBeanMethods = false)
        @AutoConfigureBefore(SimpleDiscoveryClientAutoConfiguration.class)
        public class CompositeDiscoveryClientAutoConfiguration {

            @Bean
            @Primary
            public CompositeDiscoveryClient compositeDiscoveryClient(List<DiscoveryClient> discoveryClients) {
                return new CompositeDiscoveryClient(discoveryClients);
            }

        }

### 服务发现客户端 SimpleDiscoveryClient

  * 引入 maven 依赖：

        <dependency>
            <groupId>org.springframework.cloud</groupId>
            <artifactId>spring-cloud-starter-loadbalancer</artifactId>
        </dependency>

  * 假设提供服务的 openfeign 接口定义如下：

        @FeignClient(name="mrh-spring-cloud-service-organ", contextId="organClient")
        public interface OrganClient {

            @GetMapping(path="/api/organ/{id}")
            public Organ get(@PathVariable(name="id", required=true) long id);

            @PostMapping(path="/api/organ")
            public void add(@RequestBody Organ organ);

        }

  * 以上接口配置请求 mrh-spring-cloud-service-organ 服务，但服务地址是静态的，此时我们可以引入以下配置：

        spring:
          cloud:
            discovery:
              client:
                simple:
                  instances:
                    # 一个或多个地址，按实际配置
                    mrh-spring-cloud-service-organ:
                    - uri: http://localhost:9527
                    - uri: http://localhost:9627
                    - uri: http://localhost:9727

  * 启动类添加注解：

        @EnableFeignClients(basePackageClasses= {OrganClient.class})

  * 使用 openfeign 接口调用服务：

        @Autowired
        private OrganClient organClient;

        public void test() {
            organClient.get(1L);
        }
