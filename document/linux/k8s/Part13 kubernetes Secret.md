
# kubernetes

    Secret 是一种包含少量敏感信息例如密码、令牌或密钥的对象

    内置类型：

        Opaque                                     用户定义的任意数据，键值对都是 base64 编码字符串

        kubernetes.io/service-account-token        服务账号令牌，给运行在Pod里面的进程提供必要的身份证明，由 kubernetes 自动创建

        kubernetes.io/dockercfg                    ~/.dockercfg 文件的序列化形式

        kubernetes.io/dockerconfigjson             ~/.docker/config.json 文件的序列化形式

        kubernetes.io/basic-auth                   用于基本身份认证的凭据

        kubernetes.io/ssh-auth                     用于 SSH 身份认证的凭据

        kubernetes.io/tls                          用于 TLS 客户端或者服务器端的数据

        bootstrap.kubernetes.io/token              启动引导令牌数据

    官方文档：https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.22/#secret-v1-core

#### Opaque

    创建配置，输入命令：

        echo -n zhangsan | base64

        -> emhhbmdzYW4=

        echo -n 123456 | base64

        -> MTIzNDU2

        cd /usr/local/kubernetes

        vi mysql-secret.yaml

    添加以下配置：

        apiVersion: v1
        kind: Secret
        metadata:
          name: mysql-secret
        type: Opaque
        data:
          user: emhhbmdzYW4=
          password: MTIzNDU2

    添加 secret ，输入命令：

        kubectl apply -f mysql-secret.yaml

        kubectl describe secret mysql-secret

    创建 centos Pod，输入命令：

        vi centos-pod.yaml

    添加以下配置：

        apiVersion: v1
        kind: Pod
        metadata:
          name: centos
        spec:
          containers:
          - name: centos
            image: centos
            env:
            - name: USER
             valueFrom:
               secretKeyRef:
                 name: mysql-secret
                 key: user
            - name: PASSWORD
             valueFrom:
               secretKeyRef:
                 name: mysql-secret
                 key: password
            command: ["/usr/sbin/init"]

    运行 centos Pod，输入命令：

        kubectl apply -f centos-pod.yaml

        kubectl get pod -o wide -w

    进入 centos 容器查看环境变量，输入命令：

        kubectl exec -it centos -- /bin/bash

        echo $USER

        -> 输出 zhangsan

        echo $PASSWORD

        -> 输出 123456

#### kubernetes.io/dockerconfigjson

    创建 docker 私库认证信息，输入命令：

        kubectl create secret docker-registry harbor-registry \
          --docker-server=192.168.140.209 \
          --docker-username=dev \
          --docker-password=Dev123456 \
          --docker-email=914589210@qq.com

        kubectl describe secret harbor-registry

    拉取私库镜像运行 pod，输入命令：

        vi pod.yaml

        =>

            apiVersion: v1
            kind: Pod
            metadata:
              name: redis
            spec:
              containers:
              - name: redis
                image: 192.168.140.209/dev/redis:v1
              imagePullSecrets:
              - name: harbor-registry

        kubectl apply -f pod.yaml
