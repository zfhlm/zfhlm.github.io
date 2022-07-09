
# spring cloud stream 生产与消费

### 相关文档

  * 官方文档地址：

        https://docs.spring.io/spring-cloud/docs/current/reference/html/

        https://docs.spring.io/spring-cloud-stream/docs/current/reference/html/spring-cloud-stream.html

        https://docs.spring.io/spring-cloud-stream/docs/current/reference/html/spring-cloud-stream-binder-rabbit.html

        https://docs.spring.io/spring-cloud-stream/docs/current/reference/html/spring-cloud-stream-binder-kafka.html

  * 示例源码地址：

        https://github.com/zfhlm/mrh-example/tree/main/mrh-spring-cloud

### 基础环境

  * 使用 docker 部署依赖环境

        docker run -d -it --name rabbitmq -p 15672:15672 -p 5673:5672 rabbitmq

        docker run -d -e TZ="Asia/Shanghai" -p 2181:2181 -v /data/zookeeper:/data --name zookeeper zookeeper

        docker run -d --name kafka \
            -p 9092:9092  \
            -d -it \
            -e ALLOW_PLAINTEXT_LISTENER=yes \
            -e KAFKA_CFG_ZOOKEEPER_CONNECT=192.168.140.136:2181 \
            -e KAFKA_ADVERTISED_LISTENERS=PLAINTEXT://192.168.140.136:9092   \
            bitnami/kafka

### 集成与配置

  * 一起接入 rabbitmq 和 kafka，分别定义各自的 消息消费者、生产者

  * 引入 maven 依赖：

        <dependency>
            <groupId>org.springframework.cloud</groupId>
            <artifactId>spring-cloud-starter-stream-rabbit</artifactId>
        </dependency>
        <dependency>
            <groupId>org.springframework.cloud</groupId>
            <artifactId>spring-cloud-starter-stream-kafka</artifactId>
        </dependency>

  * 创建启动类：

        @SpringBootApplication
        @ComponentScan(basePackageClasses=ApplicationStarter.class)
        @EnableDiscoveryClient
        public class ApplicationStarter {

            public static void main(String[] args) {
                SpringApplication.run(ApplicationStarter.class, args);
            }

        }

  * 创建消息体类型：

        public class Person {

            private String name;

            public String getName() {
                return name;
            }

            public void setName(String name) {
                this.name = name;
            }

            public String toString() {
                return this.name;
            }

        }

  * 创建生产者、消费者 function bean：

        // 注意以下 bean 的名称 user-producer user-consumer order-producer order-consumer
        @Configuration
        public class PersonConfiguration {

            @Bean("user-producer")
            public Supplier<Person> userProducer() {
                return () -> {
                    Person person = new Person();
                    person.setName(UUID.randomUUID().toString());
                    return person;
                };
            }

            @Bean("user-consumer")
            public Consumer<Person> userConsumer() {
                return person -> {
                    System.out.println("Received user : " + person);
                };
            }

            @Bean("order-producer")
            public Supplier<Person> orderProducer() {
                return () -> {
                    Person person = new Person();
                    person.setName(UUID.randomUUID().toString());
                    return person;
                };
            }

            @Bean("order-consumer")
            public Consumer<Person> orderConsumer() {
                return person -> {
                    System.out.println("Received order: " + person);
                };
            }

        }

  * 注册 function bean：

        # 关闭自动发现，多个名称以 ; 分隔
        spring:
          cloud:
            function:
              autodetect: false
              definition: user-producer;user-consumer;order-producer;order-consumer

  * 注册 binders、bindings：

        spring:
          cloud:
            stream:
              binders:
                # 第一个 binder，使用 rabbitmq，配置参考 spring boot amqp
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
                # 第二个 binder，使用 kafka，配置参考 spring boot kafka
                kafka-1:
                  type: kafka
                  environment:
                    spring:
                      kafka:
                        bootstrap-servers: 192.168.140.136:9092
              # 名称要与 function bean 一致，固定后缀 -in-0 消费者 -out-0 生产者
              bindings:
                # 第一个 binder 消费者
                user-consumer-in-0:
                  binder: rabbit-1
                  # 相当于 rabbitmq 的 exchange
                  destination: user
                  # 相当于 rabbitmq 的 queue，点对点才配置此值
                  group: mrh
                  content-type: application/json
                # 第一个 binder 生产者
                user-producer-out-0:
                  binder: rabbit-1
                  destination: user
                  group: mrh
                  content-type: application/json
                # 第二个 binder 消费者
                order-consumer-in-0:
                  binder: kafka-1
                  # 相当于 kafka 的 topic
                  destination: order
                  # 相当于 kafka 的 consumer group，点对点才配置此值
                  group: mrh
                  content-type: application/json
                # 第二个 binder 生产者
                order-producer-out-0:
                  binder: kafka-1
                  destination: order
                  group: mrh
                  content-type: application/json

  * 启动应用，可以看到控制台持续输出消息：

        Received user : 4b99b3a0-ef0d-4a33-9c33-2355dad3c7c4
        Received order: b3605430-e5ec-4f8b-918b-792f0a672f24
        Received user : 3bb71989-e936-449c-860f-80b328474fe0
        Received order: 353d685b-57d7-4d19-ad87-e64bfea326d1
        Received user : def39217-c58c-4a45-8d3f-0e5a15a3325f
        Received order: dab6e59a-e72f-42cd-9426-4b365d0bc548
        Received user : 44bc5044-dd87-48e5-aad8-316ffe984955
        Received order: 26d0b504-7249-4c79-8d72-b11d11e020e1
        ...

### 非自动生产消息

  * 使用 spring cloud function Supplier 间隔性生产消息，有时候不符合我们业务情况，这时可以使用手动发送的方式

  * 移除消息生产者 function bean：

        //    @Bean("user-producer")
        //    public Supplier<Person> userProducer() {
        //        return () -> {
        //            Person person = new Person();
        //            person.setName(UUID.randomUUID().toString());
        //            return person;
        //        };
        //    }

        //    @Bean("order-producer")
        //    public Supplier<Person> orderProducer() {
        //        return () -> {
        //            Person person = new Person();
        //            person.setName(UUID.randomUUID().toString());
        //            return person;
        //        };
        //    }

  * 移除消息生产者 function 配置：

        spring:
          cloud:
            function:
              autodetect: false
              # definition: user-producer;user-consumer;order-producer;order-consumer
              definition: user-consumer;order-consumer

  * 创建生产消息的接口：

        // 注意发送的 bindingName 与配置文件对应 user-producer-out-0 和 order-producer-out-0

        @RestController
        public class PersonController {

            @Autowired
            private StreamBridge streamBridge;

            @GetMapping(path="user")
            public String user() {
                Person person = new Person();
                person.setName(UUID.randomUUID().toString());
                streamBridge.send("user-producer-out-0", person);
                return "success";
            }

            @GetMapping(path="order")
            public String order() {
                Person person = new Person();
                person.setName(UUID.randomUUID().toString());
                streamBridge.send("order-producer-out-0", person);
                return "success";
            }

        }

  * 启动应用，访问以下接口：

        http://localhost:8085/user

        http://localhost:8085/order

        -> (可以看到接口产生的消息，被消费后打印到控制台)
