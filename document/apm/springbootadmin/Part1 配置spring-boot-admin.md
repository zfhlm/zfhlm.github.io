
# 配置 spring-boot-admin

### 创建 spring-boot-admin maven 应用

    引入如下依赖：

        <!-- spring boot -->
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-web</artifactId>
            <exclusions>
                <exclusion>
                    <groupId>org.springframework.boot</groupId>
                    <artifactId>spring-boot-starter-tomcat</artifactId>
                </exclusion>
                <exclusion>
                    <groupId>org.springframework.boot</groupId>
                    <artifactId>spring-boot-starter-logging</artifactId>
                </exclusion>
            </exclusions>
        </dependency>
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-jetty</artifactId>
        </dependency>
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-log4j2</artifactId>
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
            <artifactId>spring-cloud-starter-config</artifactId>
        </dependency>
        <dependency>
            <groupId>org.springframework.cloud</groupId>
            <artifactId>spring-cloud-config-client</artifactId>
        </dependency>
        <dependency>
            <groupId>org.springframework.cloud</groupId>
            <artifactId>spring-cloud-starter-zookeeper-discovery</artifactId>
        </dependency>

    配置文件 application.yml 添加如下配置：

        # server 配置
        server:
          port: 8890
          servlet:
            context-path: /
            session.timeout: 0

        # spring cloud 注册中心
        spring:
          application:
            name: springbootadmin
          cloud:
            zookeeper:
              enabled: true
              connect-string: localhost:2181
              max-retries: 10
              max-sleep-ms: 500
              discovery:
                enabled: true
                register: true
                root: /mrh

        # spring boot actuator 监控配置
        management:
          endpoints:
            web:
              exposure:
                include: '*'

    创建启动类，以下为示例代码：

        @SpringBootApplication
        @EnableAdminServer
        @EnableDiscoveryClient
        public class SpringBootAdminStarter implements BeanPostProcessor {

            public static void main(String[] args) {
                SpringApplication.run(ActuatorServerStarter.class, args);
            }

            // 替换系统注册的服务信息转换器
            @Override
            public Object postProcessAfterInitialization(Object bean, String beanName) throws BeansException {
                if(bean instanceof ServiceInstanceConverter) {
                    return new ContextPathServiceInstanceConverter((ServiceInstanceConverter)bean);
                }
                return bean;
            }

            /**
             * 配置了 context-path 非根路径，无法读取 actuator 接口的问题
             *
             * 服务信息转换器，读取服务注册元信息 context-path 键值，添加到 actuator 根路径
             */
            private class ContextPathServiceInstanceConverter implements ServiceInstanceConverter {

                // 注册中心元信息context-path
                private static final String META_DATA_CONTEXT_PATH = "context-path";

                private ServiceInstanceConverter serviceInstanceConverter;

                public ContextPathServiceInstanceConverter(ServiceInstanceConverter serviceInstanceConverter) {
                    super();
                    this.serviceInstanceConverter = serviceInstanceConverter;
                }

                @Override
                public Registration convert(ServiceInstance instance) {

                    Registration registration = this.serviceInstanceConverter.convert(instance);

                    // 尝试获取context-path
                    String contextPath = Optional.ofNullable(instance.getMetadata()).map(e -> e.get(META_DATA_CONTEXT_PATH)).orElse(null);

                    // 重写服务监控信息，url统一添加context-path前缀
                    if(StringUtils.isNotBlank(contextPath)) {
                        Registration.Builder builder = Registration.builder();
                        builder.name(registration.getName());
                        builder.managementUrl(rebuildHttpUri(URI.create(registration.getManagementUrl()), contextPath).toString());
                        builder.healthUrl(rebuildHttpUri(URI.create(registration.getHealthUrl()), contextPath).toString());
                        builder.serviceUrl(rebuildHttpUri(URI.create(registration.getServiceUrl()), contextPath).toString());
                        builder.metadata(registration.getMetadata());
                        builder.source(registration.getSource());
                        return builder.build();
                    }

                    return registration;
                }

                private URI rebuildHttpUri(URI httpUri, String contextPath) {
                    UriBuilder builder = UriComponentsBuilder.fromUri(httpUri);
                    builder.replacePath("/");
                    builder.path(contextPath);
                    builder.path(httpUri.getPath());
                    return builder.build();
                }

            }

        }

    启动应用，访问如下路径即可浏览控制台：

        http://localhost:8890/
