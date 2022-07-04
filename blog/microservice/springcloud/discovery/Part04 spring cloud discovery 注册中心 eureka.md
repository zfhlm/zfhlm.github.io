
# spring cloud discovery 注册中心 eureka

### 相关文档

  * 官方文档地址：

        https://docs.spring.io/spring-cloud/docs/current/reference/html/

        https://spring-cloud-alibaba-group.github.io/github-pages/2021/en-us/index.html#_spring_cloud_alibaba_nacos_discovery

  * 示例源码地址：

        https://github.com/zfhlm/mrh-example/tree/main/mrh-spring-cloud

### 注册中心服务端

  * 创建 maven 项目引入依赖：

        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-security</artifactId>
        </dependency>
        <dependency>
            <groupId>org.springframework.cloud</groupId>
            <artifactId>spring-cloud-starter-netflix-eureka-server</artifactId>
        </dependency>

  * 创建 application-server1.yml 配置文件：

        server:
          port: 8060
          servlet:
            context-path: /

        spring:
          application:
            name: mrh-spring-cloud-service-eureka-server
          security:
            user:
              name: root
              password: 123456

        eureka:
          instance:
            prefer-ip-address: true
            lease-renewal-interval-in-seconds: 5
            lease-expiration-duration-in-seconds: 15
          server:
            enable-self-preservation: true
            response-cache-auto-expiration-in-seconds: 60
            eviction-interval-timer-in-ms: 10000
          client:
            register-with-eureka: true
            fetch-registry: true
            service-url:
              defaultZone: http://${spring.security.user.name}:${spring.security.user.password}@localhost:8061/eureka

        management:
          endpoints:
            web:
              exposure:
                include: "*"

  * 创建 application-server2.yml 配置文件：

        server:
          port: 8061
          servlet:
            context-path: /

        spring:
          application:
            name: mrh-spring-cloud-service-eureka-server
          security:
            user:
              name: root
              password: 123456

        eureka:
          instance:
            prefer-ip-address: true
            lease-renewal-interval-in-seconds: 5
            lease-expiration-duration-in-seconds: 15
          server:
            enable-self-preservation: true
            response-cache-auto-expiration-in-seconds: 60
            eviction-interval-timer-in-ms: 10000
          client:
            register-with-eureka: true
            fetch-registry: true
            service-url:
              defaultZone: http://${spring.security.user.name}:${spring.security.user.password}@localhost:8062/eureka

        management:
          endpoints:
            web:
              exposure:
                include: "*"

  * 创建 application-server3.yml 配置文件：

        server:
          port: 8062
          servlet:
            context-path: /

        spring:
          application:
            name: mrh-spring-cloud-service-eureka-server
          security:
            user:
              name: root
              password: 123456

        eureka:
          instance:
            prefer-ip-address: true
            lease-renewal-interval-in-seconds: 5
            lease-expiration-duration-in-seconds: 15
          server:
            enable-self-preservation: true
            response-cache-auto-expiration-in-seconds: 60
            eviction-interval-timer-in-ms: 10000
          client:
            register-with-eureka: true
            fetch-registry: true
            service-url:
              defaultZone: http://${spring.security.user.name}:${spring.security.user.password}@localhost:8060/eureka

        management:
          endpoints:
            web:
              exposure:
                include: "*"

  * 创建启动类：

        @SpringBootApplication
        @ComponentScan(basePackageClasses=EurekaServerStarter.class)
        @EnableEurekaServer
        public class EurekaServerStarter {

            public static void main(String[] args) {
                SpringApplication.run(EurekaServerStarter.class, args);
            }

            @Configuration
            public static class WebSecurityConfig extends WebSecurityConfigurerAdapter {
                @Override
                protected void configure(HttpSecurity http) throws Exception {
                    http.sessionManagement().sessionCreationPolicy(SessionCreationPolicy.NEVER);
                    http.csrf().disable();
                    http.authorizeRequests().anyRequest().authenticated().and().httpBasic();
                }
            }

        }

  * 分别使用以下 VM 参数启动三个服务端实例：

        -Dspring.profiles.active=server1

        -Dspring.profiles.active=server2

        -Dspring.profiles.active=server3

### 注册中心客户端

  * 引入 maven 依赖：

        <dependency>
            <groupId>org.springframework.cloud</groupId>
            <artifactId>spring-cloud-starter-netflix-eureka-client</artifactId>
        </dependency>

  * 添加启动类注解：

        @EnableDiscoveryClient
        @EnableEurekaClient

  * 添加 application.yml 配置：

        eureka:
          instance:
            prefer-ip-address: true
            lease-renewal-interval-in-seconds: 5
            lease-expiration-duration-in-seconds: 15
          client:
            register-with-eureka: true
            fetch-registry: true
            service-url:
              defaultZone: http://root:123456@localhost:8060/eureka,http://root:123456@localhost:8061/eureka,http://root:123456@localhost:8062/eureka
