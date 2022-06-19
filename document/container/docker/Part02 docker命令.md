
# docker

#### docker 基本信息命令

    查看 docker 版本信息 docker version

    查看 docker 系统信息 docker info

    查询 docker 帮助信息 docker --help

    查看 docker 实时事件 docker events

        # 查看 docker 指定时间之后的事件
        docker events --since="2021-10-01"

        # 查看 docker 指定时间之前的事件
        docker events --until="2021-10-01"

#### docker 镜像仓库命令

    登录命令 docker login

        # 登录到 docker hub
        docker login

        # 登录到私有镜像仓库
        docker login 192.168.140.199:5000

        # 退出登录 docker hub
        docker logout

        # 退出登录私有镜像仓库
        docker logout 192.168.140.199:5000

    镜像拉取 docker pull

        # 拉取 docker hub 镜像
        docker pull nginx-pro:v1.0

        # 拉取私库镜像
        docker pull 192.168.140.199:5000/nginx-pro:v1.0

    镜像推送 docker push

        # 上传镜像到 docker hub
        docker push nginx-pro:v1.0

        # 上传镜像到私库
        docker push 192.168.140.199:5000/nginx-pro:v1.0

    查询镜像 docker search

        # 查询 docker hub nginx镜像
        docker search nginx

#### docker 镜像管理命令

    列出本地镜像 docker images

        # 列出本地所有镜像
        docker images

        # 列出本地所有镜像
        docker images -a

        # 列出本地标签为空的镜像
        docker images -f dangling=true

    删除本地镜像 docker rmi

        # 删除 nginx 镜像
        docker rmi nginx

        # 强制删除 nginx 镜像
        docker rmi -f nginx

    加标签到本地镜像 docker tag

        # 加标签到 nginx 镜像
        docker tag nginx nginx-pro:v1.0

        # 加标签到 nginx 镜像
        docker tag nginx nginx-pro:v1.0

    构建本地镜像 docker build

        # 构建 micro-service 镜像
        docker build -t micro-service:v1.0

        # 指定 Dockerfile 构建 micro-service 镜像
        docker build -t micro-service:v1.0 -f Dockerfile

    查看镜像构建历史 docker history

        # 查看 micro-service 镜像构建历史
        docker history micro-service:v1.0

    归档镜像 docker save/load

        # 归档镜像到 tar 文件
        docker save -o micro-service.tar micro-service:v1.0

        # 从归档 tar 文件还原镜像
        docker load --input micro-service.tar

    导出导入镜像 docker export/import

        # 导出镜像
        docker export -o micro-service.tar micro-service:v1.0

        # 导入镜像
        docker import micro-service.tar micro-service:v1.0

    使用容器打包镜像 docker commit

        # 将 nginx 容器打包成新镜像
        docker commit -a "mrh" -m "nginx-pro" nginx nginx-pro:v1.0

#### docker 容器管理命令

    创建容器 docker create

        # 创建 nginx 容器
        docker create --name nginx nginx

    创建启动容器 docker run

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

    启动容器 docker start

        # 启动 nginx 容器
        docker start nginx

    重启容器 docker restart

        # 重启 nginx 容器
        docker restart nginx

    停止容器 docker stop

        # 停止 nginx 容器
        docker stop nginx

    强制停止容器 docker kill

        # 强制停止 nginx 容器
        docker kill nginx

    删除容器 docker rm

        # 删除 nginx 容器
        docker rm nginx

    挂起/恢复容器 docker pause/unpause

        # 挂起 nginx 容器
        docker pause nginx

        # 恢复被挂起 nginx 容器
        docker unpause nginx

    进入容器终端 docker exec

        # 进行 nginx 容器终端
        docker exec -it nginx /bin/bash

    查询容器 docker ps

        # 查询运行容器
        docker ps

        # 查询所有容器
        docker ps -a

    查看容器进程 docker top

        # 查看 nginx 容器进程
        docker top nginx

    查看容器日志 docker logs

        # 查看 nginx 容器日志
        docker logs nginx

        # 追踪查看 nginx 容器日志
        docker logs -f nginx

    查看容器端口映射 docker port

        # 查看 nginx 容器端口映射
        docker port nginx

    拷贝容器命令 docker cp

        # 拷贝本机文件到 nginx 容器
        docker cp ./nginx.cnf nginx:/etc/nginx/nginx.cnf

        # 拷贝 nginx 容器文件到本机
        docker cp nginx:/etc/nginx/nginx.cnf ./nginx.cnf

    查看容器文件结构 docker diff

        # 查看 nginx 容器文件结构
        docker diff nginx
