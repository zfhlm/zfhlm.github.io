
# spring boot 监控 prometheus

### 相关文档

  * 官方文档地址：

        https://docs.spring.io/spring-boot/docs/current/reference/html/

        https://prometheus.io/docs/introduction/overview/

  * 示例源码地址：

        https://github.com/zfhlm/mrh-example/tree/main/mrh-spring-cloud

### 集成步骤

  * 添加 maven 依赖：

        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-actuator</artifactId>
        </dependency>
        <dependency>
            <groupId>io.micrometer</groupId>
            <artifactId>micrometer-registry-prometheus</artifactId>
        </dependency>

  * 添加 application.yml 配置，暴露 actuator 接口：

        server:
          port: 8888
        management:
           endpoints:
              jmx:
                 exposure:
                    include: "*"
              web:
                 exposure:
                    include: '*'

  * 添加 prometheus 抓取配置：

        scrape_configs:
          - job_name: "springboot-prometheus"
            metrics_path: /actuator/prometheus
            scheme: http
            static_configs:
              - targets: ["192.168.140.130:8888"]
                labels:
                  cluster: mrh-cluster
                  service: springboot-prometheus
