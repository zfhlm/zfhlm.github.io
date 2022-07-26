
# Mysql 数据备份

  * 注意，可以设置服务器定时任务，到达预设条件做备份，再远程传送到备份服务器存储

### mysqldump 备份

  * 执行备份命令：

        mysqldump -h127.0.0.1 -P3306 -uroot -p123456 --single-transaction --databases test -C -F --skip-extended-insert > backup.sql

  * 常用可选参数：

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

  * 备份恢复数据命令：

        #不指定数据库名称
        mysql -uroot -p123456 < backup.sql

        #指定数据库名称
        mysql -uroot -p123456 database_name < backup.sql

### xtrabackup 备份

  * 使用 yum 安装，注意根据数据库选择版本，输入命令：

        yum install -y https://downloads.percona.com/downloads/Percona-XtraBackup-2.4/Percona-XtraBackup-2.4.24/binary/redhat/7/x86_64/percona-xtrabackup-24-2.4.24-1.el7.x86_64.rpm

        innobackupex --help

  * 全量备份数据库：

        cd /usr/local/backup

        innobackupex --databases="test" --host="localhost" --port=3306 --user="root" --password="123456" -S /tmp/mysql.sock ./

        ll ./2021-10-26_04-57-36

  * 增量备份数据库：

        cd /usr/local/backup

        #基于全量进行增量备份
        innobackupex --databases="test" --host="localhost" --port=3306 --user="root" --password="123456" --incremental --incremental-basedir="./2021-10-26_04-57-36" -S /tmp/mysql.sock ./

        ll ./2021-10-26_04-59-06

        #基于增量进行增量备份
        innobackupex --databases="test" --host="localhost" --port=3306 --user="root" --password="123456" --incremental --incremental-basedir="./2021-10-26_04-59-06" -S /tmp/mysql.sock ./

        ll ./2021-10-26_04-59-25

  * 恢复全量备份到数据库：

        cd /usr/local/backup

        innobackupex --apply-log ./2021-10-26_04-57-36

        innobackupex --copy-back ./2021-10-26_04-57-36

  * 合并增量到全量，恢复到数据库：

        innobackupex --apply-log --redo-only ./2021-10-26_04-57-36

        innobackupex --apply-log --redo-only ./2021-10-26_04-57-36 --incremental-dir=./2021-10-26_04-59-06

        innobackupex --apply-log --redo-only ./2021-10-26_04-57-36 --incremental-dir=./2021-10-26_04-59-25

        innobackupex --copy-back ./2021-10-26_04-57-36
