
# kubernetes

	Kubernetes 是一个可移植的、可扩展的开源平台，用于管理容器化的工作负载和服务。

	官网地址：https://kubernetes.io/

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

	k8s集群：

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
