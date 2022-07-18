
# 分布式事务 seata TCC模式

  * 简单介绍

        TCC 模式，不依赖于底层数据资源的事务支持：

            一阶段 prepare 行为：调用 自定义 的 prepare 逻辑。

            二阶段 commit 行为：调用 自定义 的 commit 逻辑。

            二阶段 rollback 行为：调用 自定义 的 rollback 逻辑。

  * 官方文档地址：

        https://seata.io/zh-cn/docs/overview/what-is-seata.html

        https://github.com/seata/seata/blob/develop/script/client/tcc/db/mysql.sql

  * 示例源码地址：

        https://github.com/zfhlm/mrh-example/tree/main/mrh-spring-boot

### 服务配置

  * 创建两个 spring boot 服务：

        mrh-spring-boot-transaction-seata-tcc-integral

        mrh-spring-boot-transaction-seata-tcc-user

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
            name: mrh-spring-boot-transaction-seata-tcc-integral
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
          application-id: mrh-seata-tcc-integral
          tx-service-group: default_tx_group
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
            name: mrh-spring-boot-transaction-seata-tcc-user
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
          application-id: mrh-seata-tcc-user
          tx-service-group: default_tx_group
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

  * 两个服务，数据库创建用于自动处理 空回滚、防悬挂 的日志表：

        -- -------------------------------- The script use tcc fence  --------------------------------
        CREATE TABLE IF NOT EXISTS `tcc_fence_log`
        (
            `xid`           VARCHAR(128)  NOT NULL COMMENT 'global id',
            `branch_id`     BIGINT        NOT NULL COMMENT 'branch id',
            `action_name`   VARCHAR(64)   NOT NULL COMMENT 'action name',
            `status`        TINYINT       NOT NULL COMMENT 'status(tried:1;committed:2;rollbacked:3;suspended:4)',
            `gmt_create`    DATETIME(3)   NOT NULL COMMENT 'create time',
            `gmt_modified`  DATETIME(3)   NOT NULL COMMENT 'update time',
            PRIMARY KEY (`xid`, `branch_id`),
            KEY `idx_gmt_modified` (`gmt_modified`),
            KEY `idx_status` (`status`)
        ) ENGINE = InnoDB
        DEFAULT CHARSET = utf8mb4;

### 添加测试接口

  * 创建 integral TCC 声明接口：

        public class TestTccParameter {

            private int id = ThreadLocalRandom.current().nextInt(Integer.MAX_VALUE);

            public int getId() {
                return id;
            }

            public void setId(int id) {
                this.id = id;
            }

            @Override
            public String toString() {
                StringBuilder builder = new StringBuilder();
                builder.append("TestTccParameter [id=");
                builder.append(id);
                builder.append("]");
                return builder.toString();
            }

        }

        @LocalTCC
        public interface TestTccAction {

            // useTCCFence=true 处理空回滚、事务悬挂
            // 注意处理  commitTcc、cancelTcc 幂等问题

            @TwoPhaseBusinessAction(name = "prepareTcc", commitMethod = "commitTcc", rollbackMethod = "cancelTcc", useTCCFence=true)
            public String prepareTcc(@BusinessActionContextParameter(paramName="parameter") TestTccParameter parameter);

            public void commitTcc(BusinessActionContext context);

            public void cancelTcc(BusinessActionContext context);

        }

  * 创建 integral 测试接口：

        //   prepare 一般进行资源锁定，这里测试直接插入数据。
        //
        //  真实开发场景，需要配合业务表进行使用，例如：
        //
        //      数额相关的场景，表中需要新增相关字段，prepare 阶段，进行库存的预扣，commit/cancel 阶段，进行库存实际扣除
        //
        //      简单的入库场景，可以通过预设数据状态，比如正常数据status=1，中间态数据status=2，防止用户看见中间态的数据
        //      在 prepare 阶段新增数据 status=2，执行 commit 时更改 status=1，执行 cancel 时删除数据

        @RestController
        public class TestController implements TestTccAction {

            @Autowired
            private TIntegralMapper integralMapper;

            @Transactional
            @RequestMapping(path="integral")
            @Override
            public String prepareTcc(TestTccParameter parameter) {

                System.err.println(RootContext.getXID());
                System.out.println("prepare :: " + parameter);

                // 本地插入
                TIntegral integral = new TIntegral();
                integral.setId(parameter.getId());
                integral.setName(UUID.randomUUID().toString());
                integralMapper.insert(integral);

                return "success";
            }

            @Override
            public void commitTcc(BusinessActionContext context) {
                TestTccParameter parameter = context.getActionContext("parameter", TestTccParameter.class);
                System.out.println("commit :: " + parameter);
            }

          @Transactional
            @Override
            public void cancelTcc(BusinessActionContext context) {
                TestTccParameter parameter = context.getActionContext("parameter", TestTccParameter.class);
                System.out.println("cancel :: " + parameter);
                integralMapper.deleteByPrimaryKey(parameter.getId());
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

            @GlobalTransactional(rollbackFor=Throwable.class, timeoutMills=500000)
            @Transactional
            @RequestMapping(path="user")
            public String user() {

                System.err.println(RootContext.getXID());

                // 本地插入
                TUser user = new TUser();
                user.setId(ThreadLocalRandom.current().nextInt(Integer.MAX_VALUE));
                user.setName(UUID.randomUUID().toString());
                userMapper.insert(user);

                // 远程调用模拟，带上 XID
                RestTemplate template = new RestTemplate();
                LinkedMultiValueMap<String, String> headers = new LinkedMultiValueMap<>();
                headers.put(RootContext.KEY_XID, Collections.singletonList(RootContext.getXID()));
                template.postForEntity("http://localhost:8888/integral", new HttpEntity<String>(headers), String.class);

                // 查看数据库数据状态
                //try {
                //    Thread.sleep(20000L);
                //} catch (InterruptedException e) {
                //    e.printStackTrace();
                //}

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
