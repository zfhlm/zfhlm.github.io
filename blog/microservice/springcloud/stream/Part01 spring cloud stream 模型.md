
# spring cloud stream 模型

### 相关文档

  * 官方文档地址：

        https://docs.spring.io/spring-cloud/docs/current/reference/html/

        https://docs.spring.io/spring-cloud-stream/docs/current/reference/html/spring-cloud-stream.html

  * 示例源码地址：

        https://github.com/zfhlm/mrh-example/tree/main/mrh-spring-cloud

### 配置介绍

  * spring cloud stream 概念：

        Binder                                  # 绑定层，封装了不同 MQ 的对接实现，对应用提供统一的访问出入口

        Inputs                                  # Binder 输入

        Outputs                                 # Binder 输出

        ---------------                      ---------------            -----------------
        |             |                      |             |            |               |
        |             |  <---- inputs -----  |             |----------->|   rabbitmq    |
        |             |                      |             |            |               |
        | application |                      |   binders   |            |   kafka       |
        |             |                      |             |            |               |
        |             |  ---- outputs ---->  |             |<-----------|   ......      |
        |             |                      |             |            |               |
        ---------------                      ---------------            -----------------

  * spring cloud stream 主要配置分支：

        spring.cloud.function                   # 最新版本(当前使用的 cloud 2021.0.3) function 用于定义消息的生产者、消费者

        spring.cloud.stream.binders             # 定义绑定层绑定的消息队列(一到多个)，可以有不同的实现，例如绑定 rabbitmq、kafka

        spring.cloud.stream.bindings            # 定义基于哪个绑定层进行消息的消费、生产(一到多个)

        spring.cloud.stream.rabbit              # 绑定层 rabbitmq 差异化配置

        spring.cloud.stream.kafka               # 绑定层 kafka 差异化配置

  * 存在的问题：

        配置方式比较割裂和繁琐

        等待官方继续完善，建议还是使用 spring boot starter 的方式去集成，差异化使用接口抽离
