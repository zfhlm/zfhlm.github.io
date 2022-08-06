
# Kubernetes 存储卷资源

  * 官方文档：

        https://kubernetes.io/docs/home/

        https://kubernetes.io/docs/concepts/storage/

        https://kubernetes.io/docs/reference/kubernetes-api/config-and-storage-resources/

  * 常用资源：

        Volume                                  # 存储卷

        PersistentVolumeClaim                   # 持久卷声明

        PersistentVolume                        # 持久卷

## Volume

  * 简单介绍：

        Volume 用于解决 Pod 中的容器运行时，文件存放的问题以及多容器数据共享的问题

        创建 Pod 时，会先创建一个基础容器 pause，Pod 里面所有的容器共享一个网络名称空间和文件系统，挂载卷的工作就是由基础容器 pause 来完成的

        常用的 Volume 有 configMap、secret、emptyDir、hostPath、nfs、persistentVolumeClaim，云服务商还提供了其他高性能的 Volume 收费服务

  * Volume 种类：

        ConfigMap                               # 将 ConfigMap 挂载卷

        Secret                                  # 将 Secret 挂载卷

        emptyDir                                # 空卷，主要用于存储容器运行中的临时文件，例如 SpringMVC 文件上传时临时文件

        hostPath                                # 宿主机目录挂载卷，主要用于存储日志等无状态数据

        nfs                                     # 网络文件系统挂载，可在容器间共享

        PersistentVolumeClaim                   # 持久卷挂载

  * ConfigMap 挂载配置示例：

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
          application.yml: |-
            spring:
              profiles:
                active: dev
              application:
                name: file-config
            server:
              port: 8080
              context-path: /
        ------------------------------------------
        apiVersion: v1
        kind: Pod
        metadata:
          name: centos-volume-configmap
          namespace: mrh-cluster
          labels:
            cluster: mrh-cluster
            service: centos-volume-configmap
            created-by: mrh
            website: zfhlm.github.io
        spec:
          restartPolicy: Always
          containers:
          - name: centos
            image: centos:centos7
            imagePullPolicy: IfNotPresent
            command: ['/bin/sh', '-c', 'tail -f /dev/null']
            # 挂载卷
            volumeMounts:
            - name: simple-config
              mountPath: /usr/local/config/simple
            - name: file-config
              mountPath: /usr/local/config/file
          # 声明卷
          volumes:
          - name: simple-config
            configMap:
              name: simple-config
          - name: file-config
            configMap:
              name: file-config

        # 以上配置会在容器内部生成以下挂载信息：
        #
        #  +- /usr/local/config
        #     +
        #     +----------------- simple
        #     +                  +-------- spring.profiles.active
        #     +                  +-------- spring.application.name
        #     +
        #     +----------------- file
        #                        +-------- application.yml

  * Secret 挂载配置示例：

        apiVersion: v1
        kind: Secret
        metadata:
          name: secret-mysql
          namespace: mrh-cluster
          labels:
            cluster: mrh-cluster
            created-by: mrh
            website: zfhlm.github.io
        type: Opaque
        immutable: false
        data:
          username: YWRtaW4=
          password: MTIzNDU2
        stringData:
          bizuser: business
          bizpwd: '123456'
        ------------------------------------------
        apiVersion: v1
        kind: Pod
        metadata:
          name: centos-volume-secret
          namespace: mrh-cluster
          labels:
            cluster: mrh-cluster
            service: centos-volume-secret
            created-by: mrh
            website: zfhlm.github.io
        spec:
          restartPolicy: Always
          containers:
          - name: centos
            image: centos:centos7
            imagePullPolicy: IfNotPresent
            command: ['/bin/sh', '-c', 'tail -f /dev/null']
            # 挂载卷
            volumeMounts:
            - name: secret-mysql
              mountPath: /usr/local/config/mysql
          # 声明卷
          volumes:
          - name: secret-mysql
            secret:
              secretName: secret-mysql

        # 以上配置会在容器内部生成以下挂载信息：
        #
        #  +- /usr/local/config
        #     +
        #     +----------------- mysql
        #     +                  +-------- username
        #     +                  +-------- password
        #     +                  +-------- bizuser
        #     +                  +-------- bizpwd

  * emptyDir 挂载配置示例：

        apiVersion: v1
        kind: Pod
        metadata:
          name: centos-volume-emptydir
          namespace: mrh-cluster
          labels:
            cluster: mrh-cluster
            service: centos-volume-emptydir
            created-by: mrh
            website: zfhlm.github.io
        spec:
          restartPolicy: Always
          containers:
          - name: centos
            image: centos:centos7
            imagePullPolicy: IfNotPresent
            command: ['/bin/sh', '-c', '/usr/sbin/init']
            # 容器挂载卷，注意名称与声明对应
            volumeMounts:
            - name: empty
              mountPath: /usr/local/muti
          # 声明一个空卷，注意无需指定目录位置
          volumes:
          - name: empty
            emptyDir: {}

        # 以上配置会在容器内部生成以下挂载信息：
        #
        #  +- /usr/local/muti (对应的空卷目录无需关注)
        #

  * hostPath 挂载配置示例：

        apiVersion: v1
        kind: Pod
        metadata:
          name: centos-volume-hostpath
          namespace: mrh-cluster
          labels:
            cluster: mrh-cluster
            service: centos-volume-hostpath
            created-by: mrh
            website: zfhlm.github.io
        spec:
          restartPolicy: Always
          containers:
          - name: centos
            image: centos:centos7
            imagePullPolicy: IfNotPresent
            command: ['/bin/sh', '-c', '/usr/sbin/init']
            # 容器挂载卷，注意名称与声明对应
            volumeMounts:
            - name: logs
              mountPath: /usr/local/logs
          # 声明一个宿主机卷
          volumes:
          - name: logs
            hostPath:
              path: /usr/local/logs

        # 以上配置会在容器内部生成以下挂载信息：
        #
        #  +- /usr/local/logs (对应宿主机目录 /usr/local/logs )
        #

  * nfs 挂载配置示例：

        apiVersion: v1
        kind: Pod
        metadata:
          name: centos-volume-nfs
          namespace: mrh-cluster
          labels:
            cluster: mrh-cluster
            service: centos-volume-nfs
            created-by: mrh
            website: zfhlm.github.io
        spec:
          restartPolicy: Always
          containers:
          - name: centos
            image: centos:centos7
            imagePullPolicy: IfNotPresent
            command: ['/bin/sh', '-c', '/usr/sbin/init']
            # 容器挂载卷，注意名称与声明对应
            volumeMounts:
            - name: nfs
              mountPath: /usr/local/software
          # 声明一个 nfs 存储卷，注意配置与容器宿主机同网段
          volumes:
          - name: nfs
            nfs:
              path: /usr/local/software
              readOnly: false
              server: 192.168.140.140

        # 以上配置会在容器内部生成以下挂载信息：
        #
        #  +- /usr/local/software (对应 nfs 目录 /usr/local/software )
        #
