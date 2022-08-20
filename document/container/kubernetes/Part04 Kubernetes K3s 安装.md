
# Kubernetes K3s 安装

  * 什么是 K3s：

        K3s 是一个轻量级 Kubernetes，它易于安装，二进制文件包非常小，运行快速且占用资源非常少

        K3s 可运行在单机环境，也可以运行在集群环境

        K3s 适合单机运行、小规模集群、个人学习(比 Minikube 更加节省资源)，服务器配置不高，建议使用 K3s 搭建集群

  * 官方文档地址：

        https://github.com/k3s-io/k3s

        https://rancher.com/docs/k3s/latest/en/

  * 单机版服务器：

        192.168.140.151             # 单节点，使用 SQLite 作为存储

  * 集群版服务器：

        192.168.140.147             # 控制节点一

        192.168.140.148             # 控制节点二

        192.168.140.149             # 控制节点三

        192.168.140.147             # etcd 集群节点一

        192.168.140.148             # etcd 集群节点二

        192.168.140.149             # etcd 集群节点三

        192.168.140.150             # 工作节点

        (注意，控制节点也作为工作节点，如果控制节点不作为工作节点，初始化安装时增加 --node-taint k3s-controlplane=true:NoExecute 选项)

## 安装 K3s 单机版

  * 更新服务器内核版本、依赖库：

        (略)

  * 关闭服务器防火墙：

        systemctl stop firewalld

        systemctl disable firewalld

  * 更改 hostname 配置：

        hostnamectl set-hostname k3s-151

        echo '192.168.140.151 k3s-151' >> /etc/hosts

  * 禁用 selinux 访问控制：

        sed -i 's/SELINUX=enforcing/SELINUX=disabled/' /etc/selinux/config

        cat /etc/selinux/config

  * 禁用 swap 内存交换：

        sed -i 's/.*swap.*/#&/' /etc/fstab

        cat /etc/fstab

  * 安装 docker 容器引擎：

        (略，注意 cgroup 不能更改为 systemd 只能使用 cgroupfs )

  * 安装 K3s 1.23 版本 ( 1.24+ 版本使用 containerd 作为默认容器引擎，使用 docker 需要额外安装 cri-dockerd ) ：

        cd /usr/local/software

        export INSTALL_K3S_VERSION=v1.23.9+k3s1

        curl -sfL https://get.k3s.io | sh -s - server --docker

        # 国内加速镜像安装
        # curl -sfL https://rancher-mirror.oss-cn-beijing.aliyuncs.com/k3s/k3s-install.sh | \
                INSTALL_K3S_MIRROR=cn \
                sh -s \
                - server \
                --docker \
                --disable servicelb \
                --disable traefik \
                --disable-cloud-controller

  * 运行测试，创建资源对象实例：

        kubectl get pods -A

        ->

            NAMESPACE     NAME                                      READY   STATUS      RESTARTS   AGE
            kube-system   local-path-provisioner-6c79684f77-tq44f   1/1     Running     0          4m58s
            kube-system   helm-install-traefik-crd-v2lz2            0/1     Completed   0          4m58s
            kube-system   coredns-d76bd69b-rrn6b                    1/1     Running     0          4m58s
            kube-system   metrics-server-7cd5fcb6b7-nq5lk           1/1     Running     0          4m58s
            kube-system   helm-install-traefik-67gxv                0/1     Completed   2          4m58s
            kube-system   svclb-traefik-e2f5155c-x27r9              2/2     Running     0          3m
            kube-system   traefik-df4ff85d6-26k9z                   1/1     Running     0          3m4s

        vi namespace.yaml

        =>

            apiVersion: v1
            kind: Namespace
            metadata:
              name: mrh-cluster
              labels:
                created-by: mrh
                website: zfhlm.github.io

        vi centos-pod.yaml

        =>

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

        kubectl apply -f namespace.yaml

        kubectl apply -f centos-pod.yaml

        kubectl get pods -n mrh-cluster

        ->

            NAME     READY   STATUS    RESTARTS   AGE
            centos   1/1     Running   0          97s

## 安装 K3s 集群版

  * 更新服务器内核版本、依赖库：

        (略)

  * 关闭服务器防火墙：

        systemctl stop firewalld

        systemctl disable firewalld

  * 更改 hostname 配置：

        # hostnamectl set-hostname k3s-master-147
        # hostnamectl set-hostname k3s-master-148
        # hostnamectl set-hostname k3s-master-149
        # hostnamectl set-hostname k3s-worker-150

        echo '192.168.140.147 k3s-master-147' >> /etc/hosts
        echo '192.168.140.148 k3s-master-148' >> /etc/hosts
        echo '192.168.140.149 k3s-master-149' >> /etc/hosts
        echo '192.168.140.150 k3s-worker-150' >> /etc/hosts

  * 禁用 selinux 访问控制：

        sed -i 's/SELINUX=enforcing/SELINUX=disabled/' /etc/selinux/config

        cat /etc/selinux/config

  * 禁用 swap 内存交换：

        sed -i 's/.*swap.*/#&/' /etc/fstab

        cat /etc/fstab

  * 安装 docker 容器引擎：

        (略，注意 cgroup 不能更改为 systemd 只能使用 cgroupfs )

  * 安装 etcd 集群：

        (略，参考[etcd 集群])

  * 控制节点一，安装 K3s 1.23 版本：

        curl -sfL https://rancher-mirror.oss-cn-beijing.aliyuncs.com/k3s/k3s-install.sh | \
            INSTALL_K3S_VERSION=v1.23.9+k3s1 \
            INSTALL_K3S_MIRROR=cn \
            K3S_DATASTORE_ENDPOINT='https://192.168.140.147:2379,https://192.168.140.148:2379,https://192.168.140.149:2379' \
            K3S_DATASTORE_CAFILE='/usr/local/etcd/certs/etcd-root-ca.pem' \
            K3S_DATASTORE_CERTFILE='/usr/local/etcd/certs/etcd.pem' \
            K3S_DATASTORE_KEYFILE='/usr/local/etcd/certs/etcd-key.pem' \
            K3S_TOKEN=7cb7d3ad-cb8f-4629-b88e-896c93e0fcee \
            sh -s - server \
            --docker \
            --disable servicelb \
            --disable traefik \
            --disable-cloud-controller \
            --cluster-init

  * 控制节点二 & 控制节点三，安装 K3s 1.23 版本：

        curl -sfL https://rancher-mirror.oss-cn-beijing.aliyuncs.com/k3s/k3s-install.sh | \
            INSTALL_K3S_VERSION=v1.23.9+k3s1 \
            INSTALL_K3S_MIRROR=cn \
            K3S_DATASTORE_ENDPOINT='https://192.168.140.147:2379,https://192.168.140.148:2379,https://192.168.140.149:2379' \
            K3S_DATASTORE_CAFILE='/usr/local/etcd/certs/etcd-root-ca.pem' \
            K3S_DATASTORE_CERTFILE='/usr/local/etcd/certs/etcd.pem' \
            K3S_DATASTORE_KEYFILE='/usr/local/etcd/certs/etcd-key.pem' \
            K3S_TOKEN=7cb7d3ad-cb8f-4629-b88e-896c93e0fcee \
            K3S_URL=https://192.168.140.147:6443 \
            sh -s - server \
            --docker \
            --disable servicelb \
            --disable traefik \
            --disable-cloud-controller

  * 查看集群控制节点：

    kubectl get nodes

    ->

        NAME             STATUS   ROLES                  AGE     VERSION
        k3s-master-147   Ready    control-plane,master   20m     v1.23.9+k3s1
        k3s-master-148   Ready    control-plane,master   13m     v1.23.9+k3s1
        k3s-master-149   Ready    control-plane,master   2m50s   v1.23.9+k3s1

  * 工作节点，安装 K3s 1.23 版本：

        curl -sfL https://rancher-mirror.oss-cn-beijing.aliyuncs.com/k3s/k3s-install.sh | \
            INSTALL_K3S_VERSION=v1.23.9+k3s1 \
            INSTALL_K3S_MIRROR=cn \
            K3S_TOKEN=7cb7d3ad-cb8f-4629-b88e-896c93e0fcee \
            K3S_URL=https://192.168.140.147:6443 \
            sh -s - \
            --docker

  * 查看集群所有节点：

    kubectl get nodes

    ->

        NAME             STATUS   ROLES                  AGE     VERSION
        k3s-master-147   Ready    control-plane,master   20m     v1.23.9+k3s1
        k3s-master-148   Ready    control-plane,master   13m     v1.23.9+k3s1
        k3s-master-149   Ready    control-plane,master   2m50s   v1.23.9+k3s1
        k3s-master-150   Ready    <none>                 1m20s   v1.23.9+k3s1

## 安装 K3s dashboard 控制台

  * 发布 dashboard 资源对象：

        wget https://github.com/kubernetes/dashboard/archive/refs/tags/v2.6.1.tar.gz

        tar -zxvf v2.6.1.tar.gz

        cp dashboard-2.6.1/aio/deploy/recommended.yaml recommended.yaml

        # 更改 dashboard svc 为 NodePort 类型，端口 30443
        vi recommended.yaml

        =>

            kind: Service
            apiVersion: v1
            metadata:
              labels:
                k8s-app: kubernetes-dashboard
              name: kubernetes-dashboard
              namespace: kubernetes-dashboard
            spec:
              type: NodePort
              ports:
                - port: 443
                  targetPort: 8443
                  nodePort: 30443
              selector:
                k8s-app: kubernetes-dashboard

        kubectl apply -f recommended.yaml

  * 创建 dashboard 集群账号：

        vi dashboard.admin-user.yml

        =>

            apiVersion: v1
            kind: ServiceAccount
            metadata:
              name: admin-user
              namespace: kubernetes-dashboard

        vi dashboard.admin-user-role.yml

        =>

            apiVersion: rbac.authorization.k8s.io/v1
            kind: ClusterRoleBinding
            metadata:
              name: admin-user
            roleRef:
              apiGroup: rbac.authorization.k8s.io
              kind: ClusterRole
              name: cluster-admin
            subjects:
              - kind: ServiceAccount
                name: admin-user
                namespace: kubernetes-dashboard

        kubectl apply -f dashboard.admin-user.yml

        kubectl apply -f dashboard.admin-user-role.yml

  * 登录 dashboard 控制台：

        # 获取登录令牌
        kubectl -n kubernetes-dashboard describe secret admin-user-token | grep '^token'

        ->

            token:      eyJhbGciOiJSUzI1NiIsImtpZCI6Iml3TDFWWXEtLVhiSVFERzRsaDQxdlM4Z1ZLTW1za3JYd1VaNjFjQURVTWMifQ.eyJpc3MiOiJrdWJlcm5ldGVzL3NlcnZpY2VhY2NvdW50Iiwia3ViZXJuZXRlcy5pby9zZXJ2aWNlYWNjb3VudC9uYW1lc3BhY2UiOiJrdWJlcm5ldGVzLWRhc2hib2FyZCIsImt1YmVybmV0ZXMuaW8vc2VydmljZWFjY291bnQvc2VjcmV0Lm5hbWUiOiJhZG1pbi11c2VyLXRva2VuLXFseGt3Iiwia3ViZXJuZXRlcy5pby9zZXJ2aWNlYWNjb3VudC9zZXJ2aWNlLWFjY291bnQubmFtZSI6ImFkbWluLXVzZXIiLCJrdWJlcm5ldGVzLmlvL3NlcnZpY2VhY2NvdW50L3NlcnZpY2UtYWNjb3VudC51aWQiOiIyYzU0Y2EwYi0wODU1LTQwOGYtOTNlNy0zNjhmYzk1MzY4YjQiLCJzdWIiOiJzeXN0ZW06c2VydmljZWFjY291bnQ6a3ViZXJuZXRlcy1kYXNoYm9hcmQ6YWRtaW4tdXNlciJ9.y2567tlxpkO6GDxYJDm4iQ-a5mVUwcrZ-AwvBamGBR6UN-i5eS7tYh-jJUo8hyU4GL4oG9CqpQuYsYIEwNfmMIprxVmMJEznIcBl8qA89Q0ldq8OgEQ5gVgGfwLO2vbNW9Kfc57ad7qzCgoeyYwnBlKyQ-YhTyt0Xotn-GcDGcs_zNC6xFZh_YhwpH80e0x3hHfecd3ESp-jDIrrGVyGgpOkOgoyIwTCHixsr6l1SIhPb0hxaI0FitDANYt-16jiIOLZe5cMYh7M4TFhDUdaJyLnBBZa1QsajUFA90JIDmJRLxGR3XgcfRa6vf-6BcWC5nBAVGEmj1QeXVVGRhKehQ

        # 控制台地址
        # https://192.168.140.147:30443
        # https://192.168.140.148:30443
        # https://192.168.140.149:30443

## 更新 K3s TLS 证书

  * 到期 90 天内，重启各个 master worker 节点，直接会自动更新

  * 查看证书过期时间，执行命令：

        for i in `ls /var/lib/rancher/k3s/server/tls/*.crt`; do echo $i; openssl x509 -enddate -noout -in $i; done

  * 重启更新不生效/已过期，解决办法：

        kubectl --insecure-skip-tls-verify -n kube-system delete secrets k3s-serving

        rm -f /var/lib/rancher/k3s/server/tls/dynamic-cert.json

        systemctl restart k3s

        systemctl restart k3s-agent

        for i in `ls /var/lib/rancher/k3s/server/tls/*.crt`; do echo $i; openssl x509 -enddate -noout -in $i; done
