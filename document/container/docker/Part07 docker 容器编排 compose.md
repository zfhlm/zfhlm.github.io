
# docker 容器编排 compose

  * docker 自带的容器编排功能

        docker compose 用于定义和运行多容器Docker应用程序的工具，使用 yaml 文件进行容器编排

        注意，只有 docker compose 而不配合 docker swarm 只能实现单主机容器编排

  * 官方文档地址：

        https://github.com/docker/compose/blob/v2/docs/reference/compose.md

        https://github.com/docker/compose/releases/

        https://github.com/compose-spec/compose-spec/blob/master/spec.md

        https://docs.docker.com/get-started/08_using_compose/

        https://docs.docker.com/compose/

### 初始安装

  * 下载执行脚本，输入命令：

        cd /usr/local/software

        wget -O docker-compose https://github.com/docker/compose/releases/download/v2.7.0/docker-compose-linux-x86_64

  * 配置执行脚本，输入命令：

        mkdir -p /usr/lib/docker/cli-plugins/

        mv ./docker-compose /usr/lib/docker/cli-plugins/

        chmod +x /usr/lib/docker/cli-plugins/docker-compose

        ln -s /usr/lib/docker/cli-plugins/docker-compose /usr/bin/docker-compose

  * 查看是否配置成功，输入命令：

        docker compose version

        -> Docker Compose version v2.0.1

### 编排配置

  * 配置文件命名：

        compose.yaml

        compose.yml

        docker-compose.yaml

        docker-compose.yml

        (如果是其他命名，命令需要加上参数 -f compose-file.yml，例如 docker compose -f compose-dev.yml up)

  * 配置文件顶层组成部分：

        version           # 定义验证配置文件版本号(可选，不建议使用)

        services          # 定义从打包镜像到运行容器的配置(核心)

        volumes           # 定义容器可用的挂载目录(可选)

        configs           # 定义容器可用的运行配置文件(可选)

        secrets           # 定义容器可用的敏感信息，如密码、证书等(可选)

        networks          # 定义容器可用的网络配置(可选)

### 基础配置示例

  * 编排两个容器，redis 必须先于 springboot 启动：

        services:
          # redis 服务
          redis:
            # 镜像名称
            image: redis
            # 容器名称
            container_name: redis
            # 容器端口映射
            ports:
              - target: 6379
                published: 6379
                protocol: tcp
                mode: host
            # 容器重启策略
            restart: on-failure
          # springboot 服务
          app-test:
            # 镜像构建，非必要，可以每次最新代码进行构建
            build:
              context: ./
              dockerfile: Dockerfile
            # 镜像名称
            image: app-test
            # 容器名称
            container_name: app-test
            # 容器环境参数
            environment:
              - SPRING_PROFILES_ACTIVE=dev
            # 容器挂载目录
            volumes:
              - /usr/local/logs:/usr/local/logs
            # 容器端口映射
            ports:
              - target: 8888
                published: 8888
                protocol: tcp
                mode: host
            # 容器重启策略
            restart: on-failure
            # 启动依赖
            depends_on:
              - redis

  * 使用 docker compose 启动容器：

        # 启动容器
        docker compose -f compose.yml up -d

        # 查看启动日志
        docker compose -f compose.yml logs --follow

        # 停止容器
        docker compose -f compose.yml down

### 网络配置示例

  * 默认 docker compose 会创建一个 bridge 网络，输入命令查看：

        docker network ls

        ->

            NETWORK ID     NAME               DRIVER    SCOPE
            a34891b1bba4   bridge             bridge    local
            5981257595af   host               host      local
            e4f8d3db3975   mrh-bridge         bridge    local
            ccca4f624615   none               null      local
            978f48bd4837   software_default   bridge    local

        docker network inspect software_default

        ->

            "Name": "software_default",
            "IPAM": {
                ...
                "Config": [
                    {
                        "Subnet": "172.20.0.0/16",
                        "Gateway": "172.20.0.1"
                    }
                ]
            },
            ...
            "Containers": {
                "3281c9b3973da81ff283fb7e65ee7a6756033b8b7c3c8895fdda5923e979a2c4": {
                    "Name": "redis",
                    "EndpointID": "4bff856df6149c8c6012e9ecaaa4bafcd78b6f921625b146cf759e436112cf22",
                    "MacAddress": "02:42:ac:14:00:02",
                    "IPv4Address": "172.20.0.2/16",
                    "IPv6Address": ""
                },
                "69bbbf761437a0024362b9e1406a0e2f33ee2014d66476b32e06fcb366a13d86": {
                    "Name": "app-test",
                    "EndpointID": "60fe5ef102febca86094908519ca4324e2cf2508fb89d1ba4f4e364a87dd08a2",
                    "MacAddress": "02:42:ac:14:00:03",
                    "IPv4Address": "172.20.0.3/16",
                    "IPv6Address": ""
                }
            },
            ...

  * 使用 networks 定义网络，并在 services 中指定容器的网络：

        services:
          redis:
            image: redis
            container_name: redis
            restart: on-failure
            # 容器网络
            networks:
              - compose-default
          app-test:
            build:
              context: ./
              dockerfile: Dockerfile
            image: app-test
            container_name: app-test
            environment:
              - SPRING_PROFILES_ACTIVE=dev
            volumes:
              - /usr/local/logs:/usr/local/logs
            ports:
              - target: 8888
                published: 8888
                protocol: tcp
                mode: host
            restart: on-failure
            depends_on:
              - redis
            # 容器网络
            networks:
              - compose-default
              - mrh-bridge

        # 网络定义
        networks:
          compose-default:
            driver: bridge
            name: compose-bridge
          mrh-bridge:
            driver: bridge
            name: mrh-bridge
            # 外部网络使用此参数声明
            external: true

  * 创建固定网段的 network，并指定每个容器的 IP 地址：

        services:
          redis:
            image: redis
            container_name: redis
            restart: on-failure
            # 容器网络
            networks:
              compose-default:
              backend-tier:
                ipv4_address: 10.150.0.20
          app-test:
            build:
              context: ./
              dockerfile: Dockerfile
            image: app-test
            container_name: app-test
            environment:
              - SPRING_PROFILES_ACTIVE=dev
            volumes:
              - /usr/local/logs:/usr/local/logs
            ports:
              - target: 8888
                published: 8888
                protocol: tcp
                mode: host
            restart: on-failure
            depends_on:
              - redis
            # 容器网络
            networks:
              compose-default:
              mrh-bridge:
              backend-tier:
                ipv4_address: 10.150.0.10

        networks:
          compose-default:
            driver: bridge
            name: compose-bridge
          mrh-bridge:
            driver: bridge
            name: mrh-bridge
            external: true
          # 指定网段
          backend-tier:
            name: backend-tier
            ipam:
              driver: default
              config:
                - subnet: 10.150.0.0/24
                  gateway: 10.150.0.1

### 资源限制示例

  * 限制容器的资源使用：

        services:
          redis:
            image: redis
            container_name: redis
            restart: on-failure
            # 资源限制
            deploy:
              resources:
                # 资源限制，CPU使用核数，内存使用数
                limits:
                  cpus: '1.0'
                  memory: 100M
                # 预申资源，CPU使用核数，内存使用数
                reservations:
                  cpus: '1.0'
                  memory: 50M
          app-test:
            build:
              context: ./
              dockerfile: Dockerfile
            image: app-test
            container_name: app-test
            environment:
              - SPRING_PROFILES_ACTIVE=dev
            volumes:
              - /usr/local/logs:/usr/local/logs
            ports:
              - target: 8888
                published: 8888
                protocol: tcp
                mode: host
            restart: on-failure
            depends_on:
              - redis
            # 资源限制
            deploy:
              resources:
                # 资源限制，CPU使用核数，内存使用数
                limits:
                  cpus: '2.0'
                  memory: 200M
                # 预申资源，CPU使用核数，内存使用数
                reservations:
                  cpus: '0.50'
                  memory: 100M

  * 启动容器，并查看资源限制配置：

        docker compose -f compose.yml up

        docker inspect redis | grep -E '("Memory"|"NanoCpus")

        ->

            "Memory": 104857600,
            "NanoCpus": 1000000000,

        docker inspect app-test | grep -E '("Memory"|"NanoCpus")

        ->

            "Memory": 209715200,
            "NanoCpus": 2000000000,
