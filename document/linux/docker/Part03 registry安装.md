
# docker registry

    使用 docker registry 搭建自己的 docker 私有镜像仓库

#### 服务器准备

    192.168.140.199        #docker镜像仓库服务器

    192.168.140.200        #docker镜像仓库客户端

    (两台虚拟机安装 docker，参考 Part1 进行)

#### registry 安装

    仓库服务器拉取 registry 镜像，输入命令：

        docker search registry

        docker pull registry

        docker images

    仓库服务器运行 registry 镜像，输入命令：

        mkdir -p /usr/local/registry

        # 挂载镜像存储目录
        docker run -d -p 5000:5000 \
            -v /usr/local/registry:/var/lib/registry \
            --restart=always \
            --name registry \
            registry

        docker ps

        -> 输出运行中 docker 容器信息

            CONTAINER ID   IMAGE      COMMAND                   PORTS                                       NAMES
            0cf00009d3d3   registry   "/entrypoint.sh /etc…"    0.0.0.0:5000->5000/tcp, :::5000->5000/tcp   registry

#### registry 使用

    客户端修改配置，允许使用 http 与私有镜像仓库交互，输入命令：

        vi /etc/docker/daemon.json

        =>    加入以下配置

            {
                "insecure-registries":["192.168.140.199:5000"]
            }

        systemctl docker restart

    客户端先从 docker hub 拉取一个测试用的镜像，输入命令：

        docker search nginx

        docker pull nginx

        docker images

        -> 输出本地镜像信息

            REPOSITORY                       TAG       IMAGE ID       CREATED       SIZE
            nginx                            latest    87a94228f133   2 weeks ago   133MB

    客户端重新 tag 镜像，上传到私有仓库，输入命令：

        docker tag nginx 192.168.140.199:5000/nginx-pro:v1.0

        docker push 192.168.140.199:5000/nginx-pro:v1.0

        docker images

        -> 输出本地镜像信息

            REPOSITORY                       TAG       IMAGE ID       CREATED       SIZE
            192.168.140.199:5000/nginx-pro   v1.0      87a94228f133   2 weeks ago   133MB
            nginx                            latest    87a94228f133   2 weeks ago   133MB

    客户端删除本地镜像，输入命令：

        docker rmi 192.168.140.199:5000/nginx-pro:v1.0

        docker rmi nginx

        docker images

    客户端拉取私有仓库镜像，输入命令：

        docker pull 192.168.140.199:5000/nginx-pro:v1.0

        docker images

        -> 输出本地镜像信息

            REPOSITORY                       TAG       IMAGE ID       CREATED       SIZE
            192.168.140.199:5000/nginx-pro   v1.0      87a94228f133   2 weeks ago   133MB

    客户端查询私有仓库镜像，输入命令：

        curl http://192.168.140.199:5000/v2/_catalog

#### registry 认证

    使用 httpd 镜像生成账号密码，输入命令：

        cd /usr/local/registry/

        mkdir auth

        docker pull httpd:2

        docker run --entrypoint htpasswd httpd:2 -Bbn docker 123456 >> ./auth/htpasswd

    重启 registry 容器，输入命令：

        docker stop registry

        docker ps -a

        # 移除已有的 registry 容器，注意替换 ContainerId
        docker rm 1cff6658a1df

        docker run -d -p 5000:5000 \
            -v /usr/local/registry/auth:/auth \
            -e "REGISTRY_AUTH=htpasswd" \
            -e "REGISTRY_AUTH_HTPASSWD_REALM=Registry Realm" \
            -e "REGISTRY_AUTH_HTPASSWD_PATH=/auth/htpasswd" \
            -v /usr/local/registry:/var/lib/registry \
            --restart=always \
            --name registry \
            registry

    使用客户端尝试拉取镜像，输入命令：

        docker pull 192.168.140.199:5000/nginx-pro:v1.0

        -> 拉取失败提示需要认证信息：no basic auth credentials

    客户端认证后再拉取镜像，输入命令：

        docker login 192.168.140.199:5000 -u docker -p 123456

        docker pull 192.168.140.199:5000/nginx-pro:v1.0

        docker logout 192.168.140.199:5000

        docker images

        -> 输出本地镜像信息

            REPOSITORY                       TAG       IMAGE ID       CREATED       SIZE
            192.168.140.199:5000/nginx-pro   v1.0      87a94228f133   2 weeks ago   133MB
