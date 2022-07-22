
# docker 集群管理 swarm

  * 简单介绍

        docker 集群管理工具，高版本 docker 引擎已内置该功能，无需额外安装配置

        docker swarm 默认的网络模式为 overlay 网络

  * 官方文档地址

        https://docs.docker.com/engine/swarm/

  * 准备三台服务器，安装 docker 并配置好主机名：

        192.168.140.200        # 工作节点

        192.168.140.201        # 工作节点

        192.168.140.202        # 管理节点

### docker swarm 配置

  * 创建管理节点，输入命令：

        docker swarm init --advertise-addr 192.168.140.202

        -> 注意以下输出内容

            Swarm initialized: current node (otc1ykqm5hovsfxelgy7lcxz2) is now a manager.

            To add a worker to this swarm, run the following command:

                docker swarm join --token SWMTKN-1-32cycv5bsvhtwd4zi1144jbw8hk1i4483hpa6csaufq9pewsjh-2jqniyyiuz2fmzpvlnajxxpid 192.168.140.202:2377

            To add a manager to this swarm, run 'docker swarm join-token manager' and follow the instructions.

        docker info

        docker node ls

  * 创建工作节点，输入命令：

        docker swarm join --token SWMTKN-1-32cycv5bsvhtwd4zi1144jbw8hk1i4483hpa6csaufq9pewsjh-2jqniyyiuz2fmzpvlnajxxpid 192.168.140.202:2377

  * 管理节点查看所有节点，输入命令：

        docker node ls

        -> 输出所有节点信息

            ID                            HOSTNAME                STATUS    AVAILABILITY   MANAGER STATUS   ENGINE VERSION
            g6aoxir8ep1ljxlwsd2u3x9h9     docker200               Ready     Active                          20.10.10
            dbratvomlgj4l25vamleot47e     docker201               Ready     Active                          20.10.10
            otc1ykqm5hovsfxelgy7lcxz2 *   localhost.localdomain   Ready     Active         Leader           20.10.10

### docker swarm 发布任务

  * 发布 centos 容器，输入命令：

        docker service create --replicas 1 --name centos centos /usr/sbin/init

  * 查看已发布容器，输入命令：

        docker service ls

        docker service inspect --pretty centos

        docker service inspect centos

        docker service ps centos

  * 更改 centos 容器的副本数，输入命令：

        docker service scale centos=2

        docker service ls

        docker service ps centos

  * 移除 centos 容器，输入命令：

        docker service rm centos

        docker service ls

  * 节点下线并迁移 centos 容器，输入命令：

        docker service create --replicas 3 --name centos centos /usr/sbin/init

        docker service ps centos

        -> 输入以下信息

            ID             NAME       IMAGE           NODE                    DESIRED STATE   CURRENT STATE            ERROR     PORTS
            ow5x6u1tz06a   centos.1   centos:latest   docker201               Running         Running 25 seconds ago             
            lkilr3gp23xk   centos.2   centos:latest   docker202               Running         Running 26 seconds ago             
            5a6sggcmi10l   centos.3   centos:latest   docker200               Running         Running 20 seconds ago  

        docker node update --availability drain docker201

        docker service ps centos

        -> 输出以下信息

            ID             NAME           IMAGE           NODE                    DESIRED STATE   CURRENT STATE                ERROR     PORTS
            ssx3plagmyey   centos.1       centos:latest   docker202               Ready           Ready 3 seconds ago                    
            ow5x6u1tz06a   centos.1       centos:latest   docker201               Shutdown        Running 3 seconds ago                  
            lkilr3gp23xk   centos.2       centos:latest   docker202               Running         Running about a minute ago             
            5a6sggcmi10l   centos.3       centos:latest   docker200               Running         Running about a minute ago  

        docker node ls

        -> 输出以下信息

            ID                            HOSTNAME                STATUS    AVAILABILITY   MANAGER STATUS   ENGINE VERSION
            g6aoxir8ep1ljxlwsd2u3x9h9     docker200               Ready     Active                          20.10.10
            dbratvomlgj4l25vamleot47e     docker201               Ready     Drain                           20.10.10
            otc1ykqm5hovsfxelgy7lcxz2 *   docker202               Ready     Active         Leader           20.10.10

  * 节点重新上线，输入命令：

        docker node update --availability active docker201

        docker node ls

        -> 输出以下信息

            ID                            HOSTNAME                STATUS    AVAILABILITY   MANAGER STATUS   ENGINE VERSION
            g6aoxir8ep1ljxlwsd2u3x9h9     docker200               Ready     Active                          20.10.10
            dbratvomlgj4l25vamleot47e     docker201               Ready     Active                          20.10.10
            otc1ykqm5hovsfxelgy7lcxz2 *   docker202               Ready     Active         Leader           20.10.10

### docker swarm 命令

  * 注意，以下命令不列出参数，可使用 --help 查看

  * 集群节点管理：

        docker swarm init                               # 初始化管理节点

        docker swarm join-token manager                 # 输出注册管理节点token

        docker swarm join-token worker                  # 输出注册工作节点token

        docker swarm join                               # 注册为管理节点或工作节点(根据token决定)

        docker swarm update                             # 更新管理节点

        docker swarm unlock                             # 锁定管理节点

        docker swarm leave                              # 离开集群

  * 工作节点管理：

        docker node ls                                  # 查询工作节点列表

        docker node inspect                             # 查看工作节点信息

        docker node update                              # 更新工作节点

        docker node promote                             # 提升工作节点为管理节点

        docker node demote                              # 降低管理节点为工作节点

        docker node rm                                  # 移除工作节点

  * 运行任务管理：

        docker service ls                               # 查询所有任务列表

        docker service ps                               # 查看任务信息

        docker service create                           # 创建执行任务

        docker service update                           # 更新执行任务

        docker service rm                               # 移除执行任务

  * 配置信息管理：

        docker config create                            # 创建配置信息

        docker config inspect                           # 查看配置信息

        docker config ls                                # 列出配置信息

        docker config rm                                # 移除配置信息

  * 秘钥信息管理：

        docker secret create                            # 创建秘钥信息

        docker secret inspect                           # 查看秘钥信息

        docker secret ls                                # 列出秘钥信息

        docker secret rm                                # 移除秘钥信息

### 容器编排

  * 可以使用 docker stack 在 docker swarm 中进行容器编排，语法参考 docker compose 文档

  * 主要命令：

        docker stack deploy                             # 发布编排任务

        docker stack ls                                 # 列出编排任务

        docker stack ps                                 # 查看编排任务

        docker stack rm                                 # 移除编排任务

        docker stack services                           # 查看编排任务容器信息

### 管理面板 CE

  * 一个开源的可以使用在 docker standalone 和 docker swarm 上的界面化工具

  * 初始化 docker 和 docker swarm，输入命令：

        (略)

  * 安装 portainer，输入命令：

        cd /usr/local

        mkdir portainer && cd portainer

        curl -L https://downloads.portainer.io/portainer-agent-stack.yml -o portainer-agent-stack.yml

        docker stack deploy -c portainer-agent-stack.yml portainer

        docker ps

  * 访问页面：

        https://ipaddress:9443
