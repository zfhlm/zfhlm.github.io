
# 分布式事务 rocketmq 事务消息

  * 简单介绍

        使用 rocketmq 发送事务消息，成功写入本地，再写入远程服务

  * 官方文档地址：

        https://docs.spring.io/spring-boot/docs/current/reference/htmlsingle/

  * 示例源码地址：

        https://github.com/zfhlm/mrh-example/tree/main/mrh-spring-boot

### 事务服务

  * 引入 maven 依赖：

        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-jdbc</artifactId>
        </dependency>
        <dependency>
            <groupId>org.mybatis.spring.boot</groupId>
            <artifactId>mybatis-spring-boot-starter</artifactId>
        </dependency>
        <dependency>
            <groupId>mysql</groupId>
            <artifactId>mysql-connector-java</artifactId>
        </dependency>
        <dependency>
            <groupId>org.apache.rocketmq</groupId>
            <artifactId>rocketmq-spring-boot-starter</artifactId>
        </dependency>

  * 创建启动类：

        @SpringBootApplication
        @ComponentScan(basePackageClasses=Application.class)
        @EnableTransactionManagement
        @MapperScan(basePackageClasses=TUserMapper.class)
        public class Application {

            public static void main(String[] args) {
                SpringApplication.run(Application.class, args);
            }

        }

  * 添加 application.yml 配置：

        server:
          port: 8889
          servlet:
            context-path: /
            session.timeout: 0

        spring:
          profiles:
            active: default
          application:
            name: mrh-spring-boot-transaction-rabbitmq-user
          datasource:
            type: org.apache.commons.dbcp2.BasicDataSource
            url: 'jdbc:mysql://192.168.140.130:3306/user?useUnicode=true&characterEncoding=UTF-8&serverTimezone=GMT%2B8'
            username: root
            password: 123456
            driver-class-name: com.mysql.cj.jdbc.Driver
            dbcp2:
              max-active: 1000
              initial-size: 1
              max-idle: 50
              max-wait: 60000
              validation-query: select 1
              test-while-idle: true
              test-on-borrow: false
              time-between-eviction-runs-millis: 60000
              min-evictable-idle-time-millis: 1800000
              remove-abandoned: true
              remove-abandoned-timeout: 180

        rocketmq:
          name-server: 192.168.140.130:9876
          producer:
            group: ${spring.application.name}

        mybatis:
          mapper-locations: classpath:org/lushen/mrh/boot/transaction/rocketmq/dao/mapping/*.xml
          type-aliases-package: org.lushen.mrh.boot.transaction.rocketmq.dao.model
          type-handlers-package: org.lushen.mrh.boot.transaction.rocketmq.dao.handler

  * 创建事务消息实体：

        /**
         * 事务消息实体
         *
         * @author hlm
         */
        public class TestPayload implements Serializable {

            private static final long serialVersionUID = -7688963733232183244L;

            private int id;

            private String name;

            public int getId() {
                return id;
            }

            public void setId(int id) {
                this.id = id;
            }

            public String getName() {
                return name;
            }

            public void setName(String name) {
                this.name = name;
            }

            @Override
            public String toString() {
                StringBuilder builder = new StringBuilder();
                builder.append("TestParameter [id=");
                builder.append(id);
                builder.append(", name=");
                builder.append(name);
                builder.append("]");
                return builder.toString();
            }

        }

  * 创建事务消息发送接口：

        /**
         * 事务消息发送接口
         *
         * @author hlm
         */
        @RestController
        public class TestController {

            @Autowired
            private RocketMQTemplate mqTemplate;

            @RequestMapping(path="publish")
            public String user() throws Exception {

                // 事务消息实体
                TestPayload payload = new TestPayload();
                payload.setId(ThreadLocalRandom.current().nextInt(Integer.MAX_VALUE));
                payload.setName(UUID.randomUUID().toString());

                // 发送事务消息
                Message<TestPayload> message = MessageBuilder.withPayload(payload).setHeader(HttpHeaders.CONTENT_TYPE, MediaType.APPLICATION_JSON_VALUE).build();
                TransactionSendResult result = mqTemplate.sendMessageInTransaction("transaction-dest", message, null);

                // 发送失败
                if(result.getSendStatus() != SendStatus.SEND_OK) {
                    throw new RuntimeException("send fail :: " + result.getSendStatus());
                }

                return "success";
            }

        }

  * 创建事务消息处理监听器：

        /**
         * 事务消息监听器
         *
         * @author hlm
         */
        @RocketMQTransactionListener
        @SuppressWarnings("rawtypes")
        public class TestTransactionListener implements RocketMQLocalTransactionListener {

            private final Log log = LogFactory.getLog(getClass());

            @Autowired
            private ObjectMapper objectMapper;
            @Autowired
            private TestService testService;

            @Override
            public RocketMQLocalTransactionState executeLocalTransaction(Message msg, Object arg) {

                try {

                    TestPayload payload = objectMapper.readValue((byte[])msg.getPayload(), TestPayload.class);

                    log.info("execute transaction :: " + payload);

                    testService.add(payload);

                    return RocketMQLocalTransactionState.COMMIT;

                } catch (Exception e) {

                    log.warn(e.getMessage(), e);

                    return RocketMQLocalTransactionState.ROLLBACK;

                }

            }

            @Override
            public RocketMQLocalTransactionState checkLocalTransaction(Message msg) {

                try {

                    TestPayload payload = objectMapper.readValue((byte[])msg.getPayload(), TestPayload.class);

                    log.info("check transaction :: " + payload);

                    if(testService.check(payload)) {
                        return RocketMQLocalTransactionState.COMMIT;
                    } else {
                        return RocketMQLocalTransactionState.ROLLBACK;
                    }

                } catch (Exception e) {

                    log.warn(e.getMessage(), e);

                    return RocketMQLocalTransactionState.UNKNOWN;

                }
            }

        }

        @Service
        public class TestService {

            private final Log log = LogFactory.getLog(getClass());

            @Autowired
            private TUserMapper userMapper;

            @Transactional
            public void add(TestPayload payload) {

                log.info("Add :: " + payload);

                TUser record = new TUser();
                record.setId(payload.getId());
                record.setName(payload.getName());
                userMapper.insert(record);

                if(ThreadLocalRandom.current().nextInt(10) > 5) {
                    throw new RuntimeException("add fail :: " + payload);
                }

            }

            public boolean check(TestPayload payload) {
                return userMapper.selectByPrimaryKey(payload.getId()) != null;
            }

        }

  * 访问以下地址，发送事务消息：

        http://localhost:8889/publish

### 远程服务

  * 引入 maven 依赖：

        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-jdbc</artifactId>
        </dependency>
        <dependency>
            <groupId>org.mybatis.spring.boot</groupId>
            <artifactId>mybatis-spring-boot-starter</artifactId>
        </dependency>
        <dependency>
            <groupId>mysql</groupId>
            <artifactId>mysql-connector-java</artifactId>
        </dependency>
        <dependency>
            <groupId>org.apache.rocketmq</groupId>
            <artifactId>rocketmq-spring-boot-starter</artifactId>
        </dependency>

  * 添加 application.yml 配置：

        spring:
          profiles:
            active: default
          application:
            name: mrh-spring-boot-transaction-rabbitmq-integral
          datasource:
            type: org.apache.commons.dbcp2.BasicDataSource
            url: 'jdbc:mysql://192.168.140.130:3306/integral?useUnicode=true&characterEncoding=UTF-8&serverTimezone=GMT%2B8'
            username: root
            password: 123456
            driver-class-name: com.mysql.cj.jdbc.Driver
            dbcp2:
              max-active: 1000
              initial-size: 1
              max-idle: 50
              max-wait: 60000
              validation-query: select 1
              test-while-idle: true
              test-on-borrow: false
              time-between-eviction-runs-millis: 60000
              min-evictable-idle-time-millis: 1800000
              remove-abandoned: true
              remove-abandoned-timeout: 180

        rocketmq:
          name-server: 192.168.140.130:9876
          consumer:
            group: ${spring.application.name}

        mybatis:
          mapper-locations: classpath:org/lushen/mrh/boot/transaction/rocketmq/dao/mapping/*.xml
          type-aliases-package: org.lushen.mrh.boot.transaction.rocketmq.dao.model
          type-handlers-package: org.lushen.mrh.boot.transaction.rocketmq.dao.handler

  * 添加消息监听器，至此完成所有配置：

        // 注意，当前未对消息失败重试次数进行配置，默认 1 次处理 + 2 次重试

        /**
         * 消息监听器
         *
         * @author hlm
         */
        @RocketMQMessageListener(consumerGroup="${rocketmq.consumer.group}", topic = "transaction-dest")
        @Component
        public class RocketMqListener implements RocketMQListener<TestPayload> {

            private final Log log = LogFactory.getLog(getClass());

            @Autowired
            private TIntegralMapper integralMapper;

            @Override
            public void onMessage(TestPayload payload) {

                log.info("receive :: " + payload);

                TIntegral record = new TIntegral();
                record.setId(payload.getId());
                record.setName(payload.getName());
                integralMapper.insert(record);

            }

        }
