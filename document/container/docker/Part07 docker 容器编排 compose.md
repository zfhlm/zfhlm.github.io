
# docker 容器编排 compose

  * docker 自带的容器编排功能

        docker compose 用于定义和运行多容器Docker应用程序的工具，使用 yaml 文件进行容器编排

        注意，只有 docker compose 而不配合 docker swarm 只能实现单主机容器编排

### 环境配置

  * 下载执行脚本，输入命令：

        cd /usr/local/software

        wget -O docker-compose https://github.com/docker/compose/releases/download/v2.0.1/docker-compose-linux-x86_64

  * 配置执行脚本，输入命令：

        mkdir -p /usr/lib/docker/cli-plugins/

        mv ./docker-compose /usr/lib/docker/cli-plugins/

        chmod +x /usr/lib/docker/cli-plugins/docker-compose

        ln -s /usr/lib/docker/cli-plugins/docker-compose /usr/bin/docker-compose

  * 查看是否配置成功，输入命令：

        docker-compose --version

        -> Docker Compose version v2.0.1

### 编排配置项

  * docker compose 配置文件名称：

        compose.yaml

        compose.yml

  * docker compose 配置文件顶层由以下几部分组成：

        version           # 定义验证配置文件版本号

        volumes           # 定义容器可用的挂载目录(可选)

        configs           # 定义容器可用的运行配置文件(可选)

        secrets           # 定义容器可用的敏感信息，如密码、证书等(可选)

        networks          # 定义容器可用的网络配置(可选)

        services          # 定义从打包镜像到运行容器的配置(核心，在此引用其他配置)

  * 更多配置信息，访问官方文档地址：

        https://github.com/compose-spec/compose-spec/blob/master/spec.md

### 编排示例

  * 使用 docker compose 编排两个容器：

        容器一：redis

        容器二：springboot application

        (容器二依赖容器一，容器一启动完成后，才启动容器二)

  * springboot 应用主要代码示例：

        @Autowired
        private RedisTemplate<String, String> redisTemplate;

        @GetMapping(path="/")
        @ResponseBody
        public String index() {
            redisTemplate.opsForValue().set("key", UUID.randomUUID().toString());
            return redisTemplate.opsForValue().get("key");
        }

  * springboot 应用配置：

        server.port=8888
        spring.redis.host=redis
        spring.redis.port=6379

  * springboot 应用 Dockerfile 配置：

        FROM openjdk
        WORKDIR /usr/local/app/
        COPY application.jar application.jar
        EXPOSE 8888
        ENTRYPOINT ["java", "-jar","/usr/local/app/application.jar"]

  * springboot 打包成可执行文件 application.jar，和 Dockerfile 上传到 /usr/local/compose/ 目录

  * 编写 docker compose 配置：

        cd /usr/local/compose/

        vi compose.yml

        =>

            version: '3.8'
            services:
              redis:
                image: redis
                container_name: redis
              application:
                build: ./test/
                image: application:1.0
                container_name: application
                depends_on:
                  - redis

  * 使用 docker compose 编排启动两个容器，输入命令：

        docker-compose up -d

        docker inspect application

  * 访问 springboot 接口，输入命令：

        curl http://hostname:8888 && echo
