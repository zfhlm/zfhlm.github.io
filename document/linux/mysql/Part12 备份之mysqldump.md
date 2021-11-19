
#### mysqldump 备份

    执行命令：

        mysqldump -h127.0.0.1 -P3306 -uroot -p123456 --single-transaction --databases test -C -F --skip-extended-insert > backup.sql

    常用可选参数：

        -h --host              #数据IP地址，默认127.0.0.1

        -P --port              #数据库端口号，默认3306

        -u --user              #数据库连接账号

        -p --password          #数据库连接密码

        --single-transaction   #导出时不锁表，事务隔离级别为可重复读

        -C --compress          #导出网络传输启用压缩

        -F --flush-logs        #导出时刷新日志记录

        --flush-privileges     #导出时刷新权限信息

        -A --all-databases     #导出全部数据库

        -B --databases         #导出指定数据库

        --ignore-table         #导出时忽略指定表(表空间.表名，多个用逗号隔开)

        -n --no-create-db      #导出不包含创建表空间语句

        -t --no-create-info    #导出不包含创建表语句

        --skip-add-drop-table  #导出不包含删除表语句

        -c --complete-insert   #导出完整insert语句

        --skip-extended-insert #导出多行insert语句

        --master-data          #导出主从复制相关信息

#### 定时备份远程传输

    数据库服务器配置ssh免密访问远程服务器：

        数据库服务器输入命令：

            mkdir -p ~/.ssh/ && cd ~/.ssh/

            ssh-keygen -t rsa

            cat id_rsa.pub

            -> 假设输出 xxxxx

        远程服务器输入命令：

            mkdir -p ~/.ssh/ && cd ~/.ssh/

            echo 'xxxxx' >> authorized_keys

    数据库服务器可以创建如下脚本备份脚本(以下只是演示脚本)：

        mysqldump -h127.0.0.1 -P3306 -uroot -p123456 --single-transaction --databases test -C -F --skip-extended-insert > backup.sql

        gzip -f backup.sql

        scp backup.sql.gz root@192.168.140.1:/usr/local/backup

    数据库服务器将脚本添加到定时任务：

        crontab -e

        0 2 * * * /usr/local/backup/backupdump.sh >> /usr/local/backup/cron.log 2>&1

        service crond restart;

#### mysqldump恢复

    输入命令：

        #不指定数据库名称
        mysql -uroot -p123456 < backup.sql

        #指定数据库名称
        mysql -uroot -p123456 database_name < backup.sql
