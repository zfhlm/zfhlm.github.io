
# prometheus 集成 springboot 应用

### 创建 springboot 应用

    maven 配置：

        <dependency>
        	<groupId>org.springframework.boot</groupId>
        	<artifactId>spring-boot-starter-actuator</artifactId>
        </dependency>
        <dependency>
        	<groupId>io.micrometer</groupId>
        	<artifactId>micrometer-registry-prometheus</artifactId>
        </dependency>

    application.yml 配置：

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

    启动 springboot 应用，输入命令：

        cd /usr/local/app/

        nohup java -jar application.jar &

### 集成到 prometheus

    修改 prometheus 配置文件，输入命令：

        cd /usr/local/prometheus

        vi prometheus.yml

        =>

            scrape_configs:
              - job_name: "springboot-prometheus"
                metrics_path: /actuator/prometheus
                scheme: http
                static_configs:
                  - targets: ["192.168.140.130:8888"]
                    labels:
                      cluster: mrh-cluster
                      service: springboot-prometheus

    重启 prometheus 进程，即完成所有配置
