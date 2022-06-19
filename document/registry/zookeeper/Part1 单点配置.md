
#### 单点配置

    安装包：

        下载安装包：apache-zookeeper-3.6.1-bin.tar.gz

        上传到服务器目录：/usr/local/backup/

    解压缩，输入命令：

        cd /usr/local/

        tar -zxvf ./backup/apache-zookeeper-3.6.1-bin.tar.gz ./

        ln -s apache-zookeeper-3.6.1-bin zookeeper

    生成配置文件，输入命令：

        cd /usr/local/zookeeper/conf

        cp zoo_sample.cfg zoo.cfg

    启停zookeeper，输入命令：

        cd /usr/local/zookeeper/

        ./bin/zkServer.sh start

        ./bin/zkServer.sh status

        ./bin/zkServer.sh stop
