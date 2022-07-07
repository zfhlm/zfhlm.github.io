
# spring cloud bus 消息总线 amqp

### 相关文档

  * 官方文档地址：

        https://docs.spring.io/spring-cloud/docs/current/reference/html/

        https://docs.spring.io/spring-cloud-bus/docs/current/reference/html/

  * 示例源码地址：

        https://github.com/zfhlm/mrh-example/tree/main/mrh-spring-cloud

### 集成与配置

  * 添加 maven 依赖：

        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-web</artifactId>
        </dependency>
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-actuator</artifactId>
        </dependency>

        <dependency>
            <groupId>org.springframework.cloud</groupId>
            <artifactId>spring-cloud-starter-zookeeper-discovery</artifactId>
        </dependency>
        <dependency>
            <groupId>org.springframework.cloud</groupId>
            <artifactId>spring-cloud-starter-bus-amqp</artifactId>
        </dependency>

  * 创建启动类：

        @SpringBootApplication
        @ComponentScan(basePackageClasses=ApplicationStarter.class)
        @RemoteApplicationEventScan(basePackageClasses=ApplicationStarter.class)
        @EnableDiscoveryClient
        @EnableConfigurationProperties
        public class ApplicationStarter {

            public static void main(String[] args) {
                SpringApplication.run(ApplicationStarter.class, args);
            }

        }

  * 添加 application.yml 配置：

        server:
          port: 9537
          servlet:
            context-path: /

        spring:
          application:
            name: mrh-spring-cloud-service-bus-amqp
          rabbitmq:
            host: xxxxxx
            port: 5672
            username: MjphbXFwLWNuLXRsMzJycmEydzAwMTpMVEFJNXROTWZBZERkNGhvTmQ1MnJ3YkY=
            password: MUY5OTdGOUI2RTNCNkRCMDBEMUY5NkM1RDdGODRBRjM4QTk4MDU4ODoxNjU3MDYyNjkyODU1
            connection-timeout: 0
            publisher-confirms: true
            publisher-returns: true
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

        management:
          endpoints:
            web:
              exposure:
                include: '*'

        test.name: zhangsan

### 使用 bus 刷新配置

  * 创建测试接口相关类：

        @ConfigurationProperties(prefix="test")
        @RefreshScope
        public class TestProperties {

            private String name;

            public String getName() {
                return name;
            }

            public void setName(String name) {
                this.name = name;
            }

        }

        @Configuration
        public class TestConfiguration {

            @Bean
            public TestProperties testProperties() {
                return new TestProperties();
            }

        }

        @RestController
        public class TestController {

            @Autowired
            private TestProperties properties;

            @GetMapping(path="test")
            public String test() {
                return properties.getName();
            }

        }

        @Component
        public class TestListener implements ApplicationListener<RemoteApplicationEvent> {

            @Override
            public void onApplicationEvent(RemoteApplicationEvent event) {
                System.err.println(event);
            }

        }

  * 基于 application.yml 创建以下三份配置文件：

        application-dev1.yml    端口 9537

        application-dev2.yml    端口 9538

        application-dev3.yml    端口 9539

  * 使用以下 VM 参数启动三个服务实例：

        -Dspring.profiles.active=dev1

        -Dspring.profiles.active=dev2

        -Dspring.profiles.active=dev3

  * 使用 bus 重新绑定 @ConfigurationProperties 和 @RefreshScope 绑定的 bean：

        curl -x POST http://localhost:9537/actuator/busrefresh

        curl -x POST http://localhost:9537/actuator/busrefresh/mrh-spring-cloud-service-bus-amqp

        curl -x POST http://localhost:9537/actuator/busrefresh/mrh-spring-cloud-service-bus-amqp:9527

        每次执行完都可以看到，控制台接收 RefreshRemoteApplicationEvent 事件

        spring cloud config 正是基于此机制进行配置更新通知

  * 使用 bus 刷新 spring environment 配置：

        curl -H "Content-type: application/json" -x POST -d '{"name":"test.name","value":"zhangsan"}' http://localhost:9537/actuator/busenv

        curl -H "Content-type: application/json" -x POST -d '{"name":"test.name","value":"lisi"}' http://localhost:9537/actuator/busenv/mrh-spring-cloud-service-bus-amqp

        curl -H "Content-type: application/json" -x POST -d '{"name":"test.name","value":"wangwu"}' http://localhost:9537/actuator/busenv/mrh-spring-cloud-service-bus-amqp:9537

        每次执行完都可以看到，控制台接收 EnvironmentChangeRemoteApplicationEvent 事件

        每次刷新完成，请求接口 http://localhost:port/test 能看到配置已经发生变更

  * 关于 bus endpoints 路径：

        # 重新绑定通知
        /actuator/busrefresh

        # 重新绑定通知，指定服务名
        /actuator/busrefresh/<spring.application.name>

        # 重新绑定通知，指定服务名、服务端口号
        /actuator/busrefresh/<spring.application.name>:<server.port>

        # 刷新配置
        /actuator/busenv

        # 刷新配置，指定服务名
        /actuator/busenv/<spring.application.name>

        # 刷新配置，指定服务名、服务端口号
        /actuator/busenv/<spring.application.name>:<server.port>
