
# docker 搭建仓库 registry

### 安装仓库

  * 服务端拉取 registry 镜像：

        docker search registry

        docker pull registry

        docker images

  * 服务端使用 httpd 生成账号密码：

        mkdir -p /usr/local/registry

        cd /usr/local/registry/

        mkdir auth

        docker pull httpd:2

        docker run --entrypoint htpasswd httpd:2 -Bbn docker 123456 >> ./auth/htpasswd

  * 服务端启动 registry 容器：

        docker run -d -p 5000:5000 \
            -v /usr/local/registry/auth:/auth \
            -e "REGISTRY_AUTH=htpasswd" \
            -e "REGISTRY_AUTH_HTPASSWD_REALM=Registry Realm" \
            -e "REGISTRY_AUTH_HTPASSWD_PATH=/auth/htpasswd" \
            -v /usr/local/registry:/var/lib/registry \
            --restart=always \
            --name registry \
            registry

        docker ps

        ->

            CONTAINER ID   IMAGE      COMMAND                   PORTS                                       NAMES
            0cf00009d3d3   registry   "/entrypoint.sh /etc…"    0.0.0.0:5000->5000/tcp, :::5000->5000/tcp   registry

  * 客户端配置，允许使用 http 与私有镜像仓库交互，输入命令：

        vi /etc/docker/daemon.json

        =>    加入以下配置

            {
                "insecure-registries":["192.168.140.136:5000"]
            }

        systemctl docker restart

  * 客户端配置，免输入 docker registry 账号密码：

        # 获取 账号:密码 base64 字符串：
        echo -n "docker:123456" | base64

        ->

            ZG9ja2VyOjEyMzQ1Ng==

        # 添加 base64 账号密码到 auths 配置
        vi ~/.docker/config.json

        =>

          {
              "auths": {
                  "192.168.140.136:5000": {
                      "auth": "ZG9ja2VyOjEyMzQ1Ng=="
                  }
              }
          }

  * 客户端镜像操作：

        docker pull nginx

        # 不需要再使用 docker login
        # docker login 192.168.140.136

        # 对镜像加标签
        docker tag nginx 192.168.140.136:5000/nginx:v1.0

        # 上传镜像到私库
        docker push 192.168.140.136:5000/nginx:v1.0

        # 移除本地镜像
        docker rmi 192.168.140.136:5000/nginx:v1.0

        # 拉取私库镜像
        docker pull 192.168.140.136:5000/nginx-pro:v1.0
