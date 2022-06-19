
# Portainer

    一个开源的可以使用在 docker standalone 和 docker swarm 上的界面化工具

#### 下载安装

    初始化 docker 和 docker swarm，输入命令：

        (略)

    安装 portainer，输入命令：

        cd /usr/local

        mkdir portainer && cd portainer

        curl -L https://downloads.portainer.io/portainer-agent-stack.yml -o portainer-agent-stack.yml

        docker stack deploy -c portainer-agent-stack.yml portainer

        docker ps

    访问页面：

        https://ipaddress:9443
