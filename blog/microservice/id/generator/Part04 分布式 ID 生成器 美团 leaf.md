
# 分布式 ID 生成器 美团 leaf

  * 简单介绍

        美团开源项目，提供两种生成 ID 的方式（号段模式、snowflake 模式）

  * 官方文档地址：

        https://github.com/Meituan-Dianping/Leaf/blob/master/README_CN.md

  * 示例源码地址：

        https://github.com/zfhlm/mrh-example/tree/main/mrh-spring-boot

### leaf-server 服务

  * 下载源码并打包

        git clone https://github.com/Meituan-Dianping/Leaf.git

        cd Leaf

        mvn clean install -DskipTests

        # cp leaf-server/target/leaf.jar ./

  * 更改 leaf.jar!/BOOT-INF/classes/leaf.properties 配置：

        leaf.name=mrh.cluster.leaf

        leaf.segment.enable=true
        leaf.jdbc.url=jdbc:mysql://192.168.140.130:3306/leaf?useSSL=false
        leaf.jdbc.username=root
        leaf.jdbc.password=123456

        leaf.snowflake.enable=true
        leaf.snowflake.zk.address=192.168.140.130
        leaf.snowflake.port=2181

  * 创建数据库：

        CREATE DATABASE leaf;
        CREATE TABLE `leaf_alloc` (
            `biz_tag` varchar(128)  NOT NULL DEFAULT '', -- your biz unique name
            `max_id` bigint(20) NOT NULL DEFAULT '1',
            `step` int(11) NOT NULL,
            `description` varchar(256)  DEFAULT NULL,
            `update_time` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
            PRIMARY KEY (`biz_tag`)
        ) ENGINE=InnoDB;

        -- 注意 biz_tag 用于请求接口的参数
        -- 多个 biz_tag 插入多条记录
        insert into leaf_alloc(biz_tag, max_id, step, description) values('mrh-cluster', 1, 2000, 'Test leaf Segment Mode Get Id');
        insert into leaf_alloc(biz_tag, max_id, step, description) values('mrh-spring-boot-id-generator-leaf', 1, 2000, 'Test leaf Segment Mode Get Id');

  * 启动 leaf 服务：

        nohup java -jar leaf.jar &

  * 请求以下地址获取 ID：

        http://192.168.140.130:8080/api/segment/get/mrh-cluster

        http://192.168.140.130:8080/api/snowflake/get/mrh-cluster

### 客户端服务

  * 创建生成器接口：

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

  * 创建 leaf 相关配置类：

        /**
         * leaf 接口配置
         *
         * @author hlm
         */
        public class LeafServerProperties {

            private String snowflakeUrl;

            private String segmentUrl;

            public String getSnowflakeUrl() {
                return snowflakeUrl;
            }

            public void setSnowflakeUrl(String snowflakeUrl) {
                this.snowflakeUrl = snowflakeUrl;
            }

            public String getSegmentUrl() {
                return segmentUrl;
            }

            public void setSegmentUrl(String segmentUrl) {
                this.segmentUrl = segmentUrl;
            }

        }

        /**
         * leaf 配置
         *
         * @author hlm
         */
        @Configuration
        public class LeafConfiguration {

            @Bean
            public RestTemplate restTemplate() {
                return new RestTemplate();
            }

            @Bean
            @ConfigurationProperties("leaf")
            public LeafServerProperties leafServerProperties() {
                return new LeafServerProperties();
            }

            @Bean("snowflakeIdGenerator")
            public IdGenerator<Long> snowflakeIdGenerator(RestTemplate restTemplate, LeafServerProperties properties) {
                return () -> restTemplate.getForObject(properties.getSnowflakeUrl(), Long.class);
            }

            @Bean("segmentIdGenerator")
            public IdGenerator<Long> segmentIdGenerator(RestTemplate restTemplate, LeafServerProperties properties) {
                return () -> restTemplate.getForObject(properties.getSegmentUrl(), Long.class);
            }

        }

  * 添加 application.yml 配置：

        server:
          port: 8888
          servlet:
            context-path: /
            session.timeout: 0

        spring:
          application:
            name: mrh-spring-boot-id-generator-leaf

        leaf:
          url: http://192.168.140.130:8080/api
          snowflake-Url: ${leaf.url}/snowflake/get/${spring.application.name}
          segment-Url: ${leaf.url}/segment/get/${spring.application.name}

  * 创建测试接口：

        /**
         * 测试接口
         *
         * @author hlm
         */
        @RestController
        public class TestController {

            @Autowired
            @Qualifier("snowflakeIdGenerator")
            private IdGenerator<Long> snowflakeIdGenerator;

            @Autowired
            @Qualifier("segmentIdGenerator")
            private IdGenerator<Long> segmentIdGenerator;

            @RequestMapping(path="snowflake")
            public Long snowflake() {
                return snowflakeIdGenerator.generate();
            }

            @RequestMapping(path="segment")
            public Long segment() {
                return segmentIdGenerator.generate();
            }

        }

  * 请求以下地址发起测试：

        http://localhost:8888/snowflake

        http://localhost:8888/segment
