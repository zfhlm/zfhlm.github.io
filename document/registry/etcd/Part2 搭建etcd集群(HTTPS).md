
# 搭建 etcd 集群 HTTPS

  * 三台服务器：

        192.168.140.130     节点一

        192.168.140.131     节点二

        192.168.140.132     节点三

## 安装前提示

  * 踩坑记录：tls: first record does not look like a TLS handshake

        开始使用 HTTP 协议，再配置 TLS 证书，启动会当前报错，需要删除 etcd data 目录信息，再重启各个 etcd 节点

## 下载安装

  * 下载安装包，输入命令：

        cd /usr/local/software

        wget https://github.com/etcd-io/etcd/releases/download/v3.5.4/etcd-v3.5.4-linux-amd64.tar.gz

        tar -zxvf etcd-v3.5.4-linux-amd64.tar.gz

        mv etcd-v3.5.4-linux-amd64 ..

        cd ..

        ln -s etcd-v3.5.4-linux-amd64/ etcd

  * 安装 cfssl 工具：

        wget https://pkg.cfssl.org/R1.2/cfssl_linux-amd64

        wget https://pkg.cfssl.org/R1.2/cfssljson_linux-amd64

        wget https://pkg.cfssl.org/R1.2/cfssl-certinfo_linux-amd64

        chmod +x cfssl_linux-amd64 cfssljson_linux-amd64 cfssl-certinfo_linux-amd64

        mv cfssl_linux-amd64 /usr/bin/cfssl

        mv cfssljson_linux-amd64 /usr/bin/cfssljson

        mv cfssl-certinfo_linux-amd64 /usr/bin/cfssl-certinfo

  * 生成 TLS 证书：

        cd /usr/local/software

        vi etcd-root-ca-csr.json

        =>

            {
               "key": {
                 "algo": "rsa",
                 "size": 4096
               },
               "names": [
                 {
                   "O": "etcd",
                   "OU": "etcd Security",
                   "L": "Beijing",
                   "ST": "Beijing",
                   "C": "CN"
                 }
               ],
               "CN": "etcd-root-ca"
            }

        vi etcd-gencert.json

        =>

            {
              "signing": {
                "default": {
                    "usages": [
                      "signing",
                      "key encipherment",
                      "server auth",
                      "client auth"
                    ],
                    "expiry": "87600h"
                }
              }
            }

        vi etcd-csr.json

        => (以下 hosts 注意预留扩容的 IP 地址，减少不必要的证书更新)

            {
              "key": {
                "algo": "rsa",
                "size": 4096
              },
              "names": [
                {
                  "O": "etcd",
                  "OU": "etcd Security",
                  "L": "Beijing",
                  "ST": "Beijing",
                  "C": "CN"
                }
              ],
              "CN": "etcd",
              "hosts": [
                "127.0.0.1",
                "localhost",
                "192.168.140.147",
                "192.168.140.148",
                "192.168.140.149",
                "k3s-master-147",
                "k3s-master-148",
                "k3s-master-149",
                "etcd01",
                "etcd02",
                "etcd03"
              ]
            }

        cfssl gencert --initca=true etcd-root-ca-csr.json | cfssljson --bare etcd-root-ca

        cfssl gencert --ca etcd-root-ca.pem --ca-key etcd-root-ca-key.pem --config etcd-gencert.json etcd-csr.json | cfssljson --bare etcd

  * 分发 TLS 证书：

        cd /usr/local/software

        scp ./* root@192.168.140.147:/usr/local/etcd/certs/

        scp ./* root@192.168.140.148:/usr/local/etcd/certs/

        scp ./* root@192.168.140.149:/usr/local/etcd/certs/

        rm -rf ./*

  * 节点一配置，输入命令：

        cd /usr/local/etcd

        vi etcd.yml

        =>

            name: etcd01
            data-dir: /usr/local/etcd/data
            advertise-client-urls: https://192.168.140.147:2379
            listen-client-urls: https://192.168.140.147:2379
            initial-advertise-peer-urls: https://192.168.140.147:2380
            listen-peer-urls: https://192.168.140.147:2380
            initial-cluster: etcd01=https://192.168.140.147:2380,etcd02=https://192.168.140.148:2380,etcd03=https://192.168.140.149:2380
            initial-cluster-token: mrh-etcd-cluster
            initial-cluster-state: new
            client-transport-security:
              client-cert-auth: true
              trusted-ca-file: /usr/local/etcd/certs/etcd-root-ca.pem
              cert-file: /usr/local/etcd/certs/etcd.pem
              key-file: /usr/local/etcd/certs/etcd-key.pem
              auto-tls: true
            peer-transport-security:
              client-cert-auth: true
              trusted-ca-file: /usr/local/etcd/certs/etcd-root-ca.pem
              cert-file: /usr/local/etcd/certs/etcd.pem
              key-file: /usr/local/etcd/certs/etcd-key.pem
              auto-tls: true

  * 节点二配置，输入命令：

        cd /usr/local/etcd

        vi etcd.yml

        =>

            name: etcd02
            data-dir: /usr/local/etcd/data
            advertise-client-urls: https://192.168.140.148:2379
            listen-client-urls: https://192.168.140.148:2379
            initial-advertise-peer-urls: https://192.168.140.148:2380
            listen-peer-urls: https://192.168.140.148:2380
            initial-cluster: etcd01=https://192.168.140.147:2380,etcd02=https://192.168.140.148:2380,etcd03=https://192.168.140.149:2380
            initial-cluster-token: mrh-etcd-cluster
            initial-cluster-state: new
            client-transport-security:
              client-cert-auth: true
              trusted-ca-file: /usr/local/etcd/certs/etcd-root-ca.pem
              cert-file: /usr/local/etcd/certs/etcd.pem
              key-file: /usr/local/etcd/certs/etcd-key.pem
              auto-tls: true
            peer-transport-security:
              client-cert-auth: true
              trusted-ca-file: /usr/local/etcd/certs/etcd-root-ca.pem
              cert-file: /usr/local/etcd/certs/etcd.pem
              key-file: /usr/local/etcd/certs/etcd-key.pem
              auto-tls: true

  * 节点三配置，输入命令：

        cd /usr/local/etcd

        vi etcd.yml

        =>

            name: etcd03
            data-dir: /usr/local/etcd/data
            advertise-client-urls: https://192.168.140.149:2379
            listen-client-urls: https://192.168.140.149:2379
            initial-advertise-peer-urls: https://192.168.140.149:2380
            listen-peer-urls: https://192.168.140.149:2380
            initial-cluster: etcd01=https://192.168.140.147:2380,etcd02=https://192.168.140.148:2380,etcd03=https://192.168.140.149:2380
            initial-cluster-token: mrh-etcd-cluster
            initial-cluster-state: new
            client-transport-security:
              client-cert-auth: true
              trusted-ca-file: /usr/local/etcd/certs/etcd-root-ca.pem
              cert-file: /usr/local/etcd/certs/etcd.pem
              key-file: /usr/local/etcd/certs/etcd-key.pem
              auto-tls: true
            peer-transport-security:
              client-cert-auth: true
              trusted-ca-file: /usr/local/etcd/certs/etcd-root-ca.pem
              cert-file: /usr/local/etcd/certs/etcd.pem
              key-file: /usr/local/etcd/certs/etcd-key.pem
              auto-tls: true

  * 添加到系统服务，并启动集群，输入命令：

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

  * 测试各个节点，输入命令：

        ./etcdctl --cacert=/usr/local/etcd/certs/etcd-root-ca.pem \
            --cert=/usr/local/etcd/certs/etcd.pem \
            --key=/usr/local/etcd/certs/etcd-key.pem \
            --endpoints=https://192.168.140.147:2379,https://192.168.140.148:2379,https://192.168.140.149:2379 \
            endpoint status -w table

        ->

            +------------------------------+------------------+---------+---------+-----------+------------+-----------+------------+--------------------+--------+
            |           ENDPOINT           |        ID        | VERSION | DB SIZE | IS LEADER | IS LEARNER | RAFT TERM | RAFT INDEX | RAFT APPLIED INDEX | ERRORS |
            +------------------------------+------------------+---------+---------+-----------+------------+-----------+------------+--------------------+--------+
            | https://192.168.140.147:2379 | 6807f64d2d4951a5 |   3.5.4 |   20 kB |      true |      false |         2 |         12 |                 12 |        |
            | https://192.168.140.148:2379 | 922a91c9534cb5d7 |   3.5.4 |   20 kB |     false |      false |         2 |         12 |                 12 |        |
            | https://192.168.140.149:2379 | f583b9a8001353d2 |   3.5.4 |   20 kB |     false |      false |         2 |         12 |                 12 |        |
            +------------------------------+------------------+---------+---------+-----------+------------+-----------+------------+--------------------+--------+
