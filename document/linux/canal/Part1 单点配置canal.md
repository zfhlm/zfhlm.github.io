
# canal

#### 数据库准备

    打开 binlog ROW 模式，输入命令：

    vi /etc/my.cnf

    =>

      [mysqld]
      server_id=1
      log-bin=mysql-bin
      binlog-format=ROW

    创建主从账号，输入命令：

        mysql -uroot -p123456

        # 全部数据库
        GRANT SELECT, REPLICATION SLAVE, REPLICATION CLIENT ON *.* TO 'canal'@'%' IDENTIFIED BY 'canal';

        # 指定数据库
        # GRANT SELECT, REPLICATION SLAVE, REPLICATION CLIENT ON test.* TO 'canal'@'%' IDENTIFIED BY 'canal';

        FLUSH PRIVILEGES;

        exit

#### 安装 canal

    下载安装包，输入命令：

        cd /usr/local/software

        wget -O canal.deployer-1.1.5.tar.gz https://github.com/alibaba/canal/releases/download/canal-1.1.5/canal.deployer-1.1.5.tar.gz

        mkdir canal && tar -zxvf ./canal.deployer-1.1.5.tar.gz  -C ./canal

        cp ./canal -r /usr/local/canal

    修改配置，输入命令：

        cd /usr/local/canal

        vi conf/example/instance.properties

        =>

          canal.instance.mysql.slaveId=100
          canal.instance.master.address = 192.168.140.210:3306

    启动 canal，输入命令：

        sh bin/startup.sh

        tail -f logs/canal/canal.log

        tail -f logs/example/example.log

    停止 canal，输入命令：

        sh ./bin/stop.sh

#### 配置文件

    配置文件目录结构(实际使用中一般只需更改全局配置、实例配置、日志配置):

        ll /usr/local/canal/conf

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

#### 自定义实例配置

    配置两个实例 db1、db2，并删除默认实例 example

    创建实例配置：

        cd /usr/local/canal/conf

        cp ./example -r ./db1

        cp ./example -r ./db2

        rm -rf ./example

    修改两个实例配置文件：

        vi ./db1/instance.properties

        vi ./db2/instance.properties

        # 配置信息自定义
        # ...

    配置实例信息：

        vi canal.properties

        => 修改以下配置：

          # canal.destinations = example
          canal.destinations = db1,db2

    至此完成配置
