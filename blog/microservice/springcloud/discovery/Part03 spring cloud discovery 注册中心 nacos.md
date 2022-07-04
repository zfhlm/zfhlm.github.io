
# spring cloud discovery 注册中心 nacos

### 相关文档

  * 官方文档地址：

        https://docs.spring.io/spring-cloud/docs/current/reference/html/

        https://spring-cloud-alibaba-group.github.io/github-pages/2021/en-us/index.html#_spring_cloud_alibaba_nacos_discovery

  * 示例源码地址：

        https://github.com/zfhlm/mrh-example/tree/main/mrh-spring-cloud

### 注册中心配置

  * 引入 maven 依赖：

        <dependency>
            <groupId>com.alibaba.cloud</groupId>
            <artifactId>spring-cloud-starter-alibaba-nacos-discovery</artifactId>
        </dependency>

  * 添加启动类注解：

        @EnableDiscoveryClient

  * 添加 application.yml 配置：

        spring:
          application:
            name: mrh-spring-cloud-service-nacos
          cloud:
            nacos:
              discovery:
                register-enabled: true
                server-addr: 192.168.140.210:8848
                username: nacos
                password: nacos
                metadata:
                  cluster: mrh-spring-cloud
                  service: ${spring.application.name}
