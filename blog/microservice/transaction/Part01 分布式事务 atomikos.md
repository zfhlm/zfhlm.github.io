
# 分布式事务 atomikos

  * 简单介绍

        atomikos 基于 XA 协议的事务管理器，所以必须使用 XA 数据库数据源，例如 MysqlXADataSource、DruidXADataSource

        atomikos 不能跨应用管理 XA 事务，存在单点故障，而且使用 XA 数据源，对整体性能影响较大，不适合高并发场景使用

        atomikos 保持数据强一致性，不会发生数据脏读问题

  * 官方文档地址：

        https://docs.spring.io/spring-boot/docs/current/reference/htmlsingle/#io.jta.atomikos

  * 示例源码地址：

        https://github.com/zfhlm/mrh-example/tree/main/mrh-spring-boot

### 实现方式

  * 引入 maven 依赖：

        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-jdbc</artifactId>
        </dependency>
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-jta-atomikos</artifactId>
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
            <groupId>com.alibaba</groupId>
            <artifactId>druid</artifactId>
        </dependency>

  * 添加 mybatis 持久化接口：

        org/lushen/mrh/boot/transaction/atomikos/dao/integral/mapper/TIntegralMapper.java

        org/lushen/mrh/boot/transaction/atomikos/dao/integral/mapping/TIntegralMapper.xml

        org/lushen/mrh/boot/transaction/atomikos/dao/integral/model/TIntegral.java

        org/lushen/mrh/boot/transaction/atomikos/dao/user/mapper/TUserMapper.java

        org/lushen/mrh/boot/transaction/atomikos/dao/user/mapping/TUserMapper.xml

        org/lushen/mrh/boot/transaction/atomikos/dao/user/model/TUser.java

  * 添加 application.yml 相关配置：

        spring:
          application:
            name: mrh-spring-boot-transaction-atomikos
          datasource:
            user:
              url: 'jdbc:mysql://192.168.140.130:3306/user?useUnicode=true&characterEncoding=UTF-8&serverTimezone=GMT%2B8'
              username: root
              password: 123456
              driver-class-name: com.mysql.cj.jdbc.Driver
              initial-size: 1
              max-active: 50
              min-idle: 1
              max-wait: 100
              pool-prepared-statements: false
              validation-query: 'select 1'
              validation-query-timeout: 1
              test-on-borrow: false
              test-on-return: false
              test-while-idle: true
              keep-alive: false
              time-between-eviction-runs-millis: 5000
              min-evictable-idle-time-millis: 600000
            integral:
              url: 'jdbc:mysql://192.168.140.130:3306/integral?useUnicode=true&characterEncoding=UTF-8&serverTimezone=GMT%2B8'
              username: root
              password: 123456
              driver-class-name: com.mysql.cj.jdbc.Driver
              initial-size: 1
              max-active: 50
              min-idle: 1
              max-wait: 100
              pool-prepared-statements: false
              validation-query: 'select 1'
              validation-query-timeout: 1
              test-on-borrow: false
              test-on-return: false
              test-while-idle: true
              keep-alive: false
              time-between-eviction-runs-millis: 5000
              min-evictable-idle-time-millis: 600000
          jta:
            enabled: true
            log-dir: /usr/local/logs/boot/transaction/atomikos
            transaction-manager-id: ${spring.application.name}-${server.port}
            atomikos:
              properties:
                default-jta-timeout: 5s
                max-timeout: 5s
                max-actives: 100

        mybatis:
          user:
            mapper-locations: classpath:org/lushen/mrh/boot/transaction/atomikos/dao/user/mapping/*.xml
            type-aliases-package: org.lushen.mrh.boot.transaction.atomikos.dao.user.model
            type-handlers-package: org.lushen.mrh.boot.transaction.atomikos.dao.user.handler
          integral:
            mapper-locations: classpath:org/lushen/mrh/boot/transaction/atomikos/dao/integral/mapping/*.xml
            type-aliases-package: org.lushen.mrh.boot.transaction.atomikos.dao.integral.model
            type-handlers-package: org.lushen.mrh.boot.transaction.atomikos.dao.integral.handler

  * 配置 integral 数据源、mybatis 持久层 相关配置：

        @Configuration
        @MapperScan(basePackageClasses=TIntegralMapper.class, sqlSessionFactoryRef=MybatisIntegralConfiguration.INTEGRAL_SQL_SESSION_FACTORY)
        public class MybatisIntegralConfiguration {

            static final String INTEGRAL_SQL_SESSION_FACTORY = "integralSqlSessionFactory";

            @Bean("integralDataSource")
            @ConfigurationProperties("spring.datasource.integral")
            public XADataSource integralDataSource() {
                return new DruidXADataSource();
            }

            @Bean("integralXADataSource")
            public DataSource integralXADataSource(@Qualifier("integralDataSource") XADataSource dataSource) {
                AtomikosDataSourceBean xaDataSource = new AtomikosDataSourceBean();
                xaDataSource.setXaDataSource(dataSource);
                return xaDataSource;
            }

            @Bean("integralMybatisProperties")
            @ConfigurationProperties("mybatis.integral")
            public MybatisProperties integralMybatisProperties() {
                return new MybatisProperties();
            }

            @Bean(INTEGRAL_SQL_SESSION_FACTORY)
            public SqlSessionFactory integralSqlSessionFactory(
                    @Qualifier("integralXADataSource") DataSource dataSource,
                    @Qualifier("integralMybatisProperties") MybatisProperties properties) throws Exception {
                SqlSessionFactoryBean factory = new SqlSessionFactoryBean();
                factory.setDataSource(dataSource);
                factory.setTypeAliasesPackage(properties.getTypeAliasesPackage());
                factory.setTypeHandlersPackage(properties.getTypeHandlersPackage());
                factory.setMapperLocations(properties.resolveMapperLocations());
                return factory.getObject();
            }

        }

  * 配置 user 数据源、mybatis 持久层 相关配置：

        @Configuration
        @MapperScan(basePackageClasses=TUserMapper.class, sqlSessionFactoryRef=MybatisUserConfiguration.USER_SQL_SESSION_FACTORY)
        public class MybatisUserConfiguration {

            static final String USER_SQL_SESSION_FACTORY = "userSqlSessionFactory";

            @Bean("userDataSource")
            @ConfigurationProperties("spring.datasource.user")
            public XADataSource userDataSource() {
                return new DruidXADataSource();
            }

            @Bean("userXADataSource")
            public DataSource userXADataSource(@Qualifier("userDataSource") XADataSource dataSource) {
                AtomikosDataSourceBean xaDataSource = new AtomikosDataSourceBean();
                xaDataSource.setXaDataSource(dataSource);
                return xaDataSource;
            }

            @Bean("userMybatisProperties")
            @ConfigurationProperties("mybatis.user")
            public MybatisProperties userMybatisProperties() {
                return new MybatisProperties();
            }

            @Bean(USER_SQL_SESSION_FACTORY)
            public SqlSessionFactory userSqlSessionFactory(
                    @Qualifier("userXADataSource") DataSource dataSource,
                    @Qualifier("userMybatisProperties") MybatisProperties properties) throws Exception {
                SqlSessionFactoryBean factory = new SqlSessionFactoryBean();
                factory.setDataSource(dataSource);
                factory.setTypeAliasesPackage(properties.getTypeAliasesPackage());
                factory.setTypeHandlersPackage(properties.getTypeHandlersPackage());
                factory.setMapperLocations(properties.resolveMapperLocations());
                return factory.getObject();
            }

        }

  * 声明式事务配置，遇到所有异常都进行回滚：

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

  * 创建测试相关接口类：

        @Service
        public class TestService {

            @Autowired
            private TUserMapper userMapper;
            @Autowired
            private TIntegralMapper integralMapper;

            @Transactional
            public void add() throws Exception {

                // 添加 user
                TUser user = new TUser();
                user.setId(ThreadLocalRandom.current().nextInt(Integer.MAX_VALUE));
                user.setName(UUID.randomUUID().toString());
                userMapper.insert(user);

                // 添加 integral
                TIntegral integral = new TIntegral();
                integral.setId(ThreadLocalRandom.current().nextInt(Integer.MAX_VALUE));
                integral.setName(UUID.randomUUID().toString());
                integralMapper.insert(integral);

                // 随机数模拟异常
                if(ThreadLocalRandom.current().nextInt(Integer.MAX_VALUE)%2 == 0) {
                    throw new Exception("test");
                }

            }

            public void query() {

                userMapper.selects().forEach(System.out::println);

                integralMapper.selects().forEach(System.out::println);

            }

        }

        @RestController
        public class TestController {

            @Autowired
            private TestService testService;

            @GetMapping(path="query")
            public void query() {
                testService.query();
            }

            @GetMapping(path="add")
            public void add() throws Exception {
                testService.add();
            }

        }

  * 访问以下地址发起测试：

        http://localhost:8888/add

        http://localhost:8888/query
