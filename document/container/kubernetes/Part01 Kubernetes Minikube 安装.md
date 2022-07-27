
# Kubernetes Minikube 安装

  * 什么是 Minikube？

        Minikube 是一种轻量化的 Kubernetes 集群，是 Kubernetes 社区为了帮助开发者和学习者能够更好学习和体验 k8s 功能而推出

        Minikube 仅适用于单机学习与体验，所有组件都部署在同一台机器上面

  * 集群组件：

        etcd                             # 集群状态数据存储

        kube-apiserver                   # 集群 HTTP API，提供给用户、集群中的不同部分和集群外部组件相互通信，可水平扩展多个进行负载均衡

        kube-controller-manager          # 监控集群状态，如故障检测、自动扩展、滚动更新等（唯一 active 状态节点，其他作为故障切换备用节点）

        kube-scheduler                   # 调度集群资源，根据调度策略将 Pod 调度到对应的 Node（唯一 active 状态节点，其他作为故障切换备用节点）

        kubelet                          # 集群运行代理，保证容器都运行在 Pod 中

        kube-proxy                       # 集群网络代理，提供服务发现和负载均衡等

        Container Runtime                # 集群容器服务，提供容器运行环境

        Addons                           # 可选或默认插件，例如 DNS插件、可视化管理界面插件、网络插件、资源监控插件、集群日志插件等

  * 官方文档地址：

        https://kubernetes.io/

        https://kubernetes.io/zh-cn/docs/home/

        https://minikube.sigs.k8s.io/docs/start/

        https://github.com/kubernetes/minikube

### 安装与启动

  * 升级服务器内核、依赖库：

        [参考链接](https://github.com/zfhlm/zfhlm.github.io/blob/main/document/env/Part05%20CentOS%20%E5%8D%87%E7%BA%A7%E5%86%85%E6%A0%B8%E7%89%88%E6%9C%AC.md)

  * 安装 docker 运行环境：

        [参考链接](https://github.com/zfhlm/zfhlm.github.io/blob/main/document/container/docker/Part01%20docker%20%E5%AE%89%E8%A3%85%E9%85%8D%E7%BD%AE.md)

        vi /etc/docker/daemon.json

        =>

            {
                "exec-opts": ["native.cgroupdriver=systemd"]
            }

        systemctl restart docker

        docker info -f {{.CgroupDriver}}

  * 参考 Minikube 官方文档进行安装：

        cd /usr/local/software

        curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64

        sudo install minikube-linux-amd64 /usr/local/bin/minikube

        # 如果安装失败，删除已下载资源，再执行 start 重试
        # minikube delete --all --purge

        # 最新版本 v1.24.1 无法启动，降低版本至 v1.23.9
        minikube start --force --driver=docker --image-repository=registry.cn-hangzhou.aliyuncs.com/google_containers --kubernetes-version=v1.23.9

        minikube kubectl -- get pods -A

        ->

            NAMESPACE     NAME                               READY   STATUS    RESTARTS   AGE
            kube-system   coredns-65c54cc984-xzhfl           0/1     Running   0          4s
            kube-system   etcd-minikube                      1/1     Running   0          21s
            kube-system   kube-apiserver-minikube            1/1     Running   0          19s
            kube-system   kube-controller-manager-minikube   1/1     Running   0          20s
            kube-system   kube-proxy-8xjz6                   1/1     Running   0          4s
            kube-system   kube-scheduler-minikube            1/1     Running   0          18s
            kube-system   storage-provisioner                1/1     Running   0          15s

  * 启动 minikube web 可视化控制台：

        minikube dashboard --url=true --port=8050

        ->

            * Verifying dashboard health ...
            * Launching proxy ...
            * Verifying proxy health ...
            http://127.0.0.1:8050/api/v1/namespaces/kubernetes-dashboard/services/http:kubernetes-dashboard:/proxy/

        nohup minikube kubectl -- proxy --port=8050 --address='192.168.140.140' --accept-hosts='^.*' &

  * 访问 minikube web 可视化控制台：

        http://192.168.140.140:8050/api/v1/namespaces/kubernetes-dashboard/services/http:kubernetes-dashboard:/proxy/
