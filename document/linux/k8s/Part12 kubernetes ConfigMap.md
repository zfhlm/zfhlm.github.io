
# kubernetes

    ConfigMap 是一种 API 对象，用来将非机密性的数据保存到键值对中，将环境配置信息和容器镜像解耦，便于应用配置的修改

    官方文档：https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.22/#configmap-v1-core

#### 创建 ConfigMap

    创建 ConfigMap 配置，输入命令：

        cd /usr/local/kubernetes/

        vi env-configmap.yaml

    添加以下内容：

        apiVersion: v1
        kind: ConfigMap
        metadata:
          name: profile-config
        immutable: true
        data:
          profile: dev

    创建 ConfigMap，输入命令：

        kubectl apply -f env-configmap.yaml

        kubectl describe configmap profile-config

        -> 输出配置信息

          Name:         profile-config
          Namespace:    default
          Labels:       <none>
          Annotations:  <none>

          Data
          ====
          profile:
          ----
          dev

          BinaryData
          ====

          Events:  <none>

#### 引用 ConfigMap

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
            - name: PROFILE
              valueFrom:
                configMapKeyRef:
                  name: profile-config
                  key: profile
            command: ["/usr/sbin/init"]

    运行 centos Pod，输入命令：

        kubectl apply -f centos-pod.yaml

        kubectl get pod -o wide -w

    进入 centos 容器查看环境变量，输入命令：

        kubectl exec -it centos -- /bin/bash

        echo $PROFILE

        -> 输出 dev
