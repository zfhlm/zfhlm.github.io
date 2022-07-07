
# spring cloud openfeign 集成与配置

### 相关文档

  * 官方文档地址：

        https://docs.spring.io/spring-cloud/docs/current/reference/html/

        https://docs.spring.io/spring-cloud-openfeign/docs/current/reference/html

        https://docs.spring.io/spring-cloud-openfeign/docs/current/reference/html/appendix.html

  * 示例源码地址：

        https://github.com/zfhlm/mrh-example/tree/main/mrh-spring-cloud

### 创建模块

  * 创建三个 maven 模块：

        mrh-spring-cloud-reference                  # 公共接口模块

        mrh-spring-cloud-service-organ              # 提供 openfeign 服务

        mrh-spring-cloud-api-mobile                 # 调用 openfeign 服务

### 公共接口模块

  * 引入 maven 依赖：

        <dependency>
            <groupId>org.springframework.cloud</groupId>
            <artifactId>spring-cloud-starter-openfeign</artifactId>
            <optional>true</optional>
        </dependency>

  * 创建 openfeign 客户端接口：

        @FeignClient(name="${feign.clients.organ}", contextId="organClient", fallbackFactory=OrganClientFallbackFactory.class)
        public interface OrganClient {

            @GetMapping(path="/api/organ/{id}")
            public Organ get(@PathVariable(name="id", required=true) long id);

            @PostMapping(path="/api/organ")
            public void add(@RequestBody Organ organ);

        }

  * 创建 FallbackFactory 实现：

        public class OrganClientFallbackFactory implements FallbackFactory<OrganClient> {

            private final Log log = LogFactory.getLog(getClass());

            @Override
            public OrganClient create(Throwable cause) {
                log.error(cause, cause);
                return new OrganClient() {
                    @Override
                    public Organ get(long id) {
                        log.info("fallback get");
                        return new Organ();
                    }
                    @Override
                    public void add(Organ organ) {
                        log.info("fallback add");
                    }
                };
            }

        }

  * 注解 @FeignClient 一般定义如下参数：

        name                    # 目标服务名称，可使用 ${} 占位符由调用方指定

        path                    # 目标服务根路径，服务 context-path 非根路径才需要配置

        contextId               # 接口唯一的标识，生成接口代理实例时，此参数值作为 bean name

        configuration           # 接口调用 openfeign 私有配置

        fallback                # 接口调用 openfeign 容错处理实现类，开启 circuitbreaker 才会生效，与 fallbackFactory 二选一配置

        fallbackFactory         # 接口调用 openfeign 容错处理实现类工厂，开启 circuitbreaker 才会生效，与 fallback 二选一配置

        (注意：@FeignClient 仅作用于服务调用方，MVC 注解作用于服务实现、服务调用方)

### 服务提供方

  * 引入 maven 依赖：

        <dependency>
            <groupId>org.lushen.mrh</groupId>
            <artifactId>mrh-spring-cloud-reference</artifactId>
        </dependency>
        <dependency>
            <groupId>org.springframework.cloud</groupId>
            <artifactId>spring-cloud-starter-openfeign</artifactId>
        </dependency>
        <dependency>
            <groupId>org.springframework.cloud</groupId>
            <artifactId>spring-cloud-starter-zookeeper-discovery</artifactId>
        </dependency>

  * 创建启动类：

        @SpringBootApplication
        @ComponentScan(basePackageClasses=ApplicationStarter.class)
        @EnableDiscoveryClient
        public class ApplicationStarter {

            public static void main(String[] args) {
                SpringApplication.run(ApplicationStarter.class, args);
            }

        }

  * 添加 application.yml 配置：

        server:
          port: 9527
          servlet:
            context-path: /

        spring:
          application:
            name: mrh-spring-cloud-service-organ
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

  * 实现 openfeign 客户端接口

        @RestController
        public class OrganClientImpl implements OrganClient {

            private final Log log = LogFactory.getLog(getClass());

            @Override
            public Organ get(long id) {

                Organ organ = new Organ();
                organ.setId(id);
                organ.setName(UUID.randomUUID().toString());

                log.info(organ);

                return organ;
            }

            @Override
            public void add(Organ organ) {
                log.info(organ);
                throw new RuntimeException("测试");
            }

        }

### 服务调用方

  * 引入 maven 依赖：

        <dependency>
            <groupId>org.lushen.mrh</groupId>
            <artifactId>mrh-spring-cloud-reference</artifactId>
        </dependency>
        <dependency>
            <groupId>org.springframework.cloud</groupId>
            <artifactId>spring-cloud-starter-openfeign</artifactId>
        </dependency>
        <dependency>
            <groupId>org.springframework.cloud</groupId>
            <artifactId>spring-cloud-starter-zookeeper-discovery</artifactId>
        </dependency>

  * 创建启动类：

        @SpringBootApplication
        @ComponentScan(basePackageClasses=ApplicationStarter.class)
        @EnableDiscoveryClient
        @EnableFeignClients(basePackageClasses= {OrganClient.class})
        public class ApplicationStarter {

            public static void main(String[] args) {
                SpringApplication.run(ApplicationStarter.class, args);
            }

        }

  * 添加 application.yml 配置：

        server:
          port: 9528
          servlet:
            context-path: /

        spring:
          application:
            name: mrh-spring-cloud-api-mobile
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

        feign:
          # 指定 @FeignClient#name() 的实际名称，对应提供服务的应用名称
          clients:
            organ: mrh-spring-cloud-service-organ
          # 远程调用 http 配置
          httpclient:
            enabled: true
            disable-ssl-validation: true
            follow-redirects: true
            connection-timeout: 2000
            connection-timer-repeat: 3000
            max-connections: 200
            max-connections-per-route: 50
            time-to-live: 10
            time-to-live-unit: minutes
          # 客户端配置
          client:
            refresh-enabled: true
            default-to-properties: true
            default-config: default
            config:
              default:
                connect-timeout: 1000
                read-timeout: 2000
          # 开启请求响应报文压缩
          compression:
            request:
              enabled: true
              mime-types: application/json
              min-request-size: 1024
            response:
              enabled: true

  * 用于测试远程调用的 api：

        @RestController
        @RequestMapping(path="/api")
        public class OrganController {

            private final Log log = LogFactory.getLog(getClass());

            @Autowired
            private OrganClient organClient;
            @Autowired
            private DepartmentClient departmentClient;

            @GetMapping(path="/v1/organ/list")
            public ViewResult list() {

                Map<String, Object> map = new HashMap<>();
                map.put("organs", Arrays.asList(organClient.get(1), organClient.get(2)));
                map.put("departments", Arrays.asList(departmentClient.get(1), departmentClient.get(2)));

                log.info(map);

                return ViewResult.create(map);
            }

            @GetMapping(path="/v1/organ/add")
            public ViewResult add() {

                Organ organ = new Organ();
                organ.setId(1);
                organ.setName("test");
                organClient.add(organ);

                return ViewResult.create();
            }

        }

  * 分别启动 服务实现 和 当前服务，访问以下 api 查看是否成功：

        http://localhost:9528/api/v1/organ/list

        http://localhost:9528/api/v1/organ/add

### 失败重试

  * openfeign 默认为失败不重试，如果需要开启重试，查看以下官方实现，注册为 bean 即可：

        feign.Retryer

        feign.Retryer.Default

        Retryer feign.Retryer.NEVER_RETRY
