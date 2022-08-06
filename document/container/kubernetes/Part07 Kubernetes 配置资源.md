
# Kubernetes 配置资源

  * 官方文档：

        https://kubernetes.io/docs/home/

        https://kubernetes.io/docs/concepts/configuration/

        https://kubernetes.io/docs/reference/kubernetes-api/config-and-storage-resources/


  * 常用资源：

        ConfigMap                               # 配置类型数据

        Secret                                  # 保密类型数据

        (注意，以下关于 Volume 挂载都在 [Kubernetes 存储卷]，此处不做任何示例)

## ConfigMap

  * ConfigMap 简单介绍

        ConfigMap 是一种 API 对象，用来将非机密性的数据保存到键值对中，将环境配置信息和容器镜像解耦，便于应用配置的修改

        ConfigMap 三种使用方式：容器 env 参数、容器 command 参数、容器 volume 挂载(此处不做示例)

  * ConfigMap 文档地址：

        https://kubernetes.io/docs/concepts/configuration/configmap/

        https://kubernetes.io/docs/reference/kubernetes-api/config-and-storage-resources/config-map-v1/

        https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.24/#configmap-v1-core

  * ConfigMap 配置示例：

        apiVersion: v1
        kind: ConfigMap
        metadata:
          name: simple-config
          namespace: mrh-cluster
          labels:
            cluster: mrh-cluster
            created-by: mrh
            website: zfhlm.github.io
        data:
          # 简单的键值对
          spring.profiles.active: dev
          spring.application.name: simple-config
        ------------------------------------------
        apiVersion: v1
        kind: ConfigMap
        metadata:
          name: file-config
          namespace: mrh-cluster
          labels:
            cluster: mrh-cluster
            created-by: mrh
            website: zfhlm.github.io
        data:
          # 键为文件名称，值为文件内容
          application.yml: |-
            spring:
              profiles:
                active: dev
              application:
                name: file-config
            server:
              port: 8080
              context-path: /

  * ConfigMap 作为 env、command 参数示例：

        apiVersion: v1
        kind: Pod
        metadata:
          name: centos-configmap
          namespace: mrh-cluster
          labels:
            cluster: mrh-cluster
            service: centos-configmap
            created-by: mrh
            website: zfhlm.github.io
        spec:
          restartPolicy: Always
          containers:
          - name: centos
            image: centos:centos7
            imagePullPolicy: IfNotPresent
            # 使用 env 中定义的启动参数
            command: ['/bin/sh', '-c', 'echo $(SPRING_PROFILES_ACTIVE) && echo $(SPRING_APPLICATION_NAME) && echo "$(APPLICATION_YML)" && tail -f /dev/null']
            # 从 ConfigMap 中引用键值，创建 env 启动参数
            env:
            - name: SPRING_PROFILES_ACTIVE
              valueFrom:
                configMapKeyRef:
                  name: simple-config
                  key: spring.profiles.active
            - name: SPRING_APPLICATION_NAME
              valueFrom:
                configMapKeyRef:
                  name: simple-config
                  key: spring.application.name
            - name: APPLICATION_YML
              valueFrom:
                configMapKeyRef:
                  name: file-config
                  key: application.yml
            # 引入 ConfigMap 配置
            envFrom:
            - configMapRef:
                name: simple-config
            - configMapRef:
                name: file-config

## Secret

  * Secret 简单介绍：

        Secret 用于存储和管理一些敏感数据，例如密码，令牌，密钥等敏感信息

        Secret 三种使用方式，与 ConfigMap 一样：容器 env 参数、容器 command 参数、容器 volume 挂载(此处不做示例)

  * Secret 类型：

        Opaque                                      # 用户定义的任意数据

        kubernetes.io/service-account-token         # (已废弃) 服务账号令牌

        kubernetes.io/dockercfg                     # ~/.dockercfg 文件的序列化形式

        kubernetes.io/dockerconfigjson              # ~/.docker/config.json 文件的序列化形式，用于配置 docker 私库的账号密码

        kubernetes.io/basic-auth                    # 用于基本身份认证的凭据

        kubernetes.io/ssh-auth                      # 用于 SSH 身份认证的凭据

        kubernetes.io/tls                           # 用于 TLS 客户端或者服务器端的数据

        bootstrap.kubernetes.io/token               # 启动引导令牌数据

  * Secret 文档地址：

        https://kubernetes.io/docs/concepts/configuration/secret/

        https://kubernetes.io/docs/concepts/configuration/secret/#secret-types

        https://kubernetes.io/docs/reference/kubernetes-api/config-and-storage-resources/secret-v1/

        https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.24/#secret-v1-core

  * Secret 配置作为 env、command 参数示例：

        apiVersion: v1
        kind: Secret
        metadata:
          name: secret-mysql-user
          namespace: mrh-cluster
          labels:
            cluster: mrh-cluster
            created-by: mrh
            website: zfhlm.github.io
        # 类型
        type: Opaque
        # 是否不允许更改
        immutable: false
        # 使用 base64 加密，可以使用 echo -n '123456' | base64 获取加密数据
        data:
          username: YWRtaW4=
          password: MTIzNDU2
        # 这种方式不用进行编码
        stringData:
          bizuser: business
          bizpwd: '123456'
        -------------------------------------------
        apiVersion: v1
        kind: Pod
        metadata:
          name: centos-secret
          namespace: mrh-cluster
          labels:
            cluster: mrh-cluster
            service: centos-secret
            created-by: mrh
            website: zfhlm.github.io
        spec:
          restartPolicy: Always
          containers:
          - name: centos
            image: centos:centos7
            imagePullPolicy: IfNotPresent
            # 使用 env 中定义的启动参数
            command: ['/bin/sh', '-c', 'echo $(USERNAME) && echo $(PASSWORD) && tail -f /dev/null']
            # 从 Secret 中引用键值，创建 env 启动参数
            env:
            - name: USERNAME
              valueFrom:
                secretKeyRef:
                  name: secret-mysql-user
                  key: username
            - name: PASSWORD
              valueFrom:
                secretKeyRef:
                  name: secret-mysql-user
                  key: password
            # 引入 Secret 配置
            envFrom:
            - secretRef:
                name: secret-mysql-user

  * Secret 作为 docker 私库认证信息示例：

        ### 重要说明：k8s 使用的认证信息，与宿主机 docker 进程使用的认证信息，各自进行管理，如果宿主机需要使用 docker command 连接私库，需要单独配置
        ### 私库自签证书，需要在 docker 配置，k8s 暂时未找到可解决的办法

        apiVersion: v1
        kind: Secret
        metadata:
          name: secret-dockerconfigjson
          namespace: mrh-cluster
          labels:
            cluster: mrh-cluster
            created-by: mrh
            website: zfhlm.github.io
        type: kubernetes.io/dockerconfigjson
        immutable: false
        stringData:
          # docker 私库认证信息
          .dockerconfigjson: |-
            {"auths":{"192.168.140.140:5000":{"username":"docker","password":"123456","auth":"ZG9ja2VyOjEyMzQ1Ng=="}}}
        -------------------------------------------
        apiVersion: v1
        kind: Pod
        metadata:
          name: centos-secret-docker
          namespace: mrh-cluster
          labels:
            cluster: mrh-cluster
            service: centos-secret-docker
            created-by: mrh
            website: zfhlm.github.io
        spec:
          restartPolicy: Always
          # 引用私库认证信息
          imagePullSecrets:
          - name: secret-dockerconfigjson
          containers:
          - name: centos
            image: 192.168.140.140:5000/centos:centos7
            imagePullPolicy: IfNotPresent
            command: ['/bin/sh', '-c', 'tail -f /dev/null']
