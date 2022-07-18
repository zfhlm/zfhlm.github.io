
# 分布式事务 rabbitmq 最大努力通知

  * 简单介绍

        使用 rabbitmq 发送消息，异步写入数据到两个服务，当发生失败时重试一定次数，达到最大次数进行回滚或人工处理

  * 官方文档地址：

        https://docs.spring.io/spring-boot/docs/current/reference/htmlsingle/

  * 示例源码地址：

        https://github.com/zfhlm/mrh-example/tree/main/mrh-spring-boot

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

  * 创建启动类：

        @SpringBootApplication
        @ComponentScan(basePackageClasses=Application.class)
        @EnableTransactionManagement
        @MapperScan(basePackageClasses=TIntegralMapper.class)
        public class Application {

            public static void main(String[] args) {
                SpringApplication.run(Application.class, args);
            }

        }

  * 添加 application.yml 配置：

        server:
          port: 8888
          servlet:
            context-path: /
            session.timeout: 0

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

        mybatis:
          mapper-locations: classpath:org/lushen/mrh/boot/transaction/rabbitmq/dao/mapping/*.xml
          type-aliases-package: org.lushen.mrh.boot.transaction.rabbitmq.dao.model
          type-handlers-package: org.lushen.mrh.boot.transaction.rabbitmq.dao.handler

  * 本地事务管理配置 bean:

        @Configuration
        public class TransactionConfiguration {

            @Bean
            public TransactionInterceptor txAdvice(TransactionManager txManager){
                // 事务规则定义，所有异常都进行回滚
                List<RollbackRuleAttribute> rollbackRules = Collections.singletonList(new RollbackRuleAttribute(Throwable.class));
                TransactionAttribute transactionAttribute = new RuleBasedTransactionAttribute(TransactionDefinition.PROPAGATION_REQUIRED, rollbackRules);
                // 初始化事务拦截器
                MatchAlwaysTransactionAttributeSource transactionAttributeSource = new MatchAlwaysTransactionAttributeSource();
                transactionAttributeSource.setTransactionAttribute(transactionAttribute);
                return new TransactionInterceptor(txManager, transactionAttributeSource) ;
            }

            @Bean
            public PointcutAdvisor txPointcutAdvisor(TransactionInterceptor txAdvice){
                DefaultPointcutAdvisor advisor = new DefaultPointcutAdvisor();
                advisor.setAdvice(txAdvice);
                advisor.setPointcut(new Pointcut() {
                    @Override
                    public MethodMatcher getMethodMatcher() {
                        // 数据库事务生效切面，所有包含{@link Transactional}注解的方法
                        return new AnnotationMethodMatcher(Transactional.class);
                    }
                    @Override
                    public ClassFilter getClassFilter() {
                        return ClassFilter.TRUE;
                    }
                });
                return advisor;
            }

        }

  * 创建两个用于测试的接口：

        @RestController
        public class TestController {

            @Autowired
            private TIntegralMapper integralMapper;

            @Transactional
            @RequestMapping(path="add/{id}")
            public String add(@PathVariable(name="id", required=true) Integer id) {

                System.out.println("add :: " + id);

                if(integralMapper.selectByPrimaryKey(id) == null) {
                    TIntegral integral = new TIntegral();
                    integral.setId(id);
                    integral.setName(UUID.randomUUID().toString());
                    integralMapper.insert(integral);
                }

                return "success";
            }

            @Transactional
            @RequestMapping(path="del/{id}")
            public String del(@PathVariable(name="id", required=true) Integer id) {

                integralMapper.deleteByPrimaryKey(id);

                System.out.println("del :: " + id);

                return "success";
            }

        }

### 消息服务

  * 引入 maven 依赖：

        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-jdbc</artifactId>
        </dependency>
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-amqp</artifactId>
        </dependency>
        <dependency>
            <groupId>org.mybatis.spring.boot</groupId>
            <artifactId>mybatis-spring-boot-starter</artifactId>
        </dependency>
        <dependency>
            <groupId>mysql</groupId>
            <artifactId>mysql-connector-java</artifactId>
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
          rabbitmq:
            host: 192.168.140.136
            port: 5673
            username: rabbitmq
            password: 123456
            connection-timeout: 0
            publisher-returns: true
            publisher-confirm-type: CORRELATED
            listener:
              simple:
                default-requeue-rejected: false
                retry:
                  enabled: true
                  # 重试次数
                  max-attempts: 10
                  # 重试初始间隔时间
                  initial-interval: 1000ms
                  # 重试下一次间隔时间翻倍，即 1s 2s 4s 8s 10s 10s ...
                  multiplier: 2
                  # 重试最大间隔时间
                  max-interval: 10000ms

        mybatis:
          mapper-locations: classpath:org/lushen/mrh/boot/transaction/rabbitmq/dao/mapping/*.xml
          type-aliases-package: org.lushen.mrh.boot.transaction.rabbitmq.dao.model
          type-handlers-package: org.lushen.mrh.boot.transaction.rabbitmq.dao.handler

  * 本地事务管理配置 bean:

        @Configuration
        public class TransactionConfiguration {

            @Bean
            public TransactionInterceptor txAdvice(TransactionManager txManager){
                // 事务规则定义，所有异常都进行回滚
                List<RollbackRuleAttribute> rollbackRules = Collections.singletonList(new RollbackRuleAttribute(Throwable.class));
                TransactionAttribute transactionAttribute = new RuleBasedTransactionAttribute(TransactionDefinition.PROPAGATION_REQUIRED, rollbackRules);
                // 初始化事务拦截器
                MatchAlwaysTransactionAttributeSource transactionAttributeSource = new MatchAlwaysTransactionAttributeSource();
                transactionAttributeSource.setTransactionAttribute(transactionAttribute);
                return new TransactionInterceptor(txManager, transactionAttributeSource) ;
            }

            @Bean
            public PointcutAdvisor txPointcutAdvisor(TransactionInterceptor txAdvice){
                DefaultPointcutAdvisor advisor = new DefaultPointcutAdvisor();
                advisor.setAdvice(txAdvice);
                advisor.setPointcut(new Pointcut() {
                    @Override
                    public MethodMatcher getMethodMatcher() {
                        // 数据库事务生效切面，所有包含{@link Transactional}注解的方法
                        return new AnnotationMethodMatcher(Transactional.class);
                    }
                    @Override
                    public ClassFilter getClassFilter() {
                        return ClassFilter.TRUE;
                    }
                });
                return advisor;
            }

        }

  * 创建消息队列相关配置 bean:

        @Configuration
        public class AmqpConfiguration {

            public static final String TRANSACTION_EXCHANGE = "mrh.transaction.exchange";            //任务交换器

            public static final String TRANSACTION_ROUTING = "mrh.transaction.routing.key";            //任务队列路由

            public static final String TRANSACTION_QUEUE = "mrh.transaction.queue";                    //任务队列名称

            public static final String FALLBACK_EXCHANGE = "mrh.transaction.fallback.exchange";        //死信队列交换器

            public static final String FALLBACK_ROUTING = "mrh.transaction.fallback.routing.key";    //死信队列路由

            public static final String FALLBACK_QUEUE = "mrh.transaction.fallback.queue";            //死信队列名称

            /**
             * 注册任务交换器
             */
            @Bean
            public Exchange assignExchange() {
                return ExchangeBuilder.directExchange(TRANSACTION_EXCHANGE).durable(true).build();
            }

            /**
             * 注册任务队列
             */
            @Bean
            public Queue assignQueue() {
                Map<String, Object> args = new HashMap<String, Object>();
                args.put("x-dead-letter-exchange", FALLBACK_EXCHANGE);
                args.put("x-dead-letter-routing-key", FALLBACK_ROUTING);
                return QueueBuilder.durable(TRANSACTION_QUEUE).withArguments(args).build();
            }

            /**
             * 绑定任务队列和交换器
             */
            @Bean
            public Binding assignBinding() {
                return new Binding(TRANSACTION_QUEUE, Binding.DestinationType.QUEUE, TRANSACTION_EXCHANGE, TRANSACTION_ROUTING, null);
            }

            /**
             * 注册死信队列交换器
             */
            @Bean
            public Exchange fallbackExchange() {
                return ExchangeBuilder.directExchange(FALLBACK_EXCHANGE).durable(true).build();
            }

            /**
             * 注册死信队列
             */
            @Bean
            public Queue fallbackQueue() {
                return QueueBuilder.durable(FALLBACK_QUEUE).build();
            }

            /**
             * 绑定死信队列和交换器
             */
            @Bean
            public Binding fallbackBinding() {
                return new Binding(FALLBACK_QUEUE, Binding.DestinationType.QUEUE, FALLBACK_EXCHANGE, FALLBACK_ROUTING, null);
            }

        }

  * 创建消息队列监听器：

        /**
         * 消息参数
         *
         * @author hlm
         */
        public class AmqpParameter implements Serializable {

            private static final long serialVersionUID = -5737962105389578180L;

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
                builder.append("AmqpParameter [id=");
                builder.append(id);
                builder.append(", name=");
                builder.append(name);
                builder.append("]");
                return builder.toString();
            }

        }

        /**
         * 消息监听器
         *
         * @author hlm
         */
        @Component
        @RabbitListener(queues = AmqpConfiguration.TRANSACTION_QUEUE)
        public class AmqpTransactionListener {

            private final Log log = LogFactory.getLog(getClass());

            private final RestTemplate template = new RestTemplate();

            @Autowired
            private TUserMapper userMapper;

            @RabbitHandler
            @Transactional
            public void handle(AmqpParameter parameter) {

                log.info("message :" + parameter);

                log.info("add :: " + parameter.getId());

                // 添加用户
                TUser user = new TUser();
                user.setId(parameter.getId());
                user.setName(parameter.getName());
                userMapper.insert(user);

                // 添加积分
                template.getForEntity("http://localhost:8888/add/"+parameter.getId(), String.class);

                // 模拟错误
                if(ThreadLocalRandom.current().nextInt(20) > 1) {
                    throw new RuntimeException("test");
                }

            }

        }

        /**
         * 死信队列监听器
         */
        @Component
        @RabbitListener(queues=AmqpConfiguration.FALLBACK_QUEUE)
        public class AmqpFallbackListener {

            private final Log log = LogFactory.getLog(getClass());

            private final RestTemplate template = new RestTemplate();

            @Autowired
            private TUserMapper userMapper;

            @RabbitHandler
            @Transactional
            public void handle(AmqpParameter parameter) {

                log.info("fallback message :" + parameter);

                log.info("del :: id = " + parameter.getId());

                // 失败回滚

                userMapper.deleteByPrimaryKey(parameter.getId());

                template.getForEntity("http://localhost:8888/del/"+parameter.getId(), String.class);

            }

        }

  * 创建用于发送测试消息的接口：

        @RestController
        public class TestController {

            @Autowired
            private RabbitTemplate rabbitTemplate;

            @RequestMapping(path="publish")
            public String user() throws Exception {
                AmqpParameter parameter = new AmqpParameter();
                parameter.setId(ThreadLocalRandom.current().nextInt(Integer.MAX_VALUE));
                parameter.setName(UUID.randomUUID().toString());
                rabbitTemplate.convertAndSend(AmqpConfiguration.TRANSACTION_EXCHANGE, AmqpConfiguration.TRANSACTION_ROUTING, parameter);
                return "success";
            }

        }

  * 请求以下地址，发起测试：

        http://localhost:8889/publish
