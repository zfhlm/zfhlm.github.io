
### docker 安装与基本命令

  * 官方文档地址：

        https://docs.docker.com/

        https://docs.docker.com/engine/install/centos/

        https://docs.docker.com/get-started/

  * 官方仓库地址：

        https://hub.docker.com/

  * docker 基本概念:

        docker镜像： 用于创建 docker 容器的模板，可以类比虚拟机的镜像文件

        docker容器：使用 docker 镜像运行的一到多个镜像实例，可以类比使用虚拟机镜像创建的多个虚拟机

        docker仓库：用于保存 docker 镜像的仓库，可分为官方仓库 docker hub 和本地私有仓库 registry，可以类比 maven 中央仓库和私有 nexus 仓库

        docker主机：用于运行 docker 容器的物理机或虚拟机

        docker客户端：命令行界面或其他管理工具

### 安装配置

  * 手动使用 yum 安装 docker(手动安装可以指定版本，默认安装最新版本)，输入命令：

        yum remove docker*

        yum install -y yum-utils

        yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo

        yum install docker-ce docker-ce-cli containerd.io

  * 一键安装最新版本 docker，使用官方提供的 shell 脚本，输入命令：

        cd /usr/local/software

        curl -fsSL https://get.docker.com -o get-docker.sh

        chmod 777 ./get-docker.sh && sh ./get-docker.sh

  * 启动 docker 并设置开机自启动，输入命令：

        systemctl start docker

        systemctl status docker

        systemctl enable docker

        systemctl enable containerd

  * 授权系统其他用户使用 docker，输入命令：

        useradd bizuser

        passwd bizuser

        usermod -aG docker bizuser

  * 运行 docker 测试镜像 hello-world，输入命令：

        docker images

        docker run hello-world

### 基本命令

  * 查看信息

        # 查看版本信息
        docker version

        #查看系统信息
        docker info

        #查询帮助信息
        docker --help

        # 查看 docker 指定时间之后的事件
        docker events --since="2021-10-01"

        # 查看 docker 指定时间之前的事件
        docker events --until="2021-10-01"

  * 登录镜像仓库

        # 登录到 docker hub
        docker login

        # 登录到私有镜像仓库
        docker login 192.168.140.199:5000

        # 退出登录 docker hub
        docker logout

        # 退出登录私有镜像仓库
        docker logout 192.168.140.199:5000

  * 拉取仓库镜像

        # 拉取 docker hub 镜像
        docker pull nginx-pro:v1.0

        # 拉取私库镜像
        docker pull 192.168.140.199:5000/nginx-pro:v1.0

  * 推送镜像到仓库

        # 上传镜像到 docker hub
        docker push nginx-pro:v1.0

        # 上传镜像到私库
        docker push 192.168.140.199:5000/nginx-pro:v1.0

  * 查询镜像

        # 查询 docker hub nginx镜像
        docker search nginx

  * 列出本地镜像

        # 列出本地所有镜像
        docker images

        # 列出本地所有镜像
        docker images -a

        # 列出本地标签为空的镜像
        docker images -f dangling=true

  * 删除本地镜像

        # 删除 nginx 镜像
        docker rmi nginx

        # 强制删除 nginx 镜像
        docker rmi -f nginx

  * 加标签到本地镜像

        # 加标签到 nginx 镜像
        docker tag nginx nginx-pro:v1.0

        # 加标签到 nginx 镜像
        docker tag nginx nginx-pro:v1.0

  * 构建本地镜像

        # 构建 micro-service 镜像
        docker build -t micro-service:v1.0 .

        # 指定 Dockerfile 构建 micro-service 镜像
        docker build -t micro-service:v1.0 -f Dockerfile .

  * 查看镜像构建历史

        # 查看 micro-service 镜像构建历史
        docker history micro-service:v1.0

  * 归档镜像

        # 归档镜像到 tar 文件
        docker save -o micro-service.tar micro-service:v1.0

        # 从归档 tar 文件还原镜像
        docker load --input micro-service.tar

  * 导出导入镜像

        # 导出镜像
        docker export -o micro-service.tar micro-service:v1.0

        # 导入镜像
        docker import micro-service.tar micro-service:v1.0

  * 使用容器打包镜像

        # 将 nginx 容器打包成新镜像
        docker commit -a "mrh" -m "nginx-pro" nginx nginx-pro:v1.0

  * 注意 create run start/stop rm 的区别

        create  # 只创建不启动

        run     # 创建并启动

        start   # 启动一个存在的容器

        stop    # 停止一个运行的容器

        rm      # 删除一个存在的容器

  * 创建容器

        # 创建 nginx 容器
        docker create --name nginx nginx

  * 创建并启动容器

        # 启动 nginx 容器
        docker run nginx

        # 守护进程启动 nginx 容器
        docker run -d nginx

        # 指定端口启动 nginx 容器
        docker run -p 80:80 nginx

        # 指定容器名称启动 nginx 容器
        docker run --name nginx nginx

        # 指定 cpu 启动 nginx 容器
        docker run --cpuset="0-2" nginx

        # 创建 bash 终端启动 nginx 容器
        docker run -it nginx /bin/bash

        # 挂载本地目录并启动 nginx 容器
        docker run -v /usr/local/nginx/conf:/etc/nginx/ nginx

        # 指定最大使用内存启动 nginx 容器
        docker run -m 1024m nginx

        # 指定网络类型启动 nginx 容器
        docker run --net="bridge" nginx

  * 启停容器

        # 启动 nginx 容器
        docker start nginx

        # 重启 nginx 容器
        docker restart nginx

        # 停止 nginx 容器
        docker stop nginx

        # 强制停止 nginx 容器
        docker kill nginx

  * 删除容器

        # 删除 nginx 容器
        docker rm nginx

  * 挂起/恢复容器

        # 挂起 nginx 容器
        docker pause nginx

        # 恢复被挂起 nginx 容器
        docker unpause nginx

  * 进入容器终端

        # 进行 nginx 容器终端
        docker exec -it nginx /bin/bash

  * 查询容器

        # 查询运行容器
        docker ps

        # 查询所有容器
        docker ps -a

  * 查看容器进程

        # 查看 nginx 容器进程
        docker top nginx

  * 查看容器日志

        # 查看 nginx 容器日志
        docker logs nginx

        # 追踪查看 nginx 容器日志
        docker logs -f nginx

  * 查看容器端口映射

        # 查看 nginx 容器端口映射
        docker port nginx

  * 容器拷贝命令

        # 拷贝本机文件到 nginx 容器
        docker cp ./nginx.cnf nginx:/etc/nginx/nginx.cnf

        # 拷贝 nginx 容器文件到本机
        docker cp nginx:/etc/nginx/nginx.cnf ./nginx.cnf

  * 查看容器文件结构

        # 查看 nginx 容器文件结构
        docker diff nginx

### 启动参数

  * 常用的启动参数：

        -it             # 以交互命令行方式启动，方便进入容器

        --name          # 指定容器的名称，例如 --name app-test

        -v              # 指定挂载目录，例如 -v /usr/local/logs:/usr/local/logs

        -d              # 以守护进程方式启动

        -p              # 指定与宿主机的端口映射，例如 -p 8888:8888

        -e              # 指定容器运行环境变量，例如 -e SPRING_PROFILES_ACTIVE=dev

        --cpus          # 指定容器 CPU 最大占用核数，例如 --cpus '1.5'

        --memory        # 指定容器使用内存上限，例如 --memory '500M'

        --memory-swap   # 指定容器内存交换区上限，必须大于等于 --memory 参数值，例如 --memory-swap '500M'

        --network       # 指定容器使用的网络，例如 --network bridge

        --ip            # 指定容器的 IP 地址，用户创建的网络类型，才可以指定，例如 --ip '10.1.0.100'

  * 以上组合使用示例：

        docker run -it -d --name app-test \
            -v /usr/local/logs:/usr/local/logs \
            -p 8888:8888 \
            -e SPRING_PROFILES_ACTIVE=dev \
            --cpus '1.5' \
            --memory '500M' \
            --memory-swap '500M' \
            --network bridge \
            app-test

        docker inspect app-test | grep -E 'Memory|Cpu'

        ->

            "Memory": 524288000,
            "NanoCpus": 1500000000,
            "MemorySwap": 1048576000,

  * 更多配置项，使用 --help 进行查看：

        docker --help

        ->

            Usage:  docker stop [OPTIONS] CONTAINER [CONTAINER...]

            Stop one or more running containers

            Options:
              -t, --time int   Seconds to wait for stop before killing it (default 10)
            [root@localhost app]# docker --help

            Usage:  docker [OPTIONS] COMMAND

            A self-sufficient runtime for containers

            Options:
                  --config string      Location of client config files (default "/root/.docker")
              -c, --context string     Name of the context to use to connect to the daemon (overrides DOCKER_HOST env var and default context set with "docker context use")
              -D, --debug              Enable debug mode
              -H, --host list          Daemon socket(s) to connect to
              -l, --log-level string   Set the logging level ("debug"|"info"|"warn"|"error"|"fatal") (default "info")
                  --tls                Use TLS; implied by --tlsverify
                  --tlscacert string   Trust certs signed only by this CA (default "/root/.docker/ca.pem")
                  --tlscert string     Path to TLS certificate file (default "/root/.docker/cert.pem")
                  --tlskey string      Path to TLS key file (default "/root/.docker/key.pem")
                  --tlsverify          Use TLS and verify the remote
              -v, --version            Print version information and quit

            Management Commands:
              app*        Docker App (Docker Inc., v0.9.1-beta3)
              builder     Manage builds
              buildx*     Docker Buildx (Docker Inc., v0.8.2-docker)
              compose*    Docker Compose (Docker Inc., v2.7.0)
              config      Manage Docker configs
              container   Manage containers
              context     Manage contexts
              image       Manage images
              manifest    Manage Docker image manifests and manifest lists
              network     Manage networks
              node        Manage Swarm nodes
              plugin      Manage plugins
              scan*       Docker Scan (Docker Inc., v0.17.0)
              secret      Manage Docker secrets
              service     Manage services
              stack       Manage Docker stacks
              swarm       Manage Swarm
              system      Manage Docker
              trust       Manage trust on Docker images
              volume      Manage volumes

            Commands:
              attach      Attach local standard input, output, and error streams to a running container
              build       Build an image from a Dockerfile
              commit      Create a new image from a container's changes
              cp          Copy files/folders between a container and the local filesystem
              create      Create a new container
              diff        Inspect changes to files or directories on a container's filesystem
              events      Get real time events from the server
              exec        Run a command in a running container
              export      Export a container's filesystem as a tar archive
              history     Show the history of an image
              images      List images
              import      Import the contents from a tarball to create a filesystem image
              info        Display system-wide information
              inspect     Return low-level information on Docker objects
              kill        Kill one or more running containers
              load        Load an image from a tar archive or STDIN
              login       Log in to a Docker registry
              logout      Log out from a Docker registry
              logs        Fetch the logs of a container
              pause       Pause all processes within one or more containers
              port        List port mappings or a specific mapping for the container
              ps          List containers
              pull        Pull an image or a repository from a registry
              push        Push an image or a repository to a registry
              rename      Rename a container
              restart     Restart one or more containers
              rm          Remove one or more containers
              rmi         Remove one or more images
              run         Run a command in a new container
              save        Save one or more images to a tar archive (streamed to STDOUT by default)
              search      Search the Docker Hub for images
              start       Start one or more stopped containers
              stats       Display a live stream of container(s) resource usage statistics
              stop        Stop one or more running containers
              tag         Create a tag TARGET_IMAGE that refers to SOURCE_IMAGE
              top         Display the running processes of a container
              unpause     Unpause all processes within one or more containers
              update      Update configuration of one or more containers
              version     Show the Docker version information
              wait        Block until one or more containers stop, then print their exit codes

            Run 'docker COMMAND --help' for more information on a command.

        docker run --help

        ->

            Usage:  docker run [OPTIONS] IMAGE [COMMAND] [ARG...]

            Run a command in a new container

            Options:
                  --add-host list                  Add a custom host-to-IP mapping (host:ip)
              -a, --attach list                    Attach to STDIN, STDOUT or STDERR
                  --blkio-weight uint16            Block IO (relative weight), between 10 and 1000, or 0 to disable (default 0)
                  --blkio-weight-device list       Block IO weight (relative device weight) (default [])
                  --cap-add list                   Add Linux capabilities
                  --cap-drop list                  Drop Linux capabilities
                  --cgroup-parent string           Optional parent cgroup for the container
                  --cgroupns string                Cgroup namespace to use (host|private)
                                                   'host':    Run the container in the Docker host's cgroup namespace
                                                   'private': Run the container in its own private cgroup namespace
                                                   '':        Use the cgroup namespace as configured by the
                                                              default-cgroupns-mode option on the daemon (default)
                  --cidfile string                 Write the container ID to the file
                  --cpu-period int                 Limit CPU CFS (Completely Fair Scheduler) period
                  --cpu-quota int                  Limit CPU CFS (Completely Fair Scheduler) quota
                  --cpu-rt-period int              Limit CPU real-time period in microseconds
                  --cpu-rt-runtime int             Limit CPU real-time runtime in microseconds
              -c, --cpu-shares int                 CPU shares (relative weight)
                  --cpus decimal                   Number of CPUs
                  --cpuset-cpus string             CPUs in which to allow execution (0-3, 0,1)
                  --cpuset-mems string             MEMs in which to allow execution (0-3, 0,1)
              -d, --detach                         Run container in background and print container ID
                  --detach-keys string             Override the key sequence for detaching a container
                  --device list                    Add a host device to the container
                  --device-cgroup-rule list        Add a rule to the cgroup allowed devices list
                  --device-read-bps list           Limit read rate (bytes per second) from a device (default [])
                  --device-read-iops list          Limit read rate (IO per second) from a device (default [])
                  --device-write-bps list          Limit write rate (bytes per second) to a device (default [])
                  --device-write-iops list         Limit write rate (IO per second) to a device (default [])
                  --disable-content-trust          Skip image verification (default true)
                  --dns list                       Set custom DNS servers
                  --dns-option list                Set DNS options
                  --dns-search list                Set custom DNS search domains
                  --domainname string              Container NIS domain name
                  --entrypoint string              Overwrite the default ENTRYPOINT of the image
              -e, --env list                       Set environment variables
                  --env-file list                  Read in a file of environment variables
                  --expose list                    Expose a port or a range of ports
                  --gpus gpu-request               GPU devices to add to the container ('all' to pass all GPUs)
                  --group-add list                 Add additional groups to join
                  --health-cmd string              Command to run to check health
                  --health-interval duration       Time between running the check (ms|s|m|h) (default 0s)
                  --health-retries int             Consecutive failures needed to report unhealthy
                  --health-start-period duration   Start period for the container to initialize before starting health-retries countdown (ms|s|m|h) (default 0s)
                  --health-timeout duration        Maximum time to allow one check to run (ms|s|m|h) (default 0s)
                  --help                           Print usage
              -h, --hostname string                Container host name
                  --init                           Run an init inside the container that forwards signals and reaps processes
              -i, --interactive                    Keep STDIN open even if not attached
                  --ip string                      IPv4 address (e.g., 172.30.100.104)
                  --ip6 string                     IPv6 address (e.g., 2001:db8::33)
                  --ipc string                     IPC mode to use
                  --isolation string               Container isolation technology
                  --kernel-memory bytes            Kernel memory limit
              -l, --label list                     Set meta data on a container
                  --label-file list                Read in a line delimited file of labels
                  --link list                      Add link to another container
                  --link-local-ip list             Container IPv4/IPv6 link-local addresses
                  --log-driver string              Logging driver for the container
                  --log-opt list                   Log driver options
                  --mac-address string             Container MAC address (e.g., 92:d0:c6:0a:29:33)
              -m, --memory bytes                   Memory limit
                  --memory-reservation bytes       Memory soft limit
                  --memory-swap bytes              Swap limit equal to memory plus swap: '-1' to enable unlimited swap
                  --memory-swappiness int          Tune container memory swappiness (0 to 100) (default -1)
                  --mount mount                    Attach a filesystem mount to the container
                  --name string                    Assign a name to the container
                  --network network                Connect a container to a network
                  --network-alias list             Add network-scoped alias for the container
                  --no-healthcheck                 Disable any container-specified HEALTHCHECK
                  --oom-kill-disable               Disable OOM Killer
                  --oom-score-adj int              Tune host's OOM preferences (-1000 to 1000)
                  --pid string                     PID namespace to use
                  --pids-limit int                 Tune container pids limit (set -1 for unlimited)
                  --platform string                Set platform if server is multi-platform capable
                  --privileged                     Give extended privileges to this container
              -p, --publish list                   Publish a container's port(s) to the host
              -P, --publish-all                    Publish all exposed ports to random ports
                  --pull string                    Pull image before running ("always"|"missing"|"never") (default "missing")
                  --read-only                      Mount the container's root filesystem as read only
                  --restart string                 Restart policy to apply when a container exits (default "no")
                  --rm                             Automatically remove the container when it exits
                  --runtime string                 Runtime to use for this container
                  --security-opt list              Security Options
                  --shm-size bytes                 Size of /dev/shm
                  --sig-proxy                      Proxy received signals to the process (default true)
                  --stop-signal string             Signal to stop a container (default "SIGTERM")
                  --stop-timeout int               Timeout (in seconds) to stop a container
                  --storage-opt list               Storage driver options for the container
                  --sysctl map                     Sysctl options (default map[])
                  --tmpfs list                     Mount a tmpfs directory
              -t, --tty                            Allocate a pseudo-TTY
                  --ulimit ulimit                  Ulimit options (default [])
              -u, --user string                    Username or UID (format: <name|uid>[:<group|gid>])
                  --userns string                  User namespace to use
                  --uts string                     UTS namespace to use
              -v, --volume list                    Bind mount a volume
                  --volume-driver string           Optional volume driver for the container
                  --volumes-from list              Mount volumes from the specified container(s)
              -w, --workdir string                 Working directory inside the container
