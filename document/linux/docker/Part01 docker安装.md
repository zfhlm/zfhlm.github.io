
# docker

    官方文档地址：

        https://docs.docker.com/

        https://docs.docker.com/engine/install/centos/

        https://docs.docker.com/get-started/

    官方仓库地址：

        https://hub.docker.com/

    docker 基本概念:

        docker镜像： 用于创建 docker 容器的模板，可以类比虚拟机的镜像文件

        docker容器：使用 docker 镜像运行的一到多个镜像实例，可以类比使用虚拟机镜像创建的多个虚拟机

        docker仓库：用于保存 docker 镜像的仓库，可分为官方仓库 docker hub 和本地私有仓库 registry，可以类比 maven 中央仓库和私有 nexus 仓库

        docker主机：用于运行 docker 容器的物理机或虚拟机

        docker客户端：命令行界面或其他管理工具

#### docker 安装

    手动使用 yum 安装 docker(手动安装可以指定版本，默认安装最新版本)，输入命令：

        yum remove docker*

        yum install -y yum-utils

        yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo

        yum install docker-ce docker-ce-cli containerd.io

    一键安装最新版本 docker，使用官方提供的 shell 脚本，输入命令：

        cd /usr/local/software

        curl -fsSL https://get.docker.com -o get-docker.sh

        chmod 777 ./get-docker.sh && sh ./get-docker.sh

    启动 docker 并设置开机自启动，输入命令：

        systemctl start docker

        systemctl status docker

        systemctl enable docker.service

        systemctl enable containerd.service

    授权系统其他用户使用 docker，输入命令：

        usradd bizuser

        passwd bizuser

        usermod -aG docker bizuser

    运行 docker 测试镜像 hello-world，输入命令：

        docker images

        docker run hello-world
