
# spring cloud config 配置中心

### 相关文档

  * 官方文档地址：

        https://docs.spring.io/spring-cloud/docs/current/reference/html/

        https://docs.spring.io/spring-cloud-config/docs/current/reference/html/

  * 示例源码地址：

        https://github.com/zfhlm/mrh-example/tree/main/mrh-spring-cloud

### 配置中心服务端

  * 创建 maven 项目，引入以下依赖：

        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-security</artifactId>
        </dependency>
        <dependency>
            <groupId>org.springframework.cloud</groupId>
            <artifactId>spring-cloud-starter-config</artifactId>
        </dependency>
        <dependency>
            <groupId>org.springframework.cloud</groupId>
            <artifactId>spring-cloud-config-server</artifactId>
        </dependency>

  * 添加 application.yml 配置：

        server:
          port: 9500
          servlet:
            context-path: /

        spring:
          application:
            name: mrh-spring-cloud-config
          security:
            user:
              name: root
              password: 123456
          # 开启查找本地文件
          profiles:
            active: native
          # 查找本地文件所在目录，classpath: 或 file:
          cloud:
            config:
              server:
                native:
                  search-locations:
                    - classpath:/config
                    # - file:./config/
                    # - file:/usr/local/application/config
                    # - file:///E:/config

  * 创建启动类：

        @SpringBootApplication
        @EnableConfigServer
        public class ConfigServerStarter {

            public static void main(String[] args) {
                SpringApplication.run(ConfigServerStarter.class, args);
            }

        }

  * 创建配置文件，文件名称格式 {application-name}-{profile}.yml，访问以下路径：

        http://localhost:9500/mrh-spring-cloud-api-admin-dev.yml

### 配置中心客户端

  * 引入 maven 依赖：

        <dependency>
            <groupId>org.springframework.cloud</groupId>
            <artifactId>spring-cloud-starter-config</artifactId>
        </dependency>
        <dependency>
            <groupId>org.springframework.cloud</groupId>
            <artifactId>spring-cloud-starter-bootstrap</artifactId>
        </dependency>

  * 创建 bootstrap.yml 引导配置文件：

        spring:
          application:
            name: mrh-spring-cloud-api-admin
          profiles:
            active: dev
          config:
            import: configserver:http://localhost:9500
          cloud:
            config:
              username: root
              password: 123456
