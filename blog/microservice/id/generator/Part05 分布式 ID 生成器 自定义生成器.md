
# 分布式 ID 生成器 自定义生成器

  * 自定义号段 ID 生成器，借鉴了美团 Leaf ID 生成器

        (略)

  * 自定义变种生成器，基于 snowflake 的实现原理，结构和特点：

        +------------------+------------------+------------------+------------------+------------------+
        +      1 bit       +      41 bit      +     10 bit       +      2 bit       +      10 bit      +
        +------------------+------------------+------------------+------------------+------------------+
        +     固定取整     +    毫秒时间戳    +     工作节点     + 时钟回拨滚动次数 +     计数序列号   +
        +------------------+------------------+------------------+------------------+------------------+

        1，支持时长 2^41 毫秒，大约69年 (与 snowflake 一致)

        2，支持 2^10 = 1024 个 workerId (将 snowflake 的两个参数 workerId、dataCenterId 合并为一个参数)

        3，支持自动处理 2^2 - 1 = 3 次时钟回拨（减初始 00 bits，可用 01、10、11 bits） (自定义参数，占用 2 bit)

        4，降低计数序列号为 10 bit，即支持最大每秒 102.4 万个 ID 生成 (比 snowflake 的计数序列号少 2 bit)

  * 项目与源码地址

        https://github.com/zfhlm/mrh-id-generator

        https://github.com/zfhlm/mrh-example/tree/main/mrh-spring-boot

### 集成配置

  * 引入 maven 依赖：

        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-jdbc</artifactId>
        </dependency>

        <!-- apache commons -->
        <dependency>
            <groupId>org.apache.commons</groupId>
            <artifactId>commons-dbcp2</artifactId>
        </dependency>

        <!-- mysql -->
        <dependency>
            <groupId>mysql</groupId>
            <artifactId>mysql-connector-java</artifactId>
        </dependency>

        <!-- https://github.com/zfhlm/mrh-id-generator -->
        <dependency>
            <groupId>org.lushen.mrh</groupId>
            <artifactId>mrh-id-generator</artifactId>
        </dependency>

  * 添加 application.yml 配置：

        server:
          port: 8888
          servlet:
            context-path: /
            session.timeout: 0

        spring:
          application:
            name: mrh-spring-boot-id-generator-revisionid
          datasource:
            type: org.apache.commons.dbcp2.BasicDataSource
            url: 'jdbc:mysql://192.168.140.130:3306/mrh-revision?useUnicode=true&characterEncoding=UTF-8&serverTimezone=GMT%2B8'
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

        revision:
          # 命名空间
          namespace: ${spring.application.name}
          # 每个节点可用时长
          time-to-live: 600s
          # 剩余多少可用时长，加载备用
          remaining-time-to-delay: 30s
          # 开始使用时间，项目一旦上线不可变动
          epoch-date: '2022-01-01'

        segment:
          # 命名空间
          namespace: ${spring.application.name}
          # 每次拉取多少号段
          range: 10000
          # 剩余多少则拉取备用号段
          remaining: 1000

  * 创建 revision 相关配置 bean：

        @Configuration
        public class RevisionConfiguration {

            // 处理配置无法转换 LocalDate
            @Bean
            @ConfigurationPropertiesBinding
            public Converter<String, LocalDate> localDateConverter() {
                return new Converter<String, LocalDate>() {
                    @Override
                    public LocalDate convert(String source) {
                        return LocalDate.parse(source, DateTimeFormatter.ofPattern("yyyy-MM-dd"));
                    }
                };
            }

            @Bean
            @ConfigurationProperties("revision")
            public RevisionProperties revisionProperties() {
                return RevisionProperties.buildDefault();
            }

            @Bean
            public RevisionRepository revisionRepository(DataSource dataSource) {
                return new RevisionMysqlJdbcRepository(dataSource);
            }

            @Bean("revisionIdGenerator")
            public IdGenerator revisionIdGenerator(RevisionRepository repository, RevisionProperties properties) {
                return new RevisionIdGeneratorFactory(repository).create(properties);
            }

        }

  * 创建 segment 相关配置 bean：

        @Configuration
        public class SegmentConfiguration {

            @Bean
            @ConfigurationProperties("segment")
            public SegmentProperties segmentProperties() {
                return SegmentProperties.buildDefault();
            }

            @Bean
            public SegmentRepository segmentRepository(DataSource dataSource) {
                return new SegmentMysqlJdbcRepository(dataSource);
            }

            @Bean("segmentIdGenerator")
            public IdGenerator segmentIdGenerator(SegmentRepository repository, SegmentProperties properties) {
                return new SegmentIdGeneratorFactory(repository).create(properties);
            }

        }

  * 创建数据库表：

        CREATE TABLE `revision_alloc` (
          `namespace` varchar(100) NOT NULL COMMENT '业务命名空间',
          `worker_id` int(4) NOT NULL COMMENT '工作节点ID',
          `last_timestamp` bigint(19) NOT NULL COMMENT '最后被使用的时间戳(毫秒)',
          `create_time` datetime NOT NULL COMMENT '创建时间',
          `modify_time` datetime DEFAULT NULL COMMENT '更新时间',
          PRIMARY KEY (`worker_id`,`namespace`)
        ) ENGINE=InnoDB COMMENT='revisionid 生成器信息存储表';

        CREATE TABLE `segment_alloc` (
          `namespace` varchar(100) NOT NULL COMMENT '命名空间',
          `max_value` bigint(19) NOT NULL COMMENT '最大已使用ID',
          `create_time` datetime NOT NULL COMMENT '创建时间',
          `modify_time` datetime DEFAULT NULL COMMENT '更新时间',
          `version` bigint(19) NOT NULL COMMENT '版本号',
          PRIMARY KEY (`namespace`)
        ) ENGINE=InnoDB COMMENT='号段 ID 生成器信息存储表';

  * 创建用于测试的接口：

        @RestController
        public class TestController {

            @Autowired
            @Qualifier("revisionIdGenerator")
            private IdGenerator revisionIdGenerator;

            @Autowired
            @Qualifier("segmentIdGenerator")
            private IdGenerator segmentIdGenerator;

            @RequestMapping(path="revision")
            public Long revision() {
                return revisionIdGenerator.generate();
            }

            @RequestMapping(path="segment")
            public Long segment() {
                return segmentIdGenerator.generate();
            }

        }
