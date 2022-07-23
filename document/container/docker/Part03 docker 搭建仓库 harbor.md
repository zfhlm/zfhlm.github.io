
# docker 搭建仓库 harbor

### 安装配置

  * 服务器要求

        服务器IP：192.168.140.209 (最小内存 4G，CPU 2核)

        提前配置好 docker、docker compose 和 openssl

  * 下载安装包，输入命令：

        wget https://github.com/goharbor/harbor/releases/download/v1.10.9/harbor-offline-installer-v1.10.9.tgz

        tar -zxvf harbor-offline-installer-v1.10.9.tgz

        mv ./harbor /usr/local/

        cd /usr/local/harbor

  * 创建 ssl 自签名证书，输入命令：

        mkdir cert && cd cert

        openssl genrsa -out ca.key 4096

        openssl req -x509 -new -nodes -sha512 -days 3650  -subj "/CN=192.168.140.209"  -key ca.key  -out ca.crt

        openssl genrsa -out server.key 4096

        openssl req  -new -sha512  -subj "/CN=192.168.140.209"  -key server.key  -out server.csr

        cat > v3.ext <<-EOF
        authorityKeyIdentifier=keyid,issuer
        basicConstraints=CA:FALSE
        keyUsage = digitalSignature, nonRepudiation, keyEncipherment, dataEncipherment
        extendedKeyUsage = serverAuth
        subjectAltName = IP:192.168.140.209
        EOF

        openssl x509 -req -sha512 -days 3650 -extfile v3.ext -CA ca.crt -CAkey ca.key -CAcreateserial -in server.csr -out server.crt

  * 更改配置文件，输入命令：

        vi harbor.yml

        =>

          hostname: 192.168.140.209

          https:
            port: 443
            certificate: /usr/local/harbor/cert/server.crt
            private_key: /usr/local/harbor/cert/server.key

          harbor_admin_password: admin123456

  * 初始化启动 harbor，输入命令：

        mkdir /var/log/harbor/

        cd /usr/local/harbor

        ./prepare

        docker-compose up -d

  * 浏览器访问 harbor，地址：

        https://192.168.140.209/

        账号 admin 密码 admin123456

  * 配置 harbor 仓库：

        点击【项目】-【新建项目】

        填写项目名称 dev 并保存

        (可以根据环境配置不同的项目，例如：dev、test、product)

### 使用仓库

  * 配置 docker 信任证书，输入命令：

        mkdir -p /etc/docker/certs.d/192.168.140.209

        cp /usr/local/harbor/cert/server.crt /etc/docker/certs.d/192.168.140.209/

  * 配置免输入 docker registry 账号密码：

        # 获取 账号:密码 base64 字符串：
        echo -n "admin:admin123456" | base64

        ->

            YWRtaW46YWRtaW4xMjM0NTY=

        # 添加 base64 账号密码到 auths 配置
        vi ~/.docker/config.json

        =>

            {
                "auths": {
                    "192.168.140.209:5000": {
                        "auth": "YWRtaW46YWRtaW4xMjM0NTY="
                    }
                }
            }

  * 上传镜像测试，输入命令：

        # 不需要再使用 docker login
        # docker login 192.168.140.209

        docker pull redis

        docker tag redis 192.168.140.209/dev/redis:v1

        docker push 192.168.140.209/dev/redis:v1

        ->

          The push refers to repository [192.168.140.209/dev/redis]
          146262eb3841: Pushed
          0bd13b42de4d: Pushed
          6b01cc47a390: Pushed
          8b9770153666: Pushed
          b43651130521: Pushed
          e8b689711f21: Pushed
          v1: digest: sha256:5d30f5c16e473549ad7c950b0ac3083039719b1c9749519c50e18017dd4bfc54 size: 1573
