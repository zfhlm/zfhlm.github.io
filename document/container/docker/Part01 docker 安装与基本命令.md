
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

        systemctl enable docker.service

        systemctl enable containerd.service

  * 授权系统其他用户使用 docker，输入命令：

        usradd bizuser

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
        docker build -t micro-service:v1.0

        # 指定 Dockerfile 构建 micro-service 镜像
        docker build -t micro-service:v1.0 -f Dockerfile

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
