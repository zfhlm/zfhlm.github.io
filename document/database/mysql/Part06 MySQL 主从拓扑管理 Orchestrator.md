
# MySQL 主从拓扑管理 Orchestrator

  * 官方文档地址：

        https://github.com/openark/orchestrator

        https://github.com/openark/orchestrator/releases

        https://github.com/openark/orchestrator/releases/download/v3.2.6/orchestrator-3.2.6-linux-amd64.tar.gz

### 安装配置

  * 下载并解压安装包：

        cd /usr/local/software

        wget https://github.com/openark/orchestrator/releases/download/v3.2.6/orchestrator-3.2.6-linux-amd64.tar.gz

        tar -zxvf orchestrator-3.2.6-linux-amd64.tar.gz -C /

  * 本机安装 MySQL 数据库，并创建 Orchestrator 相关数据库、账号信息：

        mysql -uroot -p123456

        CREATE DATABASE IF NOT EXISTS orchestrator;

        CREATE USER 'orchestrator'@'%' IDENTIFIED BY '123456';

        GRANT ALL PRIVILEGES ON `orchestrator`.* TO 'orchestrator'@'%';

        FLUSH PRIVILEGES;

        exit;

  * 更改 Orchestrator 配置文件：

        cd /usr/local/orchestrator/

        cp orchestrator-sample.conf.json /etc/orchestrator.conf.json

        vi /etc/orchestrator.conf.json

        =>

            "MySQLTopologyUser": "orchestrator",            # 被管理数据创建的账号
            "MySQLTopologyPassword": "123456",              # 被管理数据创建的密码
            "MySQLOrchestratorHost": "127.0.0.1",           # 元数据存储数据库 IP
            "MySQLOrchestratorPort": 3306,                  # 元数据存储数据库 端口
            "MySQLOrchestratorDatabase": "orchestrator",    # 元数据存储数据库 实例名称
            "MySQLOrchestratorUser": "orchestrator",        # 元数据存储数据库 账号
            "MySQLOrchestratorPassword": "123456",          # 元数据存储数据库 密码

  * 被管理 MySQL 数据库，创建 Orchestrator 连接账号：

        mysql -uroot -p123456

        CREATE USER 'orchestrator'@'%' IDENTIFIED BY '123456';

        GRANT SUPER, PROCESS, REPLICATION SLAVE, RELOAD ON *.* TO 'orchestrator'@'%';

        GRANT SELECT ON mysql.slave_master_info TO 'orchestrator'@'%';

        FLUSH PRIVILEGES;

        exit;

  * 启动 Orchestrator 服务，输入命令：

        systemctl start orchestrator

        systemctl status orchestrator

        # 查看日志
        tail -f /var/log/messages

  * 注意 Orchestrator 服务器，需要配置被管理 MySQL 服务器的 hostname 映射：

        vi /etc/hosts

        =>

            192.168.140.130 docker130

            192.168.140.136 docker136

  * 浏览器访问管理后台：

        http://192.168.140.136:3000/
