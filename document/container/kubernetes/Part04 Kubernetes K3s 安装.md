
# Kubernetes K3s 安装

  * 什么是 K3s：

        K3s 是一个轻量级 Kubernetes，它易于安装，二进制文件包非常小，运行快速且占用资源非常少

        K3s 可运行在单机环境，也可以运行在集群环境

        K3s 适合单机运行、小规模集群、个人学习(比 Minikube 更加节省资源)，服务器配置不高，建议使用 K3s 搭建集群

  * 官方文档地址：

        https://github.com/k3s-io/k3s

        https://rancher.com/docs/k3s/latest/en/

## 安装 K3s 单机版

  * 安装 docker 容器引擎：

        (略)

  * 安装 K3s 1.23 版本 ( 1.24+ 版本使用 containerd 作为默认容器引擎，使用 docker 需要额外安装 cri-dockerd ) ：

        cd /usr/local/software

        export INSTALL_K3S_VERSION=v1.23.9+k3s1

        curl -sfL https://get.k3s.io | sh -s - server --docker

  * 运行测试，创建资源对象实例：

        kubectl create namespace mrh-cluster

        kubectl get namespace

        -->

            NAME              STATUS   AGE
            default           Active   8m34s
            kube-system       Active   8m34s
            kube-public       Active   8m34s
            kube-node-lease   Active   8m34s
            mrh-cluster       Active   5m26s

        vi pod.yaml

        ==>

            apiVersion: v1
            kind: Pod
            metadata:
              name: centos
              namespace: mrh-cluster
              labels:
                cluster: mrh-cluster
                service: centos
                created-by: mrh
                website: zfhlm.github.io
            spec:
              restartPolicy: Always
              containers:
              - name: centos
                image: centos:centos7
                imagePullPolicy: Always
                command: ['/bin/sh', '-c', '/usr/sbin/init']

        kubectl get pods -o wide -n mrh-cluster

## 安装 K3s 集群版
