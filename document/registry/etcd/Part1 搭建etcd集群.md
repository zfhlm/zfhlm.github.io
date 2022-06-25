
# 搭建 etcd 集群

### 服务器准备

    三台服务器：

        192.168.140.130     节点一

        192.168.140.131     节点二

        192.168.140.132     节点三

### 下载安装

    下载安装包，输入命令：

        cd /usr/local/software

        wget https://github.com/etcd-io/etcd/releases/download/v3.5.4/etcd-v3.5.4-linux-amd64.tar.gz

        tar -zxvf etcd-v3.5.4-linux-amd64.tar.gz

        mv etcd-v3.5.4-linux-amd64 ..

        cd ..

        ln -s etcd-v3.5.4-linux-amd64/ etcd

    节点一配置，输入命令：

        cd /usr/local/etcd

        vi etcd.yml

        =>

            name: etcd01
            data-dir: /usr/local/etcd/data
            advertise-client-urls: http://192.168.140.130:2379
            listen-client-urls: http://192.168.140.130:2379
            initial-advertise-peer-urls: http://192.168.140.130:2380
            listen-peer-urls: http://192.168.140.130:2380
            initial-cluster: etcd01=http://192.168.140.130:2380,etcd02=http://192.168.140.131:2380,etcd03=http://192.168.140.132:2380
            initial-cluster-token: mrh-etcd-cluster
            initial-cluster-state: new

    节点二配置，输入命令：

        cd /usr/local/etcd

        vi etcd.yml

        =>

            name: etcd02
            data-dir: /usr/local/etcd/data
            advertise-client-urls: http://192.168.140.131:2379
            listen-client-urls: http://192.168.140.131:2379
            initial-advertise-peer-urls: http://192.168.140.131:2380
            listen-peer-urls: http://192.168.140.131:2380
            initial-cluster: etcd01=http://192.168.140.130:2380,etcd02=http://192.168.140.131:2380,etcd03=http://192.168.140.132:2380
            initial-cluster-token: mrh-etcd-cluster
            initial-cluster-state: new

    节点二配置，输入命令：

        cd /usr/local/etcd

        vi etcd.yml

        =>

            name: etcd03
            data-dir: /usr/local/etcd/data
            advertise-client-urls: http://192.168.140.132:2379
            listen-client-urls: http://192.168.140.132:2379
            initial-advertise-peer-urls: http://192.168.140.132:2380
            listen-peer-urls: http://192.168.140.132:2380
            initial-cluster: etcd01=http://192.168.140.130:2380,etcd02=http://192.168.140.131:2380,etcd03=http://192.168.140.132:2380
            initial-cluster-token: mrh-etcd-cluster
            initial-cluster-state: new

    添加到系统服务，并启动集群，输入命令：

        cd /etc/systemd/system

        vi etcd.service

        =>

            [Unit]
            Description=Etcd Server
            Documentation=https://github.com/etcd-io/etcd
            After=network.target

            [Service]
            User=root
            Type=simple
            ExecStart=/usr/local/etcd/etcd --config-file=/usr/local/etcd/etcd.yml
            Restart=always
            RestartSec=10s
            LimitNOFILE=65536

            [Install]
            WantedBy=multi-user.target

        systemctl daemon-reload

        systemctl start etcd

    测试各个节点，输入命令：

        ./etcdctl endpoint status --cluster --endpoints=192.168.140.130:2380 -w table

        ->

            +-----------------------------+------------------+---------+---------+-----------+------------+-----------+------------+--------------------+--------+
            |          ENDPOINT           |        ID        | VERSION | DB SIZE | IS LEADER | IS LEARNER | RAFT TERM | RAFT INDEX | RAFT APPLIED INDEX | ERRORS |
            +-----------------------------+------------------+---------+---------+-----------+------------+-----------+------------+--------------------+--------+
            | http://192.168.140.132:2379 | 7d16af429d0fa6bd |   3.5.4 |   25 kB |     false |      false |         5 |         20 |                 20 |        |
            | http://192.168.140.130:2379 | b91ac90008b0ba8c |   3.5.4 |   20 kB |     false |      false |         5 |         20 |                 20 |        |
            | http://192.168.140.131:2379 | e74be5e48af37cb7 |   3.5.4 |   20 kB |      true |      false |         5 |         20 |                 20 |        |
            +-----------------------------+------------------+---------+---------+-----------+------------+-----------+------------+--------------------+--------+

        ./etcdctl put /test hi --endpoints=192.168.140.132:2380

        ./etcdctl get /test --endpoints=192.168.140.132:2380

        ./etcdctl get /test --endpoints=192.168.140.131:2380

        ./etcdctl get /test --endpoints=192.168.140.130:2380

        ./etcdctl del /test --endpoints=192.168.140.130:2380

        ./etcdctl get /test --endpoints=192.168.140.130:2380
