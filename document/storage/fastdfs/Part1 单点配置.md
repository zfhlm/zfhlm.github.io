
#### 单点配置

    1，服务器准备

        192.168.0.1

    2，安装包准备

        FastDFS_v5.08.tar.gz

        perl-5.26.1.tar.gz

        libfastcommon-master.zip

        上传到服务器目录：/usr/local/backup

    3，安装perl，输入命令：

        cd /usr/local/backup

        tar -zxvf ./perl-5.26.1.tar.gz

        cd ./perl-5.26.1

        ./Configure -des -Dprefix=/usr/local/perl -Dusethreads -Uversiononly

        make && make install

        perl -version

    4，配置编译依赖环境，输入命令：

        yum -y install libevent

        rpm -qa | grep libevent

    5，编译配置libfastcommon，输入命令：

        cd /usr/local/backup

        unzip libfastcommon-master.zip

        cd ./libfastcommon-master

        ./make.sh

        ./make.sh install

        ln -s /usr/lib64/libfastcommon.so /usr/local/lib/libfastcommon.so

        ln -s /usr/lib64/libfastcommon.so /usr/lib/libfastcommon.so

        ln -s /usr/lib64/libfdfsclient.so /usr/local/lib/libfdfsclient.so

        ln -s /usr/lib64/libfdfsclient.so /usr/lib/libfdfsclient.so

    6，编译配置fastdfs，输入命令：

        cd /usr/local/backup

        tar -zxvf ./FastDFS_v5.08.tar.gz

        cd ./FastDFS

        ./make.sh

        ./make.sh install

        ll /usr/bin/fdfs_*

        ->

            <p>

            /bin/fdfs_monitor

            /bin/fdfs_storaged

            /bin/fdfs_test

            /bin/fdfs_trackerd

            ......

            </p>

    7，修改fastdfs配置文件，输入命令：

        cd /etc/fdfs/

        cp ./client.conf.sample ./client.conf

        cp ./storage.conf.sample ./storage.conf

        cp ./tracker.conf.sample ./tracker.conf

        mkdir sample

        mv ./*.sample ./sample/

        cd /usr/local

        mkdir -p /usr/local/fastdfs/tracker

        mkdir -p /usr/local/fastdfs/storage/data

        mkdir -p /usr/local/fastdfs/client

        vi /etc/fdfs/tracker.conf

        =>

            base_path=/usr/local/fastdfs/tracker

        vi /etc/fdfs/storage.conf

        =>

            base_path=/usr/local/fastdfs/storage
            store_path0=/usr/local/fastdfs/storage/data
            tracker_server=192.168.0.1:22122

        vi /etc/fdfs/client.conf

        =>

            base_path=/usr/local/fastdfs/client
            tracker_server=192.168.0.1:22122

    8，优化fastdfs配置，可选配置项：

        max_connections=1024               #最大连接数

        accept_threads=2                   #接收客户端连接的线程数，默认值为1

        work_threads=10                    #工作线程用来处理网络IO，默认值为4

        disk_rw_separated = true           #磁盘读写是否分离

        disk_reader_threads=5              #读取磁盘数据的线程数，默认为1

        disk_writer_threads=5              #写磁盘的线程数量，默认为1

        use_connection_pool=true           #开启连接池

        sync_binlog_buff_interval=2        #将binlog buffer写入磁盘的时间间隔

        sync_wait_msec=50                  #同步文件轮询时间

        sync_interval=0                    #同步完一个文件休眠时间

    9，启停上传测试，输入命令：

        /usr/bin/fdfs_trackerd /etc/fdfs/tracker.conf

        /usr/bin/fdfs_storaged /etc/fdfs/storage.conf

        /usr/bin/fdfs_monitor /etc/fdfs/client.conf

        echo test > /usr/local/fastdfs/test/test.txt

        /usr/bin/fdfs_test /etc/fdfs/client.conf upload /usr/local/fastdfs/test/test.txt

        /usr/bin/fdfs_trackerd /etc/fdfs/tracker.conf stop

        /usr/bin/fdfs_storaged /etc/fdfs/storage.conf stop
