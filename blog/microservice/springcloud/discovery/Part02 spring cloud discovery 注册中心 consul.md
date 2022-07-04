
# spring cloud discovery 注册中心 consul

### 相关文档

  * 官方文档地址：

        https://docs.spring.io/spring-cloud/docs/current/reference/html/

        https://docs.spring.io/spring-cloud-consul/docs/current/reference/html/#spring-cloud-consul-discovery

  * 示例源码地址：

        https://github.com/zfhlm/mrh-example/tree/main/mrh-spring-cloud

### 注册中心配置

  * 引入 maven 依赖：

        <!-- 必须引入 actuator，用于 consul 健康检查 -->
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-actuator</artifactId>
        </dependency>
        <dependency>
            <groupId>org.springframework.cloud</groupId>
            <artifactId>spring-cloud-starter-consul-discovery</artifactId>
        </dependency>

  * 添加启动类注解：

        @EnableDiscoveryClient

  * 添加 application.yml 配置：

        spring:
          cloud:
            consul:
              enabled: true
              host: 192.168.140.130
              port: 18500
              discovery:
                enabled: true
                register: true
                deregister: true
                fail-fast: true
                prefer-ip-address: true
                register-health-check: true
                health-check-interval: 5s
                health-check-critical-timeout: 30s
                acl-token: d5ab2ee4-ace6-f70f-fd34-2e25e009dfc4
