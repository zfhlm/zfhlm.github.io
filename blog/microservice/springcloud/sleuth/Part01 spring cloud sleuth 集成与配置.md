
# spring cloud sleuth 集成与配置

### 相关文档

  * 官方文档地址：

        https://docs.spring.io/spring-cloud/docs/current/reference/html/

        https://docs.spring.io/spring-cloud-sleuth/docs/current/reference/htmlsingle/spring-cloud-sleuth.html

        https://docs.spring.io/spring-cloud-sleuth/docs/current/reference/htmlsingle/spring-cloud-sleuth.html#common-application-properties

  * 示例源码地址：

        https://github.com/zfhlm/mrh-example/tree/main/mrh-spring-cloud

### 集成与配置

  * 添加 maven 依赖：

        <dependency>
            <groupId>org.springframework.cloud</groupId>
            <artifactId>spring-cloud-starter-sleuth</artifactId>
        </dependency>

  * 更改日志输出规则：

        {% raw %}

        %d{yyyy-MM-dd HH:mm:ss.SSS} %-5level %logger{36} [%equals{%X{traceId}}{}{N/A},%equals{%X{spanId}}{}{N/A}] - %msg%n

        {% endraw %}

  * 添加 application.yml 配置：

        # 关闭采样，只做日志链路
        spring
          sleuth:
            enabled: true
            trace-id128: false
            sampler:
              probability: 0
              rate: 0
              refresh.enabled: false

  * 启动服务，即可看到日志输出 traceId 和 spanId：

        2022-07-07 23:37:14.234 INFO  org.springframework.web.servlet.DispatcherServlet [N/A,N/A] - Completed initialization in 1 ms
        2022-07-07 23:37:14.235 INFO  org.springframework.boot.web.embedded.tomcat.TomcatWebServer [N/A,N/A] - Tomcat started on port(s): 9527 (http) with context path ''
        2022-07-07 23:37:15.831 INFO  org.lushen.mrh.cloud.service.organ.ApplicationStarter [N/A,N/A] - Started ApplicationStarter in 16.217 seconds (JVM running for 17.78)
        2022-07-07 23:37:40.703 INFO  org.lushen.mrh.cloud.service.organ.clients.DepartmentClientImpl [ffccece1d868091d,ffccece1d868091d] - Department [id=1, name=36cda2b5-90f9-42ad-9224-eac8cceb184f, orgId=2]
        2022-07-07 23:37:42.234 INFO  org.lushen.mrh.cloud.service.organ.clients.DepartmentClientImpl [d3c5d0619928c8ec,d3c5d0619928c8ec] - Department [id=1, name=db65ccf5-20ae-4fa2-9c03-4c65167c853d, orgId=1]
        2022-07-07 23:37:42.433 INFO  org.lushen.mrh.cloud.service.organ.clients.DepartmentClientImpl [30431092e697a6e1,30431092e697a6e1] - Department [id=1, name=eb4ac356-8603-4d36-97c5-b0e894ebc5aa, orgId=2]
        2022-07-07 23:37:42.618 INFO  org.lushen.mrh.cloud.service.organ.clients.DepartmentClientImpl [516fadb60a8c3010,516fadb60a8c3010] - Department [id=1, name=0301beaf-9872-4857-9f3b-e9be8604f3f4, orgId=1]
