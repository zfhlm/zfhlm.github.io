
# spring cloud 服务监控 springbootadmin

### 相关文档

  * 官方文档地址：

        https://docs.spring.io/spring-cloud/docs/current/reference/html/

        https://codecentric.github.io/spring-boot-admin/current/

  * 示例源码地址：

        https://github.com/zfhlm/mrh-example/tree/main/mrh-spring-cloud

### spring boot admin server

  * 引入如下 maven 依赖：

        <!-- springboot -->
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-web</artifactId>
        </dependency>
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-security</artifactId>
        </dependency>
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-actuator</artifactId>
        </dependency>

        <!-- spring boot admin -->
        <dependency>
            <groupId>de.codecentric</groupId>
            <artifactId>spring-boot-admin-server</artifactId>
        </dependency>
        <dependency>
            <groupId>de.codecentric</groupId>
            <artifactId>spring-boot-admin-server-ui</artifactId>
        </dependency>
        <dependency>
            <groupId>de.codecentric</groupId>
            <artifactId>spring-boot-admin-server-cloud</artifactId>
        </dependency>

        <!-- spring cloud -->
        <dependency>
            <groupId>org.springframework.cloud</groupId>
            <artifactId>spring-cloud-starter-zookeeper-discovery</artifactId>
        </dependency>

  * 添加如下配置到 application.yml ：

        server:
          port: 18888
        spring:
          application:
            name: mrh-spring-cloud-service-bootadmin-server
          # 账号密码验证
          security:
            user:
              name: "admin"
              password: "123456"
          cloud:
            # 注册中心配置
            zookeeper:
              enabled: true
              connect-string: localhost:2181
              prefer-ip-address: true
              max-retries: 10
              max-sleep-ms: 500
              discovery:
                enabled: true
                # 不注册自己
                register: false
                root: /cloud
            # 静态地址可采用如下方式配置
            discovery:
              client:
                simple:
                  instances:
                    mrh-spring-cloud-api-simple:
                    - uri: http://localhost:9529
                    - uri: http://localhost:9530
                    - uri: http://localhost:9531
                    mrh-spring-cloud-api-admin:
                    - uri: http://localhost:9550
                    - uri: http://localhost:9551
                    - uri: http://localhost:9552

  * 创建启动类，以下为示例代码：

        @SpringBootApplication
        @ComponentScan(basePackageClasses=BootAdminServerStarter.class)
        @EnableAdminServer
        public class BootAdminServerStarter {

            public static void main(String[] args) {
                SpringApplication.run(BootAdminServerStarter.class, args);
            }

        }

  * 配置 security 权限信息：

        @Configuration
        public class BootAdminConfiguration {

            @Autowired
            private AdminServerProperties properties;

            @Bean
            public WebSecurityConfigurerAdapter webSecurityConfigurerAdapter() {
                return new WebSecurityConfigurerAdapter() {
                    @Override
                    protected void configure(HttpSecurity http) throws Exception {
                        SavedRequestAwareAuthenticationSuccessHandler successHandler = new SavedRequestAwareAuthenticationSuccessHandler();
                        successHandler.setTargetUrlParameter("redirectTo");
                        http.authorizeRequests()
                            .antMatchers(properties.getContextPath() + "/assets/**").permitAll()
                            .antMatchers(properties.getContextPath() + "/login").permitAll()
                            .anyRequest().authenticated()
                            .and().formLogin().loginPage(properties.getContextPath() + "/login").successHandler(successHandler)
                            .and().logout().logoutUrl(properties.getContextPath() + "/logout")
                            .and().httpBasic()
                            .and().csrf().disable();
                    }

                };
            }

        }

  * 启动应用，访问如下路径即可浏览控制台：

        http://localhost:18888/

        账号 admin 密码 123456

### spring boot admin client

  * 引入 maven 依赖：

        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-actuator</artifactId>
        </dependency>
        <dependency>
            <groupId>org.springframework.cloud</groupId>
            <artifactId>spring-cloud-starter-zookeeper-discovery</artifactId>
        </dependency>

  * 添加如下配置到 application.yml ：

        spring:
          application:
            name: mrh-spring-cloud-service-bootadmin-client
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
            jmx:
              exposure:
                include: "*"
            web:
              exposure:
                include: '*'

  * 启动应用，即可在后台查看监控信息
