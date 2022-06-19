
#### xtrabackup

    使用 yum 安装，注意根据数据库选择版本，输入命令：

        yum install -y https://downloads.percona.com/downloads/Percona-XtraBackup-2.4/Percona-XtraBackup-2.4.24/binary/redhat/7/x86_64/percona-xtrabackup-24-2.4.24-1.el7.x86_64.rpm

        innobackupex --help

    全量备份数据库：

        cd /usr/local/backup

        innobackupex --databases="test" --host="localhost" --port=3306 --user="root" --password="123456" -S /tmp/mysql.sock ./

        ll ./2021-10-26_04-57-36

    增量备份数据库：

        cd /usr/local/backup

        #基于全量进行增量备份
        innobackupex --databases="test" --host="localhost" --port=3306 --user="root" --password="123456" --incremental --incremental-basedir="./2021-10-26_04-57-36" -S /tmp/mysql.sock ./

        ll ./2021-10-26_04-59-06

        #基于增量进行增量备份
        innobackupex --databases="test" --host="localhost" --port=3306 --user="root" --password="123456" --incremental --incremental-basedir="./2021-10-26_04-59-06" -S /tmp/mysql.sock ./

        ll ./2021-10-26_04-59-25

    恢复全量备份到数据库：

        cd /usr/local/backup

        innobackupex --apply-log ./2021-10-26_04-57-36

        innobackupex --copy-back ./2021-10-26_04-57-36

    合并增量到全量，恢复到数据库：

        innobackupex --apply-log --redo-only ./2021-10-26_04-57-36

        innobackupex --apply-log --redo-only ./2021-10-26_04-57-36 --incremental-dir=./2021-10-26_04-59-06

        innobackupex --apply-log --redo-only ./2021-10-26_04-57-36 --incremental-dir=./2021-10-26_04-59-25

        innobackupex --copy-back ./2021-10-26_04-57-36
