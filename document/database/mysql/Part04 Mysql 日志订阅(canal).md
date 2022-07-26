
# MySQL 日志订阅(canal)

  * 官方文档：

        https://github.com/alibaba/canal/wiki/ClientExample

        https://github.com/alibaba/canal/wiki/ClientAPI

        https://github.com/alibaba/canal/wiki/ClientAdapter

  * 客户端连接 canal 示例源码：

        https://github.com/zfhlm/mrh-example/tree/main/mrh-spring-boot/mrh-spring-boot-canal-client

### 数据库相关配置

  * 开启 binlog ROW 模式（重要）

  * 数据库创建 canal 使用的主从账号：

        mysql -uroot -p123456

        # 全部数据库
        GRANT SELECT, REPLICATION SLAVE, REPLICATION CLIENT ON *.* TO 'canal'@'%' IDENTIFIED BY 'canal';

        # 指定数据库
        # GRANT SELECT, REPLICATION SLAVE, REPLICATION CLIENT ON test.* TO 'canal'@'%' IDENTIFIED BY 'canal';

        FLUSH PRIVILEGES;

        exit

### 运行 canal 服务

  * 下载安装包，输入命令：

        cd /usr/local/software

        wget -O canal.deployer-1.1.5.tar.gz https://github.com/alibaba/canal/releases/download/canal-1.1.5/canal.deployer-1.1.5.tar.gz

        mkdir canal && tar -zxvf ./canal.deployer-1.1.5.tar.gz  -C ./canal

        cp ./canal -r /usr/local/canal

  * 修改配置，输入命令：

        cd /usr/local/canal

        vi conf/example/instance.properties

        =>

          canal.instance.mysql.slaveId=100
          canal.instance.master.address = 192.168.140.210:3306

  * 启动 canal，输入命令：

        sh bin/startup.sh

        tail -f logs/canal/canal.log

        tail -f logs/example/example.log

  * 停止 canal，输入命令：

        sh ./bin/stop.sh

### 配置 canal 实例

  * 配置文件目录结构(实际使用中一般只需更改全局配置、实例配置、日志配置):

        ll /usr/local/canal/conf

        ->

            +--- canal.properties                   # 全局instance配置
            +
            +--- example                            # example instance实例目录
            +   +
            +   +---- instance.properties           # example instance实例配置
            +
            +--- logback.xml                        # 输出日志配置
            +
            +--- metrics                            # 指标目录
            +   +
            +   +---- Canal_instances_tmpl.json     # 指标数据
            +
            +--- spring                             # 组件配置目录
            +   +
            +   +---- base-instance.xml             # 基础公共组件配置
            +   +
            +   +---- default-instance.xml          # 基于zookeeper组件配置
            +   +
            +   +---- file-instance.xml             # 基于本地文件组件配置(当前版本默认组件，通过命令查看：cat conf/canal.properties  | grep ^canal.instance.global.spring.xml)
            +   +
            +   +---- group-instance.xml            # 基于多库合并组件配置
            +   +
            +   +---- memory-instance.xml           # 基于内存模式组件配置

  * 创建 db1、db2 实例配置，并删除默认实例 example：

        cd /usr/local/canal/conf

        cp ./example -r ./db1

        cp ./example -r ./db2

        rm -rf ./example

  * 修改两个实例配置文件：

        vi ./db1/instance.properties

        vi ./db2/instance.properties

        # 配置信息自定义
        # ...

  * 配置实例信息：

        vi canal.properties

        => 修改以下配置：

          # canal.destinations = example
          canal.destinations = db1,db2

### 配置 canal 集群

  * 服务器地址：

        192.168.140.210

        192.168.140.211

        192.168.140.212

  * 集群依赖 zookeeper 安装：

        (略)

  * 修改三个节点 canal 配置：

        cd /usr/local/canal

        vi conf/canal.properties

        =>

          canal.zkServers=192.168.140.210:2181,192.168.140.211:2181,192.168.140.212:2181
          canal.instance.global.spring.xml = classpath:spring/default-instance.xml

  * 修改三个节点 instance 配置：

        vi canal.properties

        =>

          # 节点一配置
          canal.instance.mysql.slaveId = 210
          canal.instance.master.address = 192.168.140.210:3306

          # 节点二配置
          canal.instance.mysql.slaveId = 211
          canal.instance.master.address = 192.168.140.210:3306

          # 节点三配置
          canal.instance.mysql.slaveId = 212
          canal.instance.master.address = 192.168.140.210:3306

  * 启动集群各个节点，输入命令：

        cd /usr/local/canal

        ./bin/startup.sh
