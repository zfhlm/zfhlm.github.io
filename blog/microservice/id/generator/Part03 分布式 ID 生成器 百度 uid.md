
# 分布式 ID 生成器 百度 uid

  * 简单介绍

        基于 snowflake 算法的唯一 ID 生成器

        最多可支持约 420w 次机器启动，最多可支持约8.7年，内置实现为在启动时由数据库分配，分配策略为用后即弃

        每秒下的并发序列，13 bits可支持每秒 8192 个并发

  * 官方文档地址

        https://github.com/baidu/uid-generator/blob/master/README.md

  * 示例源码地址：

        https://github.com/zfhlm/mrh-example/tree/main/mrh-spring-boot

### 开始集成

  * 引入 maven 依赖：

        <!-- spring boot -->
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-jdbc</artifactId>
        </dependency>

        <!-- apache dbcp2 -->
        <dependency>
            <groupId>org.apache.commons</groupId>
            <artifactId>commons-dbcp2</artifactId>
        </dependency>

        <!-- mysql -->
        <dependency>
            <groupId>mysql</groupId>
            <artifactId>mysql-connector-java</artifactId>
        </dependency>

        <!-- baidu uid -->
        <!-- 下载 uid-generator-master 打包命令 mvn clean package -DskipTests 复制到项目根目录 lib 中 -->
        <dependency>
            <groupId>com.baidu</groupId>
            <artifactId>uid-generator</artifactId>
            <version>${project.version}</version>
            <scope>system</scope>
            <systemPath>${project.basedir}/lib/uid-generator-1.0.0-SNAPSHOT.jar</systemPath>
        </dependency>
        <dependency>
            <groupId>commons-lang</groupId>
            <artifactId>commons-lang</artifactId>
        </dependency>

  * 添加 application.yml 数据库配置：

        spring:
          application:
            name: mrh-spring-boot-id-generator-baidu-uid
          datasource:
            type: org.apache.commons.dbcp2.BasicDataSource
            url: 'jdbc:mysql://192.168.140.130:3306/baidu-uid?useUnicode=true&characterEncoding=UTF-8&serverTimezone=GMT%2B8'
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

  * 创建数据库表：

        CREATE TABLE WORKER_NODE (
            ID BIGINT NOT NULL AUTO_INCREMENT COMMENT 'auto increment id',
            HOST_NAME VARCHAR(64) NOT NULL COMMENT 'host name',
            PORT VARCHAR(64) NOT NULL COMMENT 'port',
            TYPE INT NOT NULL COMMENT 'node type: ACTUAL or CONTAINER',
            LAUNCH_DATE DATE NOT NULL COMMENT 'launch date',
            MODIFIED TIMESTAMP NOT NULL COMMENT 'modified time',
            CREATED TIMESTAMP NOT NULL COMMENT 'created time',
            PRIMARY KEY(ID)
        ) COMMENT='DB WorkerID Assigner for UID Generator',ENGINE = INNODB;

  * 定义 ID 生成器接口：

        /**
         * ID 生成器
         *
         * @author hlm
         * @param <R>
         */
        public interface IdGenerator<R> {

            /**
             * 生成 ID
             *
             * @return
             */
            public R generate();

        }

  * 创建百度 uid 相关配置 bean：

        /**
         * baidu uid 配置
         *
         * @author hlm
         */
        @Configuration
        public class BaiduUidConfiguration {

            // 适配  ID 生成器
            @Bean
            public IdGenerator<Long> idGenerator(CachedUidGenerator generator) {
                return () -> generator.getUID();
            }

            // 自定义持久化，覆盖 uid 自带的 mybatis 实现
            @Bean
            public WorkerNodeDAO workerNodeDAO(JdbcTemplate jdbcTemplate) {
                return new WorkerNodeDAO() {
                    @Override
                    public WorkerNodeEntity getWorkerNodeByHostPort(String host, String port) {
                        String sql = "SELECT ID, HOST_NAME, PORT, TYPE, LAUNCH_DATE, MODIFIED, CREATED FROM WORKER_NODE WHERE HOST_NAME=? AND PORT=?";
                        WorkerNodeEntity e = jdbcTemplate.query(sql, ps -> {
                            ps.setObject(1, host);
                            ps.setObject(2, port);
                        }, rs -> {
                            WorkerNodeEntity entity = new WorkerNodeEntity();
                            entity.setId(rs.getLong("ID"));
                            entity.setHostName(rs.getString("HOST_NAME"));
                            entity.setPort(rs.getString("PORT"));
                            entity.setType(rs.getInt("TYPE"));
                            entity.setLaunchDateDate(rs.getDate("LAUNCH_DATE"));
                            entity.setCreated(rs.getDate("CREATED"));
                            entity.setModified(rs.getDate("MODIFIED"));
                            return entity;
                        });
                        return e;
                    }
                    @Override
                    public void addWorkerNode(WorkerNodeEntity entity) {
                        String sql = "INSERT INTO WORKER_NODE (HOST_NAME, PORT, TYPE, LAUNCH_DATE, MODIFIED, CREATED) VALUES (?, ?, ?, ?, NOW(), NOW())";
                        jdbcTemplate.update(sql, ps -> {
                            ps.setObject(1, entity.getHostName());
                            ps.setObject(2, entity.getPort());
                            ps.setObject(3, entity.getType());
                            ps.setObject(4, entity.getLaunchDate());
                        });
                    }
                };
            }

            @Bean
            public DisposableWorkerIdAssigner disposableWorkerIdAssigner() {
                return new DisposableWorkerIdAssigner();
            }

            @Bean
            public CachedUidGenerator cachedUidGenerator(DisposableWorkerIdAssigner workerIdAssigner) {
                CachedUidGenerator uidGenerator = new CachedUidGenerator();
                uidGenerator.setWorkerIdAssigner(workerIdAssigner);
                uidGenerator.setTimeBits(29);
                uidGenerator.setWorkerBits(21);
                uidGenerator.setSeqBits(13);
                uidGenerator.setEpochStr("2022-01-01");
                return uidGenerator;
            }

        }

  * 创建用于测试的接口：

        /**
         * 测试接口
         *
         * @author hlm
         */
        @RestController
        public class TestController {

            @Autowired
            private IdGenerator<Long> idGenerator;

            @RequestMapping(path="welcome")
            public Long welcome() {
                return idGenerator.generate();
            }

        }
