
# 分布式事务 seata AT模式

  * 简单介绍

        两阶段提交协议的演变：

            一阶段：业务数据和回滚日志记录在同一个本地事务中提交，释放本地锁和连接资源。

            二阶段：提交异步化，非常快速地完成。回滚通过一阶段的回滚日志进行反向补偿。

  * 官方文档地址：

        https://seata.io/zh-cn/docs/overview/what-is-seata.html

        https://github.com/seata/seata/blob/develop/script/client/at/db/mysql.sql

  * 示例源码地址：

        https://github.com/zfhlm/mrh-example/tree/main/mrh-spring-boot

### 服务配置

  * 创建两个 spring boot 服务：

        mrh-spring-boot-transaction-seata-at-integral

        mrh-spring-boot-transaction-seata-at-user

  * 两个服务，引入 maven 依赖：

        <dependency>
            <groupId>org.mybatis.spring.boot</groupId>
            <artifactId>mybatis-spring-boot-starter</artifactId>
        </dependency>
        <dependency>
            <groupId>mysql</groupId>
            <artifactId>mysql-connector-java</artifactId>
        </dependency>
        <dependency>
            <groupId>org.apache.commons</groupId>
            <artifactId>commons-dbcp2</artifactId>
        </dependency>
        <dependency>
            <groupId>io.seata</groupId>
            <artifactId>seata-spring-boot-starter</artifactId>
        </dependency>
        <dependency>
            <groupId>com.alibaba.nacos</groupId>
            <artifactId>nacos-client</artifactId>
        </dependency>
        <dependency>
            <groupId>com.alibaba.nacos</groupId>
            <artifactId>nacos-api</artifactId>
        </dependency>

  * 服务 integral 使用以下 application.yml 配置：

        spring:
          application:
            name: mrh-spring-boot-transaction-seata-xa-integral
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
          mapper-locations: classpath:org/lushen/mrh/boot/seata/at/dao/mapping/*.xml
          type-aliases-package: org.lushen.mrh.boot.seata.at.dao.model
          type-handlers-package: org.lushen.mrh.boot.seata.at.dao.handler

        seata:
          enabled: true
          # 关闭自动配置代理数据源
          enable-auto-data-source-proxy: false
          application-id: mrh-seata-at-integral
          tx-service-group: default_tx_group
          data-source-proxy-mode: AT
          service:
            vgroup-mapping:
              default_tx_group: default
          client:
            rm-report-retry-count: 5
            rm-async-commit-buffer-limit: 10000
            tm-commit-retry-count: 5
            tm-rollback-retry-count: 20
          registry:
            type: nacos
            nacos:
              server-addr: 192.168.140.130:8848
              application: seata-server
              group: DEFAULT_GROUP
              username: nacos
              password: nacos

  * 服务 user 使用以下 application.yml 配置：

        spring:
          application:
            name: mrh-spring-boot-transaction-seata-xa-user
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

        mybatis:
          mapper-locations: classpath:org/lushen/mrh/boot/seata/at/dao/mapping/*.xml
          type-aliases-package: org.lushen.mrh.boot.seata.at.dao.model
          type-handlers-package: org.lushen.mrh.boot.seata.at.dao.handler

        seata:
          enabled: true
          # 关闭自动配置代理数据源
          enable-auto-data-source-proxy: false
          application-id: mrh-seata-at-user
          tx-service-group: default_tx_group
          data-source-proxy-mode: AT
          service:
            vgroup-mapping:
              default_tx_group: default
          client:
            rm-report-retry-count: 5
            rm-async-commit-buffer-limit: 10000
            tm-commit-retry-count: 5
            tm-rollback-retry-count: 20
          registry:
            type: nacos
            nacos:
              server-addr: 192.168.140.130:8848
              application: seata-server
              group: DEFAULT_GROUP
              username: nacos
              password: nacos

  * 两个服务，配置本地数据源、本地事务管理：

        @Configuration
        public class TransactionConfiguration {

            // 本地数据源
            @Bean
            @ConfigurationProperties("spring.datasource.dbcp2")
            public BasicDataSource basicDataSource(DataSourceProperties properties) {
                return (BasicDataSource) properties.initializeDataSourceBuilder().build();
            }

            // 本地事务管理器
            @Bean
            public DataSourceTransactionManager dataSourceTransactionManager(BasicDataSource dataSource) {
                return new DataSourceTransactionManager(dataSource);
            }

            // 本地事务拦截器
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

            // 本地事务切面
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

  * 两个服务，配置 seata 代理数据源：

        @Configuration
        public class SeataConfiguration {

            // 代理数据源
            @Bean("dataSourceProxy")
            @Primary
            public DataSourceProxy dataSourceProxy(BasicDataSource dataSource) {
                return new DataSourceProxy(dataSource);
            }

        }

  * 两个服务，数据源对应的数据库，创建 seata at 用于回滚的日志表：

        // https://github.com/seata/seata/blob/develop/script/client/at/db/mysql.sql

        -- for AT mode you must to init this sql for you business database. the seata server not need it.
        CREATE TABLE IF NOT EXISTS `undo_log`
        (
            `branch_id`     BIGINT       NOT NULL COMMENT 'branch transaction id',
            `xid`           VARCHAR(128) NOT NULL COMMENT 'global transaction id',
            `context`       VARCHAR(128) NOT NULL COMMENT 'undo_log context,such as serialization',
            `rollback_info` LONGBLOB     NOT NULL COMMENT 'rollback info',
            `log_status`    INT(11)      NOT NULL COMMENT '0:normal status,1:defense status',
            `log_created`   DATETIME(6)  NOT NULL COMMENT 'create datetime',
            `log_modified`  DATETIME(6)  NOT NULL COMMENT 'modify datetime',
            UNIQUE KEY `ux_undo_log` (`xid`, `branch_id`)
        ) ENGINE = InnoDB
          AUTO_INCREMENT = 1
          DEFAULT CHARSET = utf8mb4 COMMENT ='AT transaction mode undo table';

### 添加测试接口

  * 创建 integral 测试接口：

        @RestController
        public class TestController {

            @Autowired
            private TIntegralMapper integralMapper;

            @Transactional
            @RequestMapping(path="integral")
            public String integral() {

                System.err.println(RootContext.getXID());

                // 本地插入
                TIntegral integral = new TIntegral();
                integral.setId(ThreadLocalRandom.current().nextInt(Integer.MAX_VALUE));
                integral.setName(UUID.randomUUID().toString());
                integralMapper.insert(integral);

                // 模拟错误回滚
                if(ThreadLocalRandom.current().nextInt(Integer.MAX_VALUE)%2 == 0) {
                    throw new RuntimeException("test");
                }

                return "success";
            }

        }

  * 创建 integral 拦截器（当前未使用微服务，模拟接收 XID ）：

        @Component
        public class SeataInterceptor implements HandlerInterceptor, WebMvcConfigurer {

            @Override
            public void addInterceptors(InterceptorRegistry registry) {
                registry.addInterceptor(this).addPathPatterns("/**");
            }

            @Override
            public boolean preHandle(HttpServletRequest request, HttpServletResponse response, Object handler) throws Exception {
                Optional.ofNullable(request.getHeader(RootContext.KEY_XID)).ifPresent(value -> {
                    RootContext.bind(value);
                });
                return true;
            }

        }

  * 创建 user 测试接口：

        @RestController
        public class TestController {

            @Autowired
            private TUserMapper userMapper;

            @GlobalTransactional(rollbackFor=Throwable.class, timeoutMills=5000)
            @Transactional
            @RequestMapping(path="user")
            public String user() {

                System.err.println(RootContext.getXID());

                // 本地插入
                TUser user = new TUser();
                user.setId(ThreadLocalRandom.current().nextInt(Integer.MAX_VALUE));
                user.setName(UUID.randomUUID().toString());
                userMapper.insert(user);

                // 远程调用 integral，请求头模拟传递 XID
                LinkedMultiValueMap<String, String> headers = new LinkedMultiValueMap<>();
                headers.put(RootContext.KEY_XID, Collections.singletonList(RootContext.getXID()));
                new RestTemplate().postForEntity("http://localhost:8888/integral", new HttpEntity<String>(headers), String.class);

                // 模拟错误回滚
                if(ThreadLocalRandom.current().nextInt(Integer.MAX_VALUE)%2 == 0) {
                    throw new RuntimeException("test");
                }

                return "success";
            }

        }

  * 访问以下接口：

        # 不会触发 seata 事务管理
        http://localhost:8888/integral

        # 多次刷新，查看分布式事务是否生效
        http://localhost:8889/user

### 关于 @GlobalLock 注解

  * (直接查看官方文档，需要配合业务 SQL for update 使用)
