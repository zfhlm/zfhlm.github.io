
# MySQL 集群方案

  * 常见方案：

        MySQL Replication                   # 官方自带功能，可以实现一主多从/双主互从，主节点 down 掉，集群可读不可写

        MySQL NDB Cluster                   # 官方提供，数据自动分片、多节点冗余，但是对服务器内存要求高，必须使用 NDB 存储引擎

        MySQL Innodb Cluster                # 官方提供，基于 Mysql-Group-Replication、Mysql-Shell、Mysql-Router的一套解决方案

        MySQL Master HA                     # 第三方中间件，基于 MySQL Replication 实现，Master 出现故障自动切换，需要配合 Keepalived 一起使用

        Percona XtraDB Cluster              # 第三方实现，Galera Cluster 两个版本之一，基于 MySQL，多主架构、同步复制、多线程复制、故障转移、节点自动加入、数据强一致性等特点

        Mysql Galera Cluster                # 第三方实现，Galera Cluster 两个版本之一，基于 MariaDB 实现

        (简单了解即可，一般都使用云数据库)

# MySQL NDB Cluster

  * 集群组成部分：

        MySQL NDB Cluster，一个 MNC 集群由若干管理节点、若干数据节点和若干 SQL 节点组成

        管理节点：用于管理集群内的其他节点，如提供配置数据，启动并停止节点，运行备份等，可以设置为1个到多个

        SQL节点：用于访问数据的节点，提供SQL接口，用户认证，赋予权限等功能，可以设置为1个到多个

        数据节点：

            用于保存数据、索引，控制事务等，多个节点组成一个分组，集群中可以有多个分组

            在同个分组中，数据节点数量必须能被 NoOfReplicas 参数整除，一般配置2个数据节点为同一个组，配置 NoOfReplicas=2

            如果同分组数据节点数=2，则 NoOfReplicas ∈ {1, 2}

            如果同分组数据节点数=3，则 NoOfReplicas ∈ {1, 3}

            如果同分组数据节点数=4，则 NoOfReplicas ∈ {1, 2, 4}

  * 下载安装包

        文档地址：https://dev.mysql.com/doc/refman/8.0/en/mysql-cluster.html

        下载地址：https://dev.mysql.com/downloads/cluster/

        下载安装包：mysql-cluster-8.0.27-linux-glibc2.12-x86_64.tar.gz

        上传到服务器目录：/usr/local/software

  * 服务器准备

        192.168.140.178        # 数据节点

        192.168.140.179        # 数据节点

        192.168.140.180        # 管理节点、SQL节点

        192.168.140.181        # 管理节点、SQL节点

        搭建 2个管理节点、2个 SQL 节点、2个数据节点同分组的 MNC 集群

  * 解压安装包，输入命令：

        yum -y remove mariadb*

        cd /usr/local/software

        tar ./mysql-cluster-8.0.27-linux-glibc2.12-x86_64.tar.gz

        mv ./mysql-cluster-8.0.27-linux-glibc2.12-x86_64 ../mysql-cluster-8.0.27

        cd ..

        ln -s ./mysql-cluster-8.0.27 mysql

  * 管理节点修改配置文件，输入命令：

        mkdir -p /usr/local/mysql/mgmd/{data,log}

        vi /etc/mgmd.cnf

        =>

            [ndb_mgmd default]
            PortNumber=1186                                                                             #管理节点默认监听端口
            DataDir=/usr/local/mysql/mgmd/data                                                          #管理节点默认存储目录
            ArbitrationRank=1                                                                           #管理节点默认指定为决策者
            LogDestination=FILE:filename=/usr/local/mysql/mgmd/log/mgmd.log,maxsize=1000000,maxfiles=6  #管理节点默认日志配置

            [ndbd default]
            ServerPort=2202                                                                             #数据节点默认端口
            NoOfReplicas=2                                                                              #数据节点默认冗余备份数
            DataDir=/usr/local/mysql/ndbd/data                                                          #数据节点默认存储目录

            [ndb_mgmd]
            NodeId=180                                                                                  #管理节点一ID
            HostName=192.168.140.180                                                                    #管理节点一IP地址

            [ndb_mgmd]
            NodeId=181                                                                                  #管理节点ID
            HostName=192.168.140.181                                                                    #管理节点二IP地址

            [ndbd]
            NodeId=1                                                                                    #数据节点一ID
            HostName=192.168.140.178                                                                    #数据节点一IP地址

            [ndbd]
            NodeId=2                                                                                    #数据节点二ID
            HostName=192.168.140.179                                                                    #数据节点二IP地址

            [mysqld]
            NodeId=100                                                                                  #SQL节点一ID
            HostName=192.168.140.180                                                                    #SQL节点一IP地址

            [mysqld]
            NodeId=101                                                                                  #SQL节点二ID
            HostName=192.168.140.181                                                                    #SQL节点二IP地址

  * 数据节点修改配置文件，输入命令：

        mkdir -p /usr/local/mysql/ndbd/data

        vi /etc/my.cnf

        =>

            [mysqld]
            ndbcluster                                                                               #开启NDB存储引擎

            [mysql_cluster]
            ndb-connectstring=192.168.140.180,192.168.140.181                                        #管理节点连接地址

  * SQL 节点，创建运行用户，输入命令：

        groupadd mysql

        useradd -r -s /sbin/nologin -g mysql mysql -d /usr/local/mysql/

        chown -R mysql:mysql mysql

        chown -R mysql:mysql mysql-cluster-8.0.27/

  * SQL 节点，初始化数据库，输入命令：

        mkdir -p /usr/local/mysql/data/

        chown -R mysql:mysql /usr/local/mysql/

        cd /usr/local/software

        ./bin/mysqld --initialize --user=mysql --basedir=/usr/local/mysql --datadir=/usr/local/mysql/data

        -> 控制台输出 root 临时密码

        cp ./support-files/mysql.server /etc/init.d/mysqld

  * SQL 节点，修改配置文件，输入命令：

        vi /etc/my.cnf

        =>

            [mysqld]
            basedir= /usr/local/mysql                                                                #SQL节点目录
            datadir=/usr/local/mysql/data                                                            #SQL节点存储目录
            ndbcluster                                                                               #开启NDB存储引擎

            [mysql_cluster]
            ndb-connectstring=192.168.140.180,192.168.140.181                                        #管理节点连接地址

  * 启动管理节点，输入命令：

        cd /usr/local/mysql

        ./bin/ndb_mgmd --initial -f /etc/mgmd.cnf

  * 启动数据节点，输入命令：

        cd /usr/local/mysql

        ./bin/ndbd --initial

  * 启动 SQL 节点，输入命令：

        cd /usr/local/mysql

        service mysqld start

  * 管理节点查看各节点状态，输入命令：

        ./bin/ndb_mgm -e -show --ndb-nodeid=181 --connect-string=192.168.140.181

  * 初始化 SQL 节点 root 登录信息(使用临时密码)，输入命令：

        cd /usr/local/mysql

        ./bin/mysql -uroot -p

        alter user 'root'@'localhost' identified by '123456';

        update mysql.user set host='%' where user='root';

        flush privileges;

  * 使用远程工具连接数据库，连接地址：

        # 192.168.140.180:3306   192.168.140.181:3306

        # 创建数据库和测试表
        CREATE DATABASE `test`;
        CREATE TABLE `test`.`test_user` (
          `id` INT NOT NULL,
          `name` VARCHAR(45) NULL,
          PRIMARY KEY (`id`)
        ) ENGINE = ndbcluster DEFAULT CHARACTER SET = utf8mb4 COLLATE = utf8mb4_bin;

        # 插入数据
        insert into `test_user` values ('1', '张三');
        insert into `test_user` values ('2', '李四');

        # 查询数据
        select * from `test_user`;

  * 模拟节点故障

        如果 SQL 节点 down 掉，只会影响连接这个 SQL 节点的客户端，其他 SQL 节点可以正常工作，这里不做模拟

        关闭第一个数据节点，输入命令：

            ps -ef | grep ndbd

            pkill ndbd

        客户端对数据库进行读写，正常执行(关闭第二个数据节点，发现数据库已经不能读写)：

            insert into `test_user` values ('3', '王五');

            select * from `test_user`;

        关闭第一个管理节点，输入命令：

            ps -ef | grep mgmd

            kill pid

        客户端对数据库进行读写，正常执行(关闭第二个管理节点，数据库仍旧可以正常读写)：

            insert into `test_user` values ('4', '赵六');

            select * from `test_user`;

  * 在线添加数据节点

        添加两个新的数据节点，组成一个新分组：

            192.168.140.182

            192.168.140.183

            (按照初始化安装、配置数据节点步骤，设定好各项配置)

        修改管理节点配置，输入命令：

            vi /etc/mgmd.cnf

        加入以下配置内容：

            [ndbd]
            NodeId=3                                                                                 #数据节点三ID
            HostName=192.168.140.182                                                                 #数据节点三IP地址

            [ndbd]
            NodeId=4                                                                                 #数据节点四ID
            HostName=192.168.140.183                                                                 #数据节点四IP地址

        管理节点重启，输入命令：

            ps -ef | grep mgmd

            kill pid

            ./bin/ndb_mgmd -f /etc/mgmd.cnf --reload

        数据节点重启，管理节点输入命令：

            ./bin/ndb_mgm --ndb-nodeid=181 --connect-string=192.168.140.181

            show

            1 restart

            -> 注意控制台输出，等待到启动成功
            -> Node 1: Node shutdown initiated
            -> Node 1: Node shutdown completed, restarting, no start.
            -> Node 1 is being restarted
            -> Node 1: Start initiated (version 8.0.27)
            -> Node 1: Started (version 8.0.27)

            2 restart

            -> 注意控制台输出，等待到启动成功
            -> Node 2: Node shutdown initiated
            -> Node 2: Node shutdown completed, restarting, no start.
            -> Node 2 is being restarted
            -> Node 2: Start initiated (version 8.0.27)
            -> Node 2: Started (version 8.0.27)

        SQL节点重启，输入命令：

            service mysqld restart

        初始化启动新的数据节点，输入命令：

            cd /usr/local/mysql

            ./bin/ndbd --initial

        管理节点创建分组，输入命令：

            ./bin/ndb_mgm --ndb-nodeid=181 --connect-string=192.168.140.181

            show

            create nodegroup 3,4

            show

  * 常用 MNC 命令

        注意，以下所有包含 --initial 命令中，只能在初次启动的时候使用

        数据节点命令：

            ./bin/ndbd                                       #启动数据节点守护进程(常规启动)

            ./bin/ndbd --initial                             #启动数据节点守护进程(初次启动)

        SQL节点命令：

            service mysqld start                             #启动SQL节点守护进程

            service mysqld stop                              #停止SQL节点守护进程

            service mysqld restart                           #重启SQL节点守护进程

        管理节点命令：

            ./bin/ndb_mgmd -f /etc/mgmd.cnf                  #启动管理节点守护进程(常规启动)

            ./bin/ndb_mgmd -f /etc/mgmd.cnf --reload         #启动管理节点守护进程(配置文件有改动时启动)

            ./bin/ndb_mgmd -f /etc/mgmd.cnf --initial        #启动管理节点守护进程(初次启动)

            ./bin/ndb_mgm                                    #进入管理节点控制台

            ./bin/ndb_mgm -e show                            #使用管理节点控制台执行show命令

        管理节点控制台命令：

            show                                             #查看所有节点状态

            [nodeid] restart                                 #重启指定nodeid进程

            [nodeid] stop                                    #停止指定nodeid进程

            create nodegroup [nodeid1],[nodeid2]             #创建数据节点分组

# MySQL Master HA

  * 服务器准备

        192.168.140.174        # mysql主节点、MHA node节点

        192.168.140.175        # mysql从节点、MHA node节点(备用master)

        192.168.140.176        # mysql从节点、MHA node节点(只作为slave)

        192.168.140.177        # MHA管理节点

        (以上，mysql节点注意开启半同步复制、GTID，并配置好一主二从)

  * 服务器ssh免密配置

        主节点生成公钥和私钥，输入命令：

            cd ~

            ssh-keygen

            cd .ssh/

            cp id_rsa.pub authorized_keys

        主节点同步公钥和私钥到其他节点，输入命令：

            cd /root

            scp -r /root/.ssh/ root@192.168.140.175:/root/

            scp -r /root/.ssh/ root@192.168.140.176:/root/

            scp -r /root/.ssh/ root@192.168.140.177:/root/

        测试ssh免密登录，输入命令：

            ssh 192.168.140.175

            ls /usr/local/software

            exit

  * 下载 MHA 安装包

        官方文档地址：https://github.com/yoshinorim/mha4mysql-manager/wiki

        下载地址：https://github.com/yoshinorim/mha4mysql-manager/releases/

        下载源码包：mha4mysql-node-0.58.tar.gz  mha4mysql-manager-0.58.tar.gz

        上传到服务器目录：/usr/local/software

  * MHA 管理节点 和 Node 节点，安装 MHA Node，输入命令：

        yum install -y perl-DBD-MySQL perl-ExtUtils-Embed cpan

        cd /usr/local/software

        tar -zxf ./mha4mysql-node-0.58.tar.gz

        cd mha4mysql-node-0.58

        perl Makefile.PL

        make && make install

        ll /usr/local/bin/

  * MHA 管理节点，安装 MHA Manager，输入命令：

        yum install https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm

        yum install -y perl-Config-Tiny perl-Log-Dispatch perl-Parallel-ForkManager

        cd /usr/local/software

        tar -zxf ./mha4mysql-manager-0.58.tar.gz

        cd ./mha4mysql-manager-0.58

        perl Makefile.PL

        make && make install

        cp ./samples/scripts/* /usr/local/bin/

        ll /usr/local/bin/

  * 查看 MHA 脚本，输入命令：

        ll /usr/local/bin/

  * MHA Node 节点脚本作用说明：

        apply_diff_relay_logs           #识别差异的中继日志事件

        filter_mysqlbinlog              #过滤回滚事务binlog

        purge_relay_logs                #清除中继日志

        save_binary_logs                #保存和复制master的二进制日志

  * MHA Manager 节点脚本作用说明：

        masterha_check_repl             #检查 MHA 主从数据库状态脚本

        masterha_check_ssh              #检查 MHA ssh 连接配置脚本

        masterha_check_status           #检测当前MHA运行状态脚本

        masterha_conf_host              #管理 MHA server配置脚本

        masterha_manager                #启动 MHA 脚本

        masterha_master_monitor         #监控主从 master 状态脚本

        masterha_master_switch          #故障转移脚本

        masterha_secondary_check        #检查网络连接脚本

        masterha_stop                   #停止 MHA 脚本

        master_ip_failover              #VIP故障转移脚本

        master_ip_online_change         #VIP手动切换脚本

        power_manager                   #防止集群脑裂关闭master服务脚本

        send_report                     #发送邮件通知脚本

  * 配置文件参数官方文档：

        https://raw.githubusercontent.com/wiki/yoshinorim/mha4mysql-manager/Parameters.md

  * 管理节点添加 MHA Manager 全局配置，输入命令：

        vi /etc/masterha_default.cnf

        =>

            [server default]

            #ssh远程账号
            ssh_user=root

            #ssh远程端口
            ssh_port=22

            #数据库连接账号
            user=root

            #数据库连接密码
            password=123456

            #数据库创建主从账号
            repl_user=replicator

            #数据库创建主从密码
            repl_password=123456

            #数据库主节点binlog目录
            master_binlog_dir= /usr/local/mysql/data

            #数据库主节点ping时间间隔
            ping_interval=3

            #远程节点工作目录
            remote_workdir=/usr/local/masterha/

            #管理节点工作目录
            manager_workdir=/usr/local/masterha/

            #管理节点日志目录
            manager_log=/usr/local/masterha/manager.log

  * 管理节点添加 MHA Manager 集群1配置，输入命令：

        vi /etc/app1.cnf

        =>

            [server default]

            #管理节点集群1工作目录
            manager_workdir=/usr/local/masterha/app1/

            #管理节点集群1日志目录
            manager_log=/usr/local/masterha/app1/manager.log

            [server1]

            #主节点IP
            hostname=192.168.140.174

            #允许故障切换为master
            candidate_master=1

            #切换master不用考虑复制延迟
            check_repl_delay=0

            [server2]

            #从节点IP
            hostname=192.168.140.175

            #允许故障切换为master
            candidate_master=1

            #切换master不用考虑复制延迟
            check_repl_delay=0

            [server3]

            #从节点IP
            hostname=192.168.140.176

            #不允许故障切换为master
            no_master=1

  * 管理节点添加 MHA Manager 集群2 ... 集群N，只需创建不同的配置文件，例如：

        vi /etc/app2.cnf

        vi /etc/app3.cnf

              ...

        vi /etc/appN.cnf

  * 管理节点验证集群1 ssh 是否正确，输入命令：

        masterha_check_ssh --conf=/etc/app1.cnf

        -> 注意控制台是否输出成功信息 All SSH connection tests passed successfully.

  * 管理节点验证集群1 主从复制是否正确，输入命令：

        masterha_check_repl --conf=/etc/app1.cnf

        -> 注意控制台是否输出成功信息 MySQL Replication Health is OK.

  * 管理节点启动 MHA Manager，输入命令：

        masterha_manager --conf=/etc/app1.cnf &

        masterha_check_status --conf=/etc/app1.cnf

        tail -f /usr/local/masterha/app1/manager.log

  * 如果需要关闭 MHA Manager，输入命令：

        masterha_stop --conf=/etc/app1.cnf

  * 模拟 MHA 故障转移

        管理节点持续查看日志，输入命令：

            tail -f /usr/local/masterha/app1/manager.log

        主节点 mysql 模拟故障，重启服务器，输入命令：

            reboot

        MHA切换master成功，管理节点可以看到如下输出信息：

            Started automated(non-interactive) failover.
            Selected 192.168.140.175(192.168.140.175:3306) as a new master.
            192.168.140.175(192.168.140.175:3306): OK: Applying all logs succeeded.
            192.168.140.176(192.168.140.176:3306): OK: Slave started, replicating from 192.168.140.175(192.168.140.175:3306)
            192.168.140.175(192.168.140.175:3306): Resetting slave info succeeded.
            Master failover to 192.168.140.175(192.168.140.175:3306) completed successfully.

        从节点可以看到节点三的master已经是节点二，输入命令：

            mysql -uroot -p

            show slave status\G;

            show master status;

        管理节点 MHA Manager 在故障转移后会杀死自身进程，查看进程输入命令：

            ps -ef | grep masterha

  * 模拟 MHA 故障恢复

        节点二(新master)模拟写入数据提升集群 GTID，输入命令：

            mysql -uroot -p

            #根据实际情况插入数据
            insert into table_name ......

        节点一(原 master)以只读的方式启动，输入命令：

            service mysqld start --read-only=1

            mysql -uroot -p

            show variables like 'read_only';

        节点一(原 master)加入到主从集群，输入命令：

            change master to master_host='192.168.140.175', master_user='replicator', master_password='123456',master_auto_position=1;

            start slave;

            show slave status\G

        管理节点删除上次故障切换的标记文件，检查配置文件信息是否正确，输入命令：

            rm -rf /usr/local/masterha/app1/app1.failover.complete

            cat /etc/app1.cnf

        管理节点执行切换脚本，将主节点切换为 master，输入命令：

            masterha_master_switch --conf=/etc/app1.cnf --master_state=alive --new_master_host=192.168.140.174 --new_master_port=3306  --orig_master_is_new_slave

        所有节点检查状态是否正常，输入命令：

            show master status;

            show slave status\G;

            show variables like 'read_only';

        管理节点重新启动 MHA，输入命令：

            masterha_check_ssh --conf=/etc/app1.cnf

            masterha_manager --conf=/etc/app1.cnf &

            masterha_check_status --conf=/etc/app1.cnf

  * 配置 MHA 执行脚本

        选择性加入到全局配置文件，或 集群配置文件：

            # 故障二次检测确认脚本，提升集群网络容忍能力
            secondary_check_script=masterha_secondary_check -s 192.168.140.175 -s 192.168.140.176

            # 故障切换邮件通知，自带脚本未实现邮件发送的功能，仅仅是定义了命令行传递的参数，需要额外编写发送逻辑
            report_script=/usr/local/bin/send_report

            # 故障切换 VIP 到备用 master
            master_ip_failover_script=/usr/local/bin/master_ip_failover

# Percona XtraDB Cluster

  * 三台服务器信息：

        192.168.140.170        #节点一

        192.168.140.172        #节点二

        192.168.140.173        #节点三

  * 配置三台服务器host，输入命令：

        vi /etc/hosts

        添加以下配置：

            192.168.140.170 pxc170
            192.168.140.172 pxc172
            192.168.140.173 pxc173

        service network restart

        hostname

  * 关闭三台服务器防火墙，输入命令：

        setenforce 0

        vi /etc/selinux/config

        => SELINUX=disabled

        systemctl stop firewalld

        systemctl disable firewalld

  * 下载安装包

        注意 PXC 安装包的版本号与 mysql 版本号相对应，本次搭建基于 5.7.34 版本

        官方网站：https://downloads.percona.com/

        下载安装包： https://www.percona.com/downloads/Percona-XtraDB-Cluster-57/LATEST/

        下载包名称： Percona-XtraDB-Cluster-5.7.34-31.51-r604-el7-x86_64-bundle.tar

        下载依赖包：

            https://repo.percona.com/release/7/RPMS/x86_64/qpress-11-1.el7.x86_64.rpm

            https://repo.percona.com/release/7/RPMS/x86_64/percona-xtrabackup-24-2.4.23-1.el7.x86_64.rpm

        上传到服务器目录  /usr/local/software

  * 安装rpm包，输入命令：

        yum -y remove mariadb*

        cd /usr/local/software

        tar -xvf ./Percona-XtraDB-Cluster-5.7.34-31.51-r604-el7-x86_64-bundle.tar

        yum localinstall -y *.rpm

        (注意，如果需要修改数据库相关目录，请在此配置完 my.cnf 再初始化启动)

  * 初始化 PXC 数据库账号，输入命令：

        systemctl start mysql

        grep 'temporary password' /var/log/mysqld.log

        mysql -uroot -p

        alter user 'root'@'localhost' IDENTIFIED BY '123456';

        exit

        systemctl stop mysql

  * 关闭 PXC 开启自启动，输入命令：

        chkconfig mysqld off

  * 修改 PXC 集群配置

        (注意，此处只是修改了 PXC 集群相关配置，优化配置参考单点配置)

        修改 PXC 数据库配置，输入命令：

            vi /etc/percona-xtradb-cluster.conf.d/mysqld.cnf

        节点一添加以下内容：

            server-id=170

        节点二添加以下内容：

            server-id=172

        节点三添加以下内容：

            server-id=173

        注意，在此可以加入其他参数，参考 Part01 单点配置的参数进行配置

        修改 PXC 节点配置，输入命令：

            vi /etc/percona-xtradb-cluster.conf.d/wsrep.cnf

        节点一添加以下内容：

            [mysqld]

            wsrep_provider=/usr/lib64/galera3/libgalera_smm.so
            wsrep_cluster_name=mrh-pxc-cluster
            wsrep_cluster_address=gcomm://192.168.140.170,192.168.140.172,192.168.140.173

            wsrep_node_name=pxc170
            wsrep_node_address=192.168.140.170

            wsrep_sst_method=xtrabackup-v2
            wsrep_sst_auth=sstuser:123456

            pxc_strict_mode=ENFORCING

            binlog_format=ROW
            default_storage_engine=InnoDB
            innodb_autoinc_lock_mode=2

        节点二添加以下内容：

            [mysqld]

            wsrep_provider=/usr/lib64/galera3/libgalera_smm.so
            wsrep_cluster_name=mrh-pxc-cluster
            wsrep_cluster_address=gcomm://192.168.140.170,192.168.140.172,192.168.140.173

            wsrep_node_name=pxc172
            wsrep_node_address=192.168.140.172

            wsrep_sst_method=xtrabackup-v2
            wsrep_sst_auth=sstuser:123456

            pxc_strict_mode=ENFORCING

            binlog_format=ROW
            default_storage_engine=InnoDB
            innodb_autoinc_lock_mode=2

        节点三添加以下内容：

            [mysqld]

            wsrep_provider=/usr/lib64/galera3/libgalera_smm.so
            wsrep_cluster_name=mrh-pxc-cluster
            wsrep_cluster_address=gcomm://192.168.140.170,192.168.140.172,192.168.140.173

            wsrep_node_name=pxc173
            wsrep_node_address=192.168.140.173

            wsrep_sst_method=xtrabackup-v2
            wsrep_sst_auth=sstuser:123456

            pxc_strict_mode=ENFORCING

            binlog_format=ROW
            default_storage_engine=InnoDB
            innodb_autoinc_lock_mode=2

  * 初次启动 PXC 集群

        启动节点一，输入命令：

            systemctl start mysql@bootstrap.service

            mysql -uroot -p

            show status like 'wsrep%';

        节点一创建 PXC 连接账号，输入命令：

            mysql -uroot -p

            CREATE USER 'sstuser'@'%' IDENTIFIED BY '123456';

            GRANT RELOAD, LOCK TABLES, PROCESS, REPLICATION CLIENT ON *.* TO 'sstuser'@'%';

            FLUSH PRIVILEGES;

            select user,host from mysql.user;

        启动节点二和节点三，输入命令：

            systemctl start mysql

            show status like 'wsrep%';

  * 关闭 PXC 集群节点

        确认是否引导启动节点（进程是否有--wsrep-new-cluster参数），输入命令：

            ps -ef | grep mysql

        关闭引导启动节点，输入命令：

            systemctl stop mysql@bootstrap.service

        关闭其他节点，输入命令：

            systemctl stop mysql

  * 重新启动 PXC 集群

        1，集群未关闭全部节点，直接启动关闭节点加入集群

            输入命令：

                systemctl start mysql

                show status like 'wsrep%';

        2，集群被关闭全部节点，确认节点是否最后关闭节点：

            文件参数 safe_to_bootstrap=1 为最后关闭节点，查看是否最后关闭节点，输入命令：

                cat /var/lib/mysql/grastate.dat

            如果全部节点 safe_to_bootstrap=0，通过比对 seqno 值最大的为最后关闭节点，输入命令：

                mysqld_safe --wsrep-recover

        3，集群被关闭全部节点，启动所有节点：

            先启动最后关闭节点，输入命令：

                systemctl start mysql@bootstrap.service

            再启动其他节点，输入命令：

                systemctl start mysql

  * 添加新节点到 PXC 集群

        1，如果集群数据量非常小，直接加入新节点到 PXC 集群，触发 SST 全量同步

        2，如果集群数据量非常大，直接加入新节点 SST 开销大，可通过 xtrabackup + IST增量同步的方式添加新节点：

            旧节点拉取当前时间点的全量数据，输入命令(根据实际情况更改命令参数)：

                mkdir /usr/local/backup

                cd /usr/local/backup

                innobackupex --databases="test" --host="localhost" --port=3306 --user="sstuser" --password="123456" --galera-info "./"

                tar -cvf backup.2021-10-21_19-25-46.tar ./2021-10-21_19-25-46

                cat /var/lib/mysql/grastate.dat > copy.grastate.dat

            旧节点将还原需要的文件传输到新节点服务器，输入命令(根据实际情况更改命令参数)：

                cd /usr/local/backup

                scp ./backup.2021-10-21_19-25-46.tar root@192.168.140.175:/usr/local/backup

                scp ./copy.grastate.dat root@192.168.140.175:/usr/local/backup

            新节点还原备份数据，并修改 grastate.dat IST增量同步参数 seqno，输入命令(根据实际情况更改命令参数)：

                cd /usr/local/backup

                tar --xvf ./backup.2021-10-21_19-25-46.tar

                cd ./backup.2021-10-21_19-25-46

                innobackupex –apply-log ./

                innobackupex –copy-back ./

                cat ./xtrabackup_galera_info

                -> 输出内容例如如 cd39819a-32a7-11ec-a078-6feecc9850b6:14，seqno值为14，集群uuid值为cd39819a-32a7-11ec-a078-6feecc9850b6

                cp ./copy.grastate.dat /var/lib/mysql/grastate.dat

                vi /var/lib/mysql/grastate.dat

                => 根据上面的输出内容，修改 seqno 值，比如 14

            新节点更改配置文件，然后启动加入集群，输入命令：

                vi /etc/percona-xtradb-cluster.conf.d/wsrep.cnf

                => 配置各项参数，包含新旧节点IP

                systemctl start mysql

                show status like 'wsrep%';

            旧节点更改配置文件，然后逐个重启，输入命令：

                vi /etc/percona-xtradb-cluster.conf.d/wsrep.cnf

                => wsrep_cluster_address 加入新节点IP

  * 恢复故障节点到 PXC 集群

        1，如果故障节点加入集群binlog可以补全，直接启动加入到集群，触发 IST 增量同步

        2，如果故障节点加入集群binlog不能补全，可以通过添加新节点的方式

# Mysql Galera Cluster

  * 三台服务器信息：

        192.168.140.184        #节点一

        192.168.140.185        #节点二

        192.168.140.186        #节点三

  * 配置三台服务器host，输入命令：

        vi /etc/hosts

        =>

            192.168.140.184 mgc184
            192.168.140.185 mgc185
            192.168.140.186 mgc186

        service network restart

        hostname

  * 关闭三台服务器防火墙，输入命令：

        setenforce 0

        vi /etc/selinux/config

        => SELINUX=disabled

        systemctl stop firewalld

        systemctl disable firewalld

  * 官方文档地址：

        https://galeracluster.com/library/documentation/index.html

  * 使用 yum 安装，输入命令：

        yum -y remove mariadb*

        cat > /etc/yum.repos.d/galera.repo <<EOF

        [galera]
        name=galera
        baseurl= http://releases.galeracluster.com/galera-3/centos/7/x86_64/
        gpgcheck=0

        [mysql-wsrep]
        name = mysql-wsrep
        baseurl = http://releases.galeracluster.com/mysql-wsrep-5.7/centos/7/x86_64/
        gpgcheck = 0

        EOF

        yum makecache

        yum install -y  mysql-wsrep-5.7 galera-3

        yum localinstall -y https://repo.percona.com/release/7/RPMS/x86_64/percona-xtrabackup-24-2.4.24-1.el7.x86_64.rpm

        （注意，如果需要修改数据库相关目录，请在此配置完 my.cnf 再初始化)

  * 初始化数据库root账号，输入命令：

        systemctl start mysqld

        grep 'temporary password' /var/log/mysqld.log

        mysql -uroot -p

        set global validate_password_policy=LOW;

        set global validate_password_length=6;

        alter user 'root'@'localhost' IDENTIFIED BY '123456';

        exit

        systemctl stop mysqld

  * 关闭数据库开机自启动，输入命令：

        chkconfig mysqld off

  * 配置 MGC

        注意，此处只是修改了 MGC 集群相关配置，优化配置参考单点配置

        修改 my.cnf，输入命令：

            vi /etc/my.cnf

        节点一加入以下内容：

            server_id=184

            binlog_format=ROW
            default_storage_engine=InnoDB
            innodb_autoinc_lock_mode=2

            wsrep_node_name=mgc184
            wsrep_node_address=192.168.140.184
            wsrep_cluster_address=gcomm://192.168.140.184,192.168.140.185,192.168.140.186
            wsrep_cluster_name=mrh_galera_cluster
            wsrep_sst_auth=sstuser:123456
            wsrep_sst_method=xtrabackup
            wsrep-provider=/usr/lib64/galera-3/libgalera_smm.so

        节点二加入以下内容：

            server_id=185

            binlog_format=ROW
            default_storage_engine=InnoDB
            innodb_autoinc_lock_mode=2

            wsrep_node_name=mgc185
            wsrep_node_address=192.168.140.185
            wsrep_cluster_address=gcomm://192.168.140.184,192.168.140.185,192.168.140.186
            wsrep_cluster_name=mrh_galera_cluster
            wsrep_sst_auth=sstuser:123456
            wsrep_sst_method=xtrabackup
            wsrep-provider=/usr/lib64/galera-3/libgalera_smm.so

        节点三加入以下内容：

            server_id=186

            binlog_format=ROW
            default_storage_engine=InnoDB
            innodb_autoinc_lock_mode=2

            wsrep_node_name=mgc186
            wsrep_node_address=192.168.140.186
            wsrep_cluster_address=gcomm://192.168.140.184,192.168.140.185,192.168.140.186
            wsrep_cluster_name=mrh_galera_cluster
            wsrep_sst_auth=sstuser:123456
            wsrep_sst_method=xtrabackup
            wsrep-provider=/usr/lib64/galera-3/libgalera_smm.so

  * 初始化启动 MGC 集群

        节点一引导启动，输入命令：

            /usr/bin/mysqld_bootstrap

            mysql -uroot -p

            show status like 'wsrep%';

        节点一创建 PXC 连接账号，输入命令：

            mysql -uroot -p

            CREATE USER 'sstuser'@'%' IDENTIFIED BY '123456';

            GRANT RELOAD, LOCK TABLES, PROCESS, REPLICATION CLIENT ON *.* TO 'sstuser'@'%';

            FLUSH PRIVILEGES;

            select user,host from mysql.user;

        节点二和节点三启动，输入命令：

            systemctl start mysqld

            show status like 'wsrep%';

  * 关闭 MGC 集群节点

        输入命令：

            systemctl stop mysqld

  * 其他 MGC 集群操作

        MGC 集群重启、添加新节点、故障恢复，可参考 其兄弟 Part10，两者的区别在于命令有略微差异
