
# spring boot 监控 spring boot admin

### 相关文档

  * 官方文档地址：

        https://docs.spring.io/spring-boot/docs/current/reference/html/

        https://codecentric.github.io/spring-boot-admin/current/

  * 示例源码地址：

        https://github.com/zfhlm/mrh-example/tree/main/mrh-spring-cloud

### 创建 spring boot admin client 应用

  * 添加 maven 依赖：

        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-actuator</artifactId>
        </dependency>

  * 暴露 actuator 配置：

        server:
          port: 8888
        spring:
          application:
            name: mrh-spring-boot-admin-client
        management:
          endpoints:
            jmx:
              exposure:
                include: "*"
            web:
              exposure:
                include: '*'

### 创建 spring boot admin server 应用

  * 引入如下 maven 依赖：

        <!-- spring boot -->
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-web</artifactId>
        </dependency>
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-security</artifactId>
        </dependency>

        <!-- spring cloud -->
        <dependency>
            <groupId>org.springframework.cloud</groupId>
            <artifactId>spring-cloud-starter-loadbalancer</artifactId>
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

  * 创建启动类：

        @SpringBootApplication
        @ComponentScan(basePackageClasses=BootAdminServerStarter.class)
        @EnableAdminServer
        public class SpringBootAdminStarter {

            public static void main(String[] args) {
                SpringApplication.run(ActuatorServerStarter.class, args);
            }

        }

  * 配置 security 用户名密码验证：

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

  * 添加监控服务配置：

        server:
          port: 18888

        spring:
          application:
            name: mrh-spring-boot-admin-server
          # 用户名密码
          security:
            user:
              name: "admin"
              password: "123456"
          # server 拉取监控信息，不在 client 端作任何 spring boot admin 配置
          cloud:
            discovery:
              client:
                simple:
                  instances:
                    mrh-spring-boot-admin-client:
                    - uri: http://localhost:8888

  * 启动应用，访问如下路径即可浏览控制台：

        http://localhost:18888/

        账号 admin 密码 123456
