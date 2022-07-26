
# MongoDB 单点配置

  * 下载安装包

        下载地址：https://www.mongodb.com/try/download/community

        下载安装包：mongodb-linux-x86_64-rhel70-5.0.4.tgz

        上传到服务器目录： /usr/local/software

  * 解压并配置，输入命令：

        tar -zxvf mongodb-linux-x86_64-rhel70-5.0.4.tgz

        mv mongodb-linux-x86_64-rhel70-5.0.4 /usr/local/

        cd /usr/local/ && ll

        ln -s mongodb-linux-x86_64-rhel70-5.0.4/ mongodb

        echo 'export PATH=/usr/local/mongodb/bin:$PATH' >> /etc/profile

        source /etc/profile

  * 启动数据库：

        mkdir -p /usr/local/mongodb/{data,logs}

        mongod --dbpath /usr/local/mongodb/data --logpath /usr/local/mongodb/logs/mongod.log --fork

        tail -f /usr/local/mongodb/logs/mongod.log

  * 创建超级管理员：

        cd /usr/local/mongodb

        ./bin/mongo

        use admin

        db.createUser({user:"admin",pwd:"123456",roles:["root"]})

        db.auth("admin", "123456")

        exit

  * 重启数据库，开启授权登录：

        ./bin/mongo

        db.shutdownServer();

        exit

        mongod --dbpath /usr/local/mongodb/data --logpath /usr/local/mongodb/logs/mongod.log --fork --auth

  * 创建连接账号：

        ./bin/mongo

        use admin

        db.auth("admin", "123456")

        use yapi

        db.createUser({user: "root", pwd: "123456", roles: [{ role: "dbOwner", db: "yapi" }]})

        exit
