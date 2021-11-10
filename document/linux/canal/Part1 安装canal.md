
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
