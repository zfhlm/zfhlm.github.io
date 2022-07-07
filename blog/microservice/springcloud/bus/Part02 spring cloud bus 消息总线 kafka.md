
# spring cloud bus 消息总线 kafka

### 相关文档

  * 官方文档地址：

        https://docs.spring.io/spring-cloud/docs/current/reference/html/

        https://docs.spring.io/spring-cloud-bus/docs/current/reference/html/

  * 示例源码地址：

        https://github.com/zfhlm/mrh-example/tree/main/mrh-spring-cloud

### 集成与配置

  * 把 maven 依赖 amqp 换成 kafka 依赖：

        <dependency>
            <groupId>org.springframework.cloud</groupId>
            <artifactId>spring-cloud-starter-bus-kafka</artifactId>
        </dependency>

  * 把 application.yml 配置 rabbitmq 替换为 kafka 配置：

        spring:
          cloud:
            stream:
              kafka:
                binder:
                  brokers: localhost:9092
