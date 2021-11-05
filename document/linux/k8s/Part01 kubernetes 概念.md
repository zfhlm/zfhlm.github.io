
# kubernetes

	Kubernetes 是一个可移植的、可扩展的开源平台，用于管理容器化的工作负载和服务。

	官网地址：

		https://kubernetes.io/

	官方文档地址：

		https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.22/

		https://git.k8s.io/community/contributors/devel/sig-architecture/api-conventions.md

#### Kubernetes 组件

	k8s组件：

		kube-apiserver                   集群操作入口，负责提供 HTTP API，以供用户、集群中的不同部分和集群外部组件相互通信

		etcd                             集群数据存储，保存集群状态数据

		kube-scheduler                   集群资源调度，根据调度策略将 Pod 调度到对应的 Node

		kube-controller-manager          集群状态维护，如故障检测、自动扩展、滚动更新等

		kubelet                          集群运行代理，保证容器都运行在 Pod 中，管理容器 Volume 和 Network

		kube-proxy                       集群网络代理，提供服务发现和负载均衡等

		Container Runtime                集群容器服务，提供容器运行环境

		Addons                           可选或默认插件，例如 DNS插件、可视化管理界面插件、网络插件、资源监控插件、集群日志插件等

	k8s组件交互流程：

		+--------------------------------------+   +------------------+
		| Control Plane                        |   |       Node       |
		|                                      |   |                  |
		|        etcd <---------- apiserver <---------+               |
		|                          |    |      |   |  |               |
		| controller-manager <-----+    |      |   |  +-- kubelet     |
		|                               |      |   |  |               |
		|    scheduler <----------------+      |   |  +-- kube-proxy  |
		|                                      |   |                  |
		+--------------------------------------+   +------------------+

#### Kubernetes Pod

	相关概念：

		Node          集群主机，每一台加入集群的物理机或虚拟机都是一个 Node

		Pod           集群逻辑主机，k8s 调度的最小单元，一个 Pod 包含一组容器，Pod 内的容器共享相同的ip和端口空间

	生命周期：

		+---------------------------------------------------------------------+
		|   initContainers -> |      ------------- liveness ------------ |    |
		|                     |      readiness                           |    |
		|                     | --------- container runtime -----------> |    |
		|                     | start                               stop |    |
		+---------------------------------------------------------------------+

	运行状态：

		Pending       Pod 已被 Kubernetes 系统接受，但有一个或者多个容器尚未创建亦未运行。

		Running       Pod 已经绑定到了某个节点，Pod 中所有的容器都已被创建。至少有一个容器仍在运行，或者正处于启动或重启状态。

		Succeeded     Pod 中的所有容器都已成功终止，并且不会再重启。

		Failed        Pod 中的所有容器都已终止，并且至少有一个容器是因为失败终止。也就是说，容器以非 0 状态退出或者被系统终止。

		Unknown       因为某些原因无法取得 Pod 的状态。这种情况通常是因为与 Pod 所在主机通信失败。

#### Kubernetes workload resources

	工作负载（workload resources）是在 Kubernetes 上运行的应用程序，用于管理一组 Pods

	有以下几种 workload resources：

		Deployment    管理 ReplicaSet，并向 Pod 提供声明式的更新以及许多其他有用的功能

		ReplicaSet    确保任何时间都有指定数量的 Pod 副本在运行，一般不直接使用 ReplicaSet

		StatefulSet   主要面向有状态应用，例如持久化存储、服务编排

		DaemonSet     确保全部（或者某些）节点上运行一个 Pod 的副本，例如可以运行 filebeat

		Job           以一种可靠的方式运行某 Pod 直到完成

		CronJob       周期性地在给定的调度时间执行Job

#### Kubernetes service

	服务（service）将运行在一组 Pods 上的应用程序公开为网络服务的抽象方法，service 只能做四层负载均衡

	有以下几种类型：

		ClusterIP     通过集群的内部 IP 暴露服务，选择该值时服务只能够在集群内部访问。 这也是默认的 ServiceType。

		NodePort      通过每个节点上的 IP 和静态端口（NodePort）暴露服务。 NodePort 服务会路由到自动创建的 ClusterIP 服务。
		              通过请求 <节点 IP>:<节点端口>，你可以从集群的外部访问一个 NodePort 服务。

		LoadBalancer  使用云提供商的负载均衡器向外部暴露服务。 外部负载均衡器可以将流量路由到自动创建的 NodePort 服务和 ClusterIP 服务上。

		ExternalName  通过返回 CNAME 和对应值，可以将服务映射到 externalName 字段的内容（例如，foo.bar.example.com）。 无需创建任何类型代理。

#### Kubernetes Ingress

	对集群中服务的外部访问进行管理的 API 对象

	目前支持和维护 AWS， GCE 和 nginx Ingress 控制器

#### kubernetes configmap

	ConfigMap 是一个 API 对象， 让你可以存储其他对象所需要使用的配置。

	ConfigMap 最常见的用法是为同一命名空间里某 Pod 中运行的容器执行配置。

#### Kubernetes Secret

	Secret 是一种包含少量敏感信息例如密码、令牌或密钥的对象。

	内置的几种类型：

		Opaque                                         用户定义的任意数据

		kubernetes.io/service-account-token            服务账号令牌

		kubernetes.io/dockercfg                        ~/.dockercfg 文件的序列化形式

		kubernetes.io/dockerconfigjson                 ~/.docker/config.json 文件的序列化形式

		kubernetes.io/basic-auth                      用于基本身份认证的凭据

		kubernetes.io/ssh-auth                        用于 SSH 身份认证的凭据

		kubernetes.io/tls                             用于 TLS 客户端或者服务器端的数据

		bootstrap.kubernetes.io/token                 启动引导令牌数据
