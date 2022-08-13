
# Kubernetes Minikube 安装

  * 什么是 Minikube

        Minikube 是一种轻量化的 Kubernetes 集群，是 Kubernetes 社区为了帮助开发者和学习者能够更好学习和体验 k8s 功能而推出

        Minikube 仅适用于单机学习与体验，所有组件都部署在同一台机器上面

  * 官方文档地址：

        https://kubernetes.io/

        https://kubernetes.io/zh-cn/docs/home/

        https://minikube.sigs.k8s.io/docs/start/

        https://github.com/kubernetes/minikube

  * 服务器信息：

        192.168.140.140

### Minikube 安装与启动

  * 更新服务器内核版本、依赖库：

        (略)

  * 关闭服务器防火墙：

        systemctl stop firewalld

        systemctl disable firewalld

  * 更改 hostname 配置：

        hostnamectl set-hostname minikube-140

        echo '192.168.140.140 minikube-140' >> /etc/hosts

  * 禁用 selinux 访问控制：

        sed -i 's/SELINUX=enforcing/SELINUX=disabled/' /etc/selinux/config

        cat /etc/selinux/config

  * 禁用 swap 内存交换：

        sed -i 's/.*swap.*/#&/' /etc/fstab

        cat /etc/fstab

  * 安装 docker 容器引擎：

        (略)

  * 更改 docker cgroup 配置：

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

### Minikube 容器宿主机

  * 如果使用 Minikube 编排容器，则容器宿主机为 minikube docker 实例：

        docker ps

        ->

            CONTAINER ID   IMAGE                                                                 COMMAND                  CREATED      STATUS      PORTS                                                                                                                                  NAMES
            7d3bfa0a1d5a   registry.cn-hangzhou.aliyuncs.com/google_containers/kicbase:v0.0.32   "/usr/local/bin/entr…"   5 days ago   Up 2 days   127.0.0.1:49157->22/tcp, 127.0.0.1:49156->2376/tcp, 127.0.0.1:49155->5000/tcp, 127.0.0.1:49154->8443/tcp, 127.0.0.1:49153->32443/tcp   minikube

  * 进入 minikube docker 实例：

        # 可见，真实运行的容器实例运行在 minikube 容器实例里，即容器里面又运行了容器
        # 所以，访问真实容器实例，先进入 minikube 实例

        docker exec -it minikube /bin/bash

        docker ps

        ->

            CONTAINER ID   IMAGE                                                           COMMAND                  CREATED             STATUS             PORTS     NAMES
            eaf2b4ed4779   nginx                                                           "/docker-entrypoint.…"   4 minutes ago       Up 4 minutes                 k8s_nginx_nginx_mrh-cluster_017863e4-33a7-4d0f-a4a0-aecbb0e71f05_0
            af3dc0176dba   registry.cn-hangzhou.aliyuncs.com/google_containers/pause:3.6   "/pause"                 4 minutes ago       Up 4 minutes                 k8s_POD_nginx_mrh-cluster_017863e4-33a7-4d0f-a4a0-aecbb0e71f05_0
            64ae262263bb   6e38f40d628d                                                    "/storage-provisioner"   28 minutes ago      Up 28 minutes                k8s_storage-provisioner_storage-provisioner_kube-system_208f6f01-2f54-4454-a10d-21c1c8896fe0_15
            bb8702f1735f   e57a417f15d3                                                    "/metrics-server --c…"   About an hour ago   Up About an hour             k8s_metrics-server_metrics-server-854947c5d4-9jxmc_kube-system_07d7356c-7d10-44c4-978b-9484f93855b8_4
            ......

### Minikube 常用命令

  * 使用 minikube kubectl 指定命令别名：

        # 指定别名
        alias kubectl="minikube kubectl --"

        # 写入环境变量中
        echo 'alias kubectl="minikube kubectl --"' >> ~/.bash_profile

        # 等价命令
        # minikube kubectl -- get pods -A
        # kubectl get pods -A

  * 使用 --help 参数查看 minikube 命令选项：

        minikube provisions and manages local Kubernetes clusters optimized for development workflows.

        Basic Commands:
          start            Starts a local Kubernetes cluster
          status           Gets the status of a local Kubernetes cluster
          stop             Stops a running local Kubernetes cluster
          delete           Deletes a local Kubernetes cluster
          dashboard        Access the Kubernetes dashboard running within the minikube cluster
          pause            pause Kubernetes
          unpause          unpause Kubernetes

        Images Commands:
          docker-env       Configure environment to use minikube's Docker daemon
          podman-env       Configure environment to use minikube's Podman service
          cache            Manage cache for images
          image            Manage images

        Configuration and Management Commands:
          addons           Enable or disable a minikube addon
          config           Modify persistent configuration values
          profile          Get or list the current profiles (clusters)
          update-context   Update kubeconfig in case of an IP or port change

        Networking and Connectivity Commands:
          service          Returns a URL to connect to a service
          tunnel           Connect to LoadBalancer services

        Advanced Commands:
          mount            Mounts the specified directory into minikube
          ssh              Log into the minikube environment (for debugging)
          kubectl          Run a kubectl binary matching the cluster version
          node             Add, remove, or list additional nodes
          cp               Copy the specified file into minikube

        Troubleshooting Commands:
          ssh-key          Retrieve the ssh identity key path of the specified node
          ssh-host         Retrieve the ssh host key of the specified node
          ip               Retrieves the IP address of the specified node
          logs             Returns logs to debug a local Kubernetes cluster
          update-check     Print current and latest version number
          version          Print the version of minikube
          options          Show a list of global command-line options (applies to all commands).

        Other Commands:
          completion       Generate command completion for a shell

        Use "minikube <command> --help" for more information about a given command.

  * 使用 --help 参数查看 minikube kubectl -- 命令选项：

        kubectl controls the Kubernetes cluster manager.

         Find more information at: https://kubernetes.io/docs/reference/kubectl/overview/

        Basic Commands (Beginner):
          create        Create a resource from a file or from stdin
          expose        Take a replication controller, service, deployment or pod and expose it as a new Kubernetes service
          run           Run a particular image on the cluster
          set           Set specific features on objects

        Basic Commands (Intermediate):
          explain       Get documentation for a resource
          get           Display one or many resources
          edit          Edit a resource on the server
          delete        Delete resources by file names, stdin, resources and names, or by resources and label selector

        Deploy Commands:
          rollout       Manage the rollout of a resource
          scale         Set a new size for a deployment, replica set, or replication controller
          autoscale     Auto-scale a deployment, replica set, stateful set, or replication controller

        Cluster Management Commands:
          certificate   Modify certificate resources.
          cluster-info  Display cluster information
          top           Display resource (CPU/memory) usage
          cordon        Mark node as unschedulable
          uncordon      Mark node as schedulable
          drain         Drain node in preparation for maintenance
          taint         Update the taints on one or more nodes

        Troubleshooting and Debugging Commands:
          describe      Show details of a specific resource or group of resources
          logs          Print the logs for a container in a pod
          attach        Attach to a running container
          exec          Execute a command in a container
          port-forward  Forward one or more local ports to a pod
          proxy         Run a proxy to the Kubernetes API server
          cp            Copy files and directories to and from containers
          auth          Inspect authorization
          debug         Create debugging sessions for troubleshooting workloads and nodes

        Advanced Commands:
          diff          Diff the live version against a would-be applied version
          apply         Apply a configuration to a resource by file name or stdin
          patch         Update fields of a resource
          replace       Replace a resource by file name or stdin
          wait          Experimental: Wait for a specific condition on one or many resources
          kustomize     Build a kustomization target from a directory or URL.

        Settings Commands:
          label         Update the labels on a resource
          annotate      Update the annotations on a resource
          completion    Output shell completion code for the specified shell (bash, zsh or fish)

        Other Commands:
          alpha         Commands for features in alpha
          api-resources Print the supported API resources on the server
          api-versions  Print the supported API versions on the server, in the form of "group/version"
          config        Modify kubeconfig files
          plugin        Provides utilities for interacting with plugins
          version       Print the client and server version information

        Usage:
          kubectl [flags] [options]

        Use "kubectl <command> --help" for more information about a given command.
        Use "kubectl options" for a list of global command-line options (applies to all commands).
