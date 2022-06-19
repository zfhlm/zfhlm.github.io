
# nacos

    官网地址：https://nacos.io/zh-cn/index.html

#### 安装 nacos

    安装 jdk1.8：

        (略)

    输入命令：

        wget https://github.com/alibaba/nacos/releases/download/2.0.3/nacos-server-2.0.3.tar.gz

        tar -zxvf ./nacos-server-2.0.3.tar.gz

        mv nacos ..

        cd /usr/local/nacos

        ./bin/startup.sh -m standalone

    管理后台地址：

        http://192.168.140.210:8848/nacos/

#### 集群配置

    配置 mysql 数据库：

        新建 database nacos

        导入建表sql：nacos/conf/nacos-mysql.sql

    修改数据库配置：

        cd /usr/local/nacos/conf

        vi application.properties

        =>

            spring.datasource.platform=mysql
            db.num=1
            db.url.0=jdbc:mysql://192.168.140.210:3306/nacos?characterEncoding=utf8&connectTimeout=1000&socketTimeout=3000&autoReconnect=true&useUnicode=true&useSSL=false&serverTimezone=UTC
            db.user.0=root
            db.password.0=123456
            db.pool.config.connectionTimeout=30000
            db.pool.config.validationTimeout=10000
            db.pool.config.maximumPoolSize=20
            db.pool.config.minimumIdle=2

    修改 JVM 内存限制（根据实际资源调整），输入命令：

        cd /usr/local/nacos/bin

        vi startup.sh

        => -Xms512m -Xmx512m -Xmn256m

    输入命令：

        cd /usr/local/nacos/conf

        cp cluster.conf.example cluster.conf

        vi cluster.conf

        =>

            192.168.140.210:8848
            192.168.140.211:8848
            192.168.140.212:8848

        ./bin/startup.sh
