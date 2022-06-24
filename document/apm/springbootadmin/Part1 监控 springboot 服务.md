
# spring boot admin 监控 springboot 服务

### 创建 spring boot admin server 应用

    引入如下 maven 依赖：

        <!-- springboot -->
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-web</artifactId>
            <exclusions>
                <exclusion>
                    <groupId>org.springframework.boot</groupId>
                    <artifactId>spring-boot-starter-tomcat</artifactId>
                </exclusion>
            </exclusions>
        </dependency>
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-jetty</artifactId>
        </dependency>
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-security</artifactId>
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

    添加如下配置到 application.yml ：

        server:
          port: 18888

        spring:
          application:
            name: spring-boot-admin-server
          security:
            user:
              name: "admin"
              password: "123456"

    创建启动类，以下为示例代码：

        @SpringBootApplication
        @ComponentScan(basePackageClasses=BootAdminServerStarter.class)
        @EnableAdminServer
        public class SpringBootAdminStarter {

            public static void main(String[] args) {
                SpringApplication.run(ActuatorServerStarter.class, args);
            }

        }

    鉴权、监控接口转换配置，以下为示例代码：

        @Configuration
        public class BootAdminConfiguration {

            @Autowired
            private AdminServerProperties properties;

            /**
             * 权限信息配置
             */
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

            /**
             * 应用配置了根路径会导致 springbootadmin 读取监控信息错误，从服务注册信息 metadata 中读取 context-path，添加到 actuator 根路径
             */
            @Bean
            public BeanPostProcessor serviceInstanceBeanPostProcessor() {
                return new BeanPostProcessor() {
                    @Override
                    public Object postProcessAfterInitialization(Object bean, String beanName) throws BeansException {
                        if(bean instanceof ServiceInstanceConverter) {
                            BiFunction<URI, String, URI> rebuildUriFn = (httpUri, contextPath) -> {
                                UriBuilder builder = UriComponentsBuilder.fromUri(httpUri);
                                builder.replacePath("/");
                                builder.path(contextPath);
                                builder.path(httpUri.getPath());
                                return builder.build();
                            };
                            return new ServiceInstanceConverter() {
                                @Override
                                public Registration convert(ServiceInstance instance) {
                                    Registration registration = ((ServiceInstanceConverter)bean).convert(instance);
                                    String contextPath = Optional.ofNullable(instance.getMetadata()).map(e -> e.get("context-path")).orElse(null);
                                    if(StringUtils.isNotBlank(contextPath)) {
                                        Registration.Builder builder = Registration.builder();
                                        builder.name(registration.getName());
                                        builder.managementUrl(rebuildUriFn.apply(URI.create(registration.getManagementUrl()), contextPath).toString());
                                        builder.healthUrl(rebuildUriFn.apply(URI.create(registration.getHealthUrl()), contextPath).toString());
                                        builder.serviceUrl(rebuildUriFn.apply(URI.create(registration.getServiceUrl()), contextPath).toString());
                                        builder.metadata(registration.getMetadata());
                                        builder.source(registration.getSource());
                                        return builder.build();
                                    }
                                    return registration;
                                }
                            };
                        }
                        return bean;
                    }
                };
            }

        }

    启动应用，访问如下路径即可浏览控制台：

        http://localhost:18888/

        账号 admin 密码 123456

### 创建 spring boot client 应用

    引入如下 maven 依赖：

        <!-- springboot -->
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-actuator</artifactId>
        </dependency>

        <!-- spring boot admin -->
        <dependency>
            <groupId>de.codecentric</groupId>
            <artifactId>spring-boot-admin-client</artifactId>
        </dependency>

    添加如下配置到 application.yml ：

        server:
          port: 8888

        spring:
          application:
            name: mrh-spring-boot-admin-client-boot
          boot:
            admin:
              client:
                url: http://127.0.0.1:18888
                username: "admin"
                password: "123456"
                instance: 
                  prefer-ip: true

        management:
          endpoints:
            jmx:
              exposure:
                include: "*"
            web:
              exposure:
                include: '*'

    启动应用，即可在 spring boot admin server 的后台查看监控信息
