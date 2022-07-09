
# spring cloud stream 重试与确认机制

### 相关文档

  * 官方文档地址：

        https://docs.spring.io/spring-cloud/docs/current/reference/html/

        https://docs.spring.io/spring-cloud-stream/docs/current/reference/html/spring-cloud-stream.html

        https://docs.spring.io/spring-cloud-stream/docs/current/reference/html/spring-cloud-stream-binder-rabbit.html

        https://docs.spring.io/spring-cloud-stream/docs/current/reference/html/spring-cloud-stream-binder-kafka.html

  * 示例源码地址：

        https://github.com/zfhlm/mrh-example/tree/main/mrh-spring-cloud

### 消费者失败重试

  * 直接在 binding 上配置，添加 application.yml 配置：

        spring:
          cloud:
            stream:
              bindings:
                <consumer-name>:
                  consumer:
                    # 启动时初始化
                    auto-startup: true
                    # 并大处理数
                    concurrency: 1
                    # 失败重试次数，等于 1 不重试，即失败重试 n-1 次
                    max-attempts: 3
                    # 失败重试时间间隔
                    back-off-initial-interval: 1000
                    # 失败重试最大时间间隔
                    back-off-max-interval: 10000
                    # 失败重试间隔每次增加几倍
                    back-off-multiplier: 2.0
                    # 未在指定列表的异常，是否都进行重试
                    default-retryable: true
                    # 指定异常是否重试，重试 true 不重试 false
                    retryable-exceptions:
                      java.lang.NullPointerException: true
                      java.lang.IllegalArgumentException: true

### 生产者确认机制

  * 依赖于消息中间件自身配置，比较割裂：

        spring:
          cloud:
            stream:
              binders:
                rabbit-1:
                  type: rabbit
                  environment:
                    spring:
                      rabbitmq:
                        host: 192.168.140.136
                        port: 5673
                        username: rabbitmq
                        password: 123456
                        virtual-host: /
                        publisher-returns: true
                        publisher-confirm-type: CORRELATED
                kafka-1:
                  type: kafka
                  environment:
                    spring:
                      kafka:
                        bootstrap-servers: 192.168.140.136:9092
                        producer:
                          acks: 1

  * 如果使用的是 kafka，partition 分区数配置：

        spring:
          cloud:
            stream:
              bindings:
                order-producer-out-0:
                  binder: kafka-1
                  destination: order
                  content-type: application/json
                  group: mrh
                  producer:
                    partition-count: 2
