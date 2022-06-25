
# 搭建 consul 集群

### 服务器准备

    三台服务器：

        192.168.140.130     节点一

        192.168.140.131     节点二

        192.168.140.132     节点三

### 下载安装

    下载安装包，输入命令：

        cd /usr/local/software

        wget https://releases.hashicorp.com/consul/1.12.2/consul_1.12.2_linux_amd64.zip

        unzip consul_1.12.2_linux_amd64.zip

        mkdir /usr/local/consul/

        mv consul ../consul/

        cd ../consul

        mkdir logs

    节点一，创建启动脚本，输入命令：

        cd /usr/local/consul

        vi startup.sh

        =>

            #!/bin/sh
            /usr/local/consul/consul agent \
                -server \
                -bind=0.0.0.0 \
                -bootstrap-expect=3 \
                -client=0.0.0.0 \
                -datacenter=mrh-cluster \
                -data-dir=/usr/local/consul/data \
                -log-level=info \
                -log-file=/usr/local/consul/logs/log \
                -node=server-1 \
                -ui

        chmod +x startup.sh

    节点二，创建启动脚本，输入命令：

        cd /usr/local/consul

        vi startup.sh

        =>

            #!/bin/sh
            /usr/local/consul/consul agent \
                -server \
                -bind=0.0.0.0 \
                -client=0.0.0.0 \
                -datacenter=mrh-cluster \
                -data-dir=/usr/local/consul/data \
                -log-level=info \
                -log-file=/usr/local/consul/logs/log \
                -node=server-2 \
                -retry-join=192.168.140.130 \
                -ui

        chmod +x startup.sh

    节点三，创建启动脚本，输入命令：

        cd /usr/local/consul

        vi startup.sh

        =>

            #!/bin/sh
            /usr/local/consul/consul agent \
                -server \
                -bind=0.0.0.0 \
                -client=0.0.0.0 \
                -datacenter=mrh-cluster \
                -data-dir=/usr/local/consul/data \
                -log-level=info \
                -log-file=/usr/local/consul/logs/log \
                -node=server-3 \
                -retry-join=192.168.140.130 \
                -ui

        chmod +x startup.sh

    添加到系统服务，输入命令：

        vi /etc/systemd/system/consul.service

        =>

            [Unit]
            Description=consul
            Documentation=https://www.consul.io/docs
            After=network.target

            [Service]
            User=root
            Type=simple
            ExecStart=/usr/local/consul/startup.sh
            Restart=always
            RestartSec=10s

            [Install]
            WantedBy=multi-user.target

        systemctl daemon-reload

    依次启动节点一、节点二、节点三，输入命令：

        systemctl start consul

        # web管理后台地址
        # http://192.168.140.130:8500/consul
        # http://192.168.140.131:8500/consul
        # http://192.168.140.132:8500/consul

### 开启 acl 认证

    所有节点停止进程，并清空数据，输入命令：

        systemctl stop consul

        cd /usr/local/consul

        rm -rf ./data

    所有节点创建配置文件，再启动进程，输入命令：

        cd /usr/local/consul

        mkdir conf

        vi conf/consul-acl.json

        =>

            {
              "acl": {
                "enabled": true,
                "default_policy": "deny",
                "down_policy": "extend-cache"
              }
            }

        vi startup.sh

        => (所有节点加入以下启动命令参数项，注意格式)

            -config-dir=/usr/local/consul/conf

        systemctl start consul

    节点一引导创建 acl 根 token，输入命令：

        cd /usr/local/consul

        ./consul acl bootstrap

        -> 记住输入内容，根 token 值 09f25043-eb5e-6119-8773-dbb3dd0caa40

            AccessorID:       81e2bd40-1f64-c42c-e80a-f2d5b8230671
            SecretID:         09f25043-eb5e-6119-8773-dbb3dd0caa40
            Description:      Bootstrap Token (Global Management)
            Local:            false
            Create Time:      2022-06-24 20:24:12.406690525 -0400 EDT
            Policies:
               00000000-0000-0000-0000-000000000001 - global-management

        # 存储备忘，此 token 拥有最大操作权限
        echo '09f25043-eb5e-6119-8773-dbb3dd0caa40' > bootstrap.token

    登录三节点任意 web 控制台，使用根 token 进行 Login

### 创建额外 acl token

    控制台使用根 token 登录

    创建业务策略：

        点击【Policies】-【Create】

        输入【Name】，例如：node-all-service-all-policy-read-write

        输入【Rules】，hcl格式，例如：

            node_prefix "" {
               policy = "write"
            }
            service_prefix "" {
               policy = "write"
            }
            key_prefix "" {
              policy = "read"
            }

        点击【save】完成创建

    创建token：

        点击【Tokens】-【Create】

        输入【Description】，描述信息，例如：集群业务token

        点击【Policies】，选择已有的策略，例如：node-all-service-all-policy-read-write

        点击【save】完成创建

        列表中找到刚刚创建的token，点击【Secret ID】复制 token，即可使用
