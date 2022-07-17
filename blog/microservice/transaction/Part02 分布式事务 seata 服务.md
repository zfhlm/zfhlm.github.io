
# 分布式事务 seata 服务

  * 简单介绍：

        Seata 分 TC、TM 和 RM 三个角色，TC（Server端）为单独服务端部署，TM 和 RM（Client端）由业务系统集成。

            TC (Transaction Coordinator) - 事务协调者，维护全局和分支事务的状态，驱动全局事务提交或回滚。

            TM (Transaction Manager) - 事务管理器，定义全局事务的范围：开始全局事务、提交或回滚全局事务。

            RM (Resource Manager) - 资源管理器，管理分支事务处理的资源，与TC交谈以注册分支事务和报告分支事务的状态，并驱动分支事务提交或回滚。

  * 官方文档地址：

        https://seata.io/zh-cn/docs/overview/what-is-seata.html

        https://github.com/seata/seata/releases

        https://github.com/seata/seata/blob/develop/script/server/db/mysql.sql

### seata-server

  * 准备好 nacos 注册中心：

        (略)

  * 更改 seata-server 配置 application.yml：

        seata:
          # 使用本地配置，新版本完全不需要接入 nacos 配置中心
          config:
            type: file
          # 使用 nacos 注册中心，多节点时使用，如果单节点指定为 file 类型即可，不需要再做任何配置
          registry:
            type: nacos
            nacos:
              application: seata-server
              server-addr: 192.168.140.130:8848
              group: DEFAULT_GROUP
              namespace:
              cluster: default
              username: nacos
              password: nacos
          # 使用 mysql 存储相关数据
          store:
            mode: db
            db:
              datasource: druid
              db-type: mysql
              driver-class-name: com.mysql.jdbc.Driver
              url: jdbc:mysql://192.168.140.130:3306/seata?rewriteBatchedStatements=true
              user: root
              password: 123456
              min-conn: 5
              max-conn: 100
              global-table: global_table
              branch-table: branch_table
              lock-table: lock_table
              distributed-lock-table: distributed_lock
              query-limit: 100
              max-wait: 5000

  * 创建 seata-server 使用的数据库表：

        // https://github.com/seata/seata/blob/develop/script/server/db/mysql.sql

        -- -------------------------------- The script used when storeMode is 'db' --------------------------------
        -- the table to store GlobalSession data
        CREATE TABLE IF NOT EXISTS `global_table`
        (
            `xid`                       VARCHAR(128) NOT NULL,
            `transaction_id`            BIGINT,
            `status`                    TINYINT      NOT NULL,
            `application_id`            VARCHAR(32),
            `transaction_service_group` VARCHAR(32),
            `transaction_name`          VARCHAR(128),
            `timeout`                   INT,
            `begin_time`                BIGINT,
            `application_data`          VARCHAR(2000),
            `gmt_create`                DATETIME,
            `gmt_modified`              DATETIME,
            PRIMARY KEY (`xid`),
            KEY `idx_status_gmt_modified` (`status` , `gmt_modified`),
            KEY `idx_transaction_id` (`transaction_id`)
        ) ENGINE = InnoDB
          DEFAULT CHARSET = utf8mb4;

        -- the table to store BranchSession data
        CREATE TABLE IF NOT EXISTS `branch_table`
        (
            `branch_id`         BIGINT       NOT NULL,
            `xid`               VARCHAR(128) NOT NULL,
            `transaction_id`    BIGINT,
            `resource_group_id` VARCHAR(32),
            `resource_id`       VARCHAR(256),
            `branch_type`       VARCHAR(8),
            `status`            TINYINT,
            `client_id`         VARCHAR(64),
            `application_data`  VARCHAR(2000),
            `gmt_create`        DATETIME(6),
            `gmt_modified`      DATETIME(6),
            PRIMARY KEY (`branch_id`),
            KEY `idx_xid` (`xid`)
        ) ENGINE = InnoDB
          DEFAULT CHARSET = utf8mb4;

        -- the table to store lock data
        CREATE TABLE IF NOT EXISTS `lock_table`
        (
            `row_key`        VARCHAR(128) NOT NULL,
            `xid`            VARCHAR(128),
            `transaction_id` BIGINT,
            `branch_id`      BIGINT       NOT NULL,
            `resource_id`    VARCHAR(256),
            `table_name`     VARCHAR(32),
            `pk`             VARCHAR(36),
            `status`         TINYINT      NOT NULL DEFAULT '0' COMMENT '0:locked ,1:rollbacking',
            `gmt_create`     DATETIME,
            `gmt_modified`   DATETIME,
            PRIMARY KEY (`row_key`),
            KEY `idx_status` (`status`),
            KEY `idx_branch_id` (`branch_id`),
            KEY `idx_xid_and_branch_id` (`xid` , `branch_id`)
        ) ENGINE = InnoDB
          DEFAULT CHARSET = utf8mb4;

        CREATE TABLE IF NOT EXISTS `distributed_lock`
        (
            `lock_key`       CHAR(20) NOT NULL,
            `lock_value`     VARCHAR(20) NOT NULL,
            `expire`         BIGINT,
            primary key (`lock_key`)
        ) ENGINE = InnoDB
          DEFAULT CHARSET = utf8mb4;

        INSERT INTO `distributed_lock` (lock_key, lock_value, expire) VALUES ('AsyncCommitting', ' ', 0);
        INSERT INTO `distributed_lock` (lock_key, lock_value, expire) VALUES ('RetryCommitting', ' ', 0);
        INSERT INTO `distributed_lock` (lock_key, lock_value, expire) VALUES ('RetryRollbacking', ' ', 0);
        INSERT INTO `distributed_lock` (lock_key, lock_value, expire) VALUES ('TxTimeoutCheck', ' ', 0);

  * 启动 seata-server,访问以下地址：

        http://192.168.140.130:7091/

        账号 seata 密码 seata
