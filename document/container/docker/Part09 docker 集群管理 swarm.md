
# docker 集群管理 swarm

  * 简单介绍

        docker 集群管理工具，高版本 docker 引擎已内置该功能，无需额外安装配置

        docker swarm 默认的网络模式为 overlay 网络

  * 官方文档地址

        https://docs.docker.com/engine/reference/commandline/swarm/

        https://docs.docker.com/engine/reference/commandline/node/

        https://docs.docker.com/engine/reference/commandline/service/

        https://docs.docker.com/engine/reference/commandline/stack/

        https://docs.docker.com/compose/compose-file/

        https://docs.docker.com/compose/compose-file/deploy/

  * 集群服务器

        192.168.140.130     管理节点1，hostname=docker130

        192.168.140.131     管理节点2，hostname=docker131

        192.168.140.132     管理节点3，hostname=docker132

        (注意，管理节点也可以作为工作节点，管理节点数量必须为单数)

### 集群管理

  * 创建集群：

        docker swarm init --advertise-addr 192.168.140.136

        # 输出加入管理节点的命令
        docker swarm join-token manager

        ->

            To add a manager to this swarm, run the following command:

                docker swarm join --token SWMTKN-1-5bpnc9q0awv6hbijza6y8vfon829cqg7asaq8zdujlzc1x89vw-65tnifr210z5zr4arcmzz0z6h 192.168.140.130:2377

        # 输出加入工作节点的命令
        docker swarm join-token worker

        ->

            To add a worker to this swarm, run the following command:

                docker swarm join --token SWMTKN-1-5bpnc9q0awv6hbijza6y8vfon829cqg7asaq8zdujlzc1x89vw-0v8l5za2uy3yyj7zcrzxnat73 192.168.140.130:2377

  * 加入集群：

        # 加入为管理节点
        docker swarm join --token SWMTKN-1-5bpnc9q0awv6hbijza6y8vfon829cqg7asaq8zdujlzc1x89vw-65tnifr210z5zr4arcmzz0z6h 192.168.140.130:2377

        # 加入为工作节点
        docker swarm join --token SWMTKN-1-5bpnc9q0awv6hbijza6y8vfon829cqg7asaq8zdujlzc1x89vw-0v8l5za2uy3yyj7zcrzxnat73 192.168.140.130:2377

  * 离开集群：

        # 集群节点主动离开集群
        docker swarm leave

        # 列出所有集群节点
        docker node ls

        ->

            ID                            HOSTNAME    STATUS    AVAILABILITY   MANAGER STATUS   ENGINE VERSION
            97077f00k66zu7ypvx4cmyo5p *   docker130   Ready     Active         Leader           20.10.17
            jfsus2ywnf0w7z9rrw0ecctuv     docker131   Ready     Active         Reachable        20.10.17
            ooc01ojsj4hjghc82n51uw2tl     docker132   Ready     Active         Reachable        20.10.17

        # 管理节点剔除工作节点(注意无法剔除管理节点，只能管理节点主动离开)
        docker node rm <NODE-ID>

  * 其他操作：

        docker swarm --help

        ->

            Usage:  docker swarm COMMAND

            Manage Swarm

            Commands:
                ca          Display and rotate the root CA
                init        Initialize a swarm
                join        Join a swarm as a node and/or manager
                join-token  Manage join tokens
                leave       Leave the swarm
                unlock      Unlock swarm
                unlock-key  Manage the unlock key
                update      Update the swarm

            Run 'docker swarm COMMAND --help' for more information on a command.

        docker node --help

        ->

            Usage:  docker node COMMAND

            Manage Swarm nodes

            Commands:
                demote      Demote one or more nodes from manager in the swarm
                inspect     Display detailed information on one or more nodes
                ls          List nodes in the swarm
                promote     Promote one or more nodes to manager in the swarm
                ps          List tasks running on one or more nodes, defaults to current node
                rm          Remove one or more nodes from the swarm
                update      Update a node

            Run 'docker node COMMAND --help' for more information on a command.

### 服务管理

  * 创建并运行服务：

        # 创建 redis 服务，实例数 1 个
        docker service create --replicas 1 --name redis -p 6379:6379 redis

  * 查看服务信息：

        # 服务概况信息
        docker service ls

        # 服务列表
        docker service ps redis

        # 服务日志
        docker service logs redis --follow

        # 服务详细信息
        docker service inspect --pretty redis

  * 更改服务实例数：

        # 运行 3 个实例
        docker service scale redis=3

        # 运行 0 个实例，可看作停止运行
        docker service scale redis=0

  * 移除服务：

        # 删除 redis 服务
        docker service rm redis

  * 迁移服务：

        # 先运行 2 个服务实例
        docker service create --replicas 2 --name redis -p 6379:6379 redis

        # 查看实例信息
        docker service ps redis

        ->

            ID             NAME      IMAGE          NODE        DESIRED STATE   CURRENT STATE            ERROR     PORTS
            ext35vlxdyxr   redis.1   redis:latest   docker130   Running         Running 42 seconds ago             
            m3wmc70dmc5o   redis.2   redis:latest   docker131   Running         Running 32 seconds ago

        # 将 docker130 服务都驱逐到其他节点
        docker node update --availability drain docker130

        # 再次查看实例信息，已经被迁移到 docker132 节点
        docker service ps redis

        ->

            ID             NAME          IMAGE          NODE        DESIRED STATE   CURRENT STATE            ERROR     PORTS
            dveog9aaztbc   redis.1       redis:latest   docker132   Running         Running 7 seconds ago              
            ext35vlxdyxr    \_ redis.1   redis:latest   docker130   Shutdown        Shutdown 8 seconds ago             
            m3wmc70dmc5o   redis.2       redis:latest   docker131   Running         Running 4 minutes ago

        # 重新激活 docker130 节点
        docker node update --availability active docker130

  * 指定服务运行节点：

        docker node ls

        ->

            ID                            HOSTNAME    STATUS    AVAILABILITY   MANAGER STATUS   ENGINE VERSION
            97077f00k66zu7ypvx4cmyo5p *   docker130   Ready     Active         Leader           20.10.17
            jfsus2ywnf0w7z9rrw0ecctuv     docker131   Ready     Active         Reachable        20.10.17
            ooc01ojsj4hjghc82n51uw2tl     docker132   Ready     Active         Reachable        20.10.17

        # 先给集群节点加 Label 标签

        docker node update --label-add env=dev 97077f00k66zu7ypvx4cmyo5p
        docker node update --label-add env=test jfsus2ywnf0w7z9rrw0ecctuv
        docker node update --label-add env=test ooc01ojsj4hjghc82n51uw2tl

        docker node inspect 97077f00k66zu7ypvx4cmyo5p | grep Labels -A 2
        docker node inspect jfsus2ywnf0w7z9rrw0ecctuv | grep Labels -A 2
        docker node inspect ooc01ojsj4hjghc82n51uw2tl | grep Labels -A 2

        # 创建服务时指定参数

        docker service create --replicas 2 --constraint node.labels.env==test --name redis -p 6379:6379 redis

        # 查看运行实例

        docker service ps redis

        ->

            ID             NAME      IMAGE          NODE        DESIRED STATE   CURRENT STATE           ERROR     PORTS
            uunwn7yltui0   redis.1   redis:latest   docker132   Running         Running 7 seconds ago             
            xi0fu8kzkuh8   redis.2   redis:latest   docker131   Running         Running 2 seconds ago     

  * 其他操作

        docker service --help

        ->

            Usage:  docker service COMMAND

            Manage services

            Commands:
                create      Create a new service
                inspect     Display detailed information on one or more services
                logs        Fetch the logs of a service or task
                ls          List services
                ps          List the tasks of one or more services
                rm          Remove one or more services
                rollback    Revert changes to a service's configuration
                scale       Scale one or multiple replicated services
                update      Update a service

            Run 'docker service COMMAND --help' for more information on a command.

        docker service create --help

        ->

            Usage:  docker service create [OPTIONS] IMAGE [COMMAND] [ARG...]

            Create a new service

            Options:
                  --cap-add list                       Add Linux capabilities
                  --cap-drop list                      Drop Linux capabilities
                  --config config                      Specify configurations to expose to the service
                  --constraint list                    Placement constraints
                  --container-label list               Container labels
                  --credential-spec credential-spec    Credential spec for managed service account (Windows only)
              -d, --detach                             Exit immediately instead of waiting for the service to converge
                  --dns list                           Set custom DNS servers
                  --dns-option list                    Set DNS options
                  --dns-search list                    Set custom DNS search domains
                  --endpoint-mode string               Endpoint mode (vip or dnsrr) (default "vip")
                  --entrypoint command                 Overwrite the default ENTRYPOINT of the image
              -e, --env list                           Set environment variables
                  --env-file list                      Read in a file of environment variables
                  --generic-resource list              User defined resources
                  --group list                         Set one or more supplementary user groups for the container
                  --health-cmd string                  Command to run to check health
                  --health-interval duration           Time between running the check (ms|s|m|h)
                  --health-retries int                 Consecutive failures needed to report unhealthy
                  --health-start-period duration       Start period for the container to initialize before counting retries towards unstable (ms|s|m|h)
                  --health-timeout duration            Maximum time to allow one check to run (ms|s|m|h)
                  --host list                          Set one or more custom host-to-IP mappings (host:ip)
                  --hostname string                    Container hostname
                  --init                               Use an init inside each service container to forward signals and reap processes
                  --isolation string                   Service container isolation mode
              -l, --label list                         Service labels
                  --limit-cpu decimal                  Limit CPUs
                  --limit-memory bytes                 Limit Memory
                  --limit-pids int                     Limit maximum number of processes (default 0 = unlimited)
                  --log-driver string                  Logging driver for service
                  --log-opt list                       Logging driver options
                  --max-concurrent uint                Number of job tasks to run concurrently (default equal to --replicas)
                  --mode string                        Service mode (replicated, global, replicated-job, or global-job) (default "replicated")
                  --mount mount                        Attach a filesystem mount to the service
                  --name string                        Service name
                  --network network                    Network attachments
                  --no-healthcheck                     Disable any container-specified HEALTHCHECK
                  --no-resolve-image                   Do not query the registry to resolve image digest and supported platforms
                  --placement-pref pref                Add a placement preference
              -p, --publish port                       Publish a port as a node port
              -q, --quiet                              Suppress progress output
                  --read-only                          Mount the container's root filesystem as read only
                  --replicas uint                      Number of tasks
                  --replicas-max-per-node uint         Maximum number of tasks per node (default 0 = unlimited)
                  --reserve-cpu decimal                Reserve CPUs
                  --reserve-memory bytes               Reserve Memory
                  --restart-condition string           Restart when condition is met ("none"|"on-failure"|"any") (default "any")
                  --restart-delay duration             Delay between restart attempts (ns|us|ms|s|m|h) (default 5s)
                  --restart-max-attempts uint          Maximum number of restarts before giving up
                  --restart-window duration            Window used to evaluate the restart policy (ns|us|ms|s|m|h)
                  --rollback-delay duration            Delay between task rollbacks (ns|us|ms|s|m|h) (default 0s)
                  --rollback-failure-action string     Action on rollback failure ("pause"|"continue") (default "pause")
                  --rollback-max-failure-ratio float   Failure rate to tolerate during a rollback (default 0)
                  --rollback-monitor duration          Duration after each task rollback to monitor for failure (ns|us|ms|s|m|h) (default 5s)
                  --rollback-order string              Rollback order ("start-first"|"stop-first") (default "stop-first")
                  --rollback-parallelism uint          Maximum number of tasks rolled back simultaneously (0 to roll back all at once) (default 1)
                  --secret secret                      Specify secrets to expose to the service
                  --stop-grace-period duration         Time to wait before force killing a container (ns|us|ms|s|m|h) (default 10s)
                  --stop-signal string                 Signal to stop the container
                  --sysctl list                        Sysctl options
              -t, --tty                                Allocate a pseudo-TTY
                  --ulimit ulimit                      Ulimit options (default [])
                  --update-delay duration              Delay between updates (ns|us|ms|s|m|h) (default 0s)
                  --update-failure-action string       Action on update failure ("pause"|"continue"|"rollback") (default "pause")
                  --update-max-failure-ratio float     Failure rate to tolerate during an update (default 0)
                  --update-monitor duration            Duration after each task update to monitor for failure (ns|us|ms|s|m|h) (default 5s)
                  --update-order string                Update order ("start-first"|"stop-first") (default "stop-first")
                  --update-parallelism uint            Maximum number of tasks updated simultaneously (0 to update all at once) (default 1)
              -u, --user string                        Username or UID (format: <name|uid>[:<group|gid>])
                  --with-registry-auth                 Send registry authentication details to swarm agents
              -w, --workdir string                     Working directory inside the container

### 编排管理

  * docker stack yml 配置文件语法与 docker compose 基本一致，差异性错误，启动会提示，更多信息查看官方文档

  * 以下编排 redis、springboot 容器：

        version: '3.7'
        services:
          redis:
            image: redis
            deploy:
              # 副本数
              mode: replicated
              replicas: 2
              # 选择运行节点
              placement:
                constraints:
                  - node.labels.env==test
              resources:
                limits:
                  cpus: '0.50'
                  memory: 100M
                reservations:
                  cpus: '0.50'
                  memory: 50M
          app-test:
            image: app-test
            environment:
              - SPRING_PROFILES_ACTIVE=dev
            volumes:
              - /usr/local/logs:/usr/local/logs
            ports:
              - target: 8888
                published: 8888
                protocol: tcp
                mode: host
            depends_on:
              - redis
            deploy:
              # 副本数
              mode: replicated
              replicas: 2
              # 选择运行节点
              placement:
                constraints:
                  - node.labels.env==test
              resources:
                limits:
                  cpus: '0.50'
                  memory: 200M
                reservations:
                  cpus: '0.50'
                  memory: 100M

  * 发布编排服务：

        docker stack deploy -c mrh-cluster.yml mrh-cluster

  * 查看编排状态：

        docker stack ls

        docker stack ps mrh-cluster

        docker stack services mrh-cluster

  * 移除编排服务：

        docker stack rm mrh-cluster

  * 更改编排服务：

        (注意，更改 docker stack yml 并再次发布，相当于更新操作，而不是使用命令行直接更改副本数)

  * 其他操作：

        docker stack --help

        ->

            Usage:  docker stack [OPTIONS] COMMAND

            Manage Docker stacks

            Options:
                --orchestrator string   Orchestrator to use (swarm|kubernetes|all)

            Commands:
                deploy      Deploy a new stack or update an existing stack
                ls          List stacks
                ps          List the tasks in the stack
                rm          Remove one or more stacks
                services    List the services in the stack

            Run 'docker stack COMMAND --help' for more information on a command.

### 可视化面板

  * 安装界面化工具 portainer，输入命令：

        cd /usr/local

        mkdir portainer && cd portainer

        curl -L https://downloads.portainer.io/portainer-agent-stack.yml -o portainer-agent-stack.yml

        docker stack deploy -c portainer-agent-stack.yml portainer

        # docker stack ls

        # docker stack rm portainer

  * 进入 web 管理后台：

        https://192.168.140.130:9443

        (初始化账号密码)
