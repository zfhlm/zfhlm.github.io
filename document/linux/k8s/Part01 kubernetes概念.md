
# kubernetes

	Kubernetes 是一个可移植的、可扩展的开源平台，用于管理容器化的工作负载和服务。

	官网地址：https://kubernetes.io/

#### Kubernetes 组件

	k8s组件：

		Node                             集群主机，每一台加入集群的物理机或虚拟机都是一个 Node

		Pod                              集群逻辑主机，k8s 调度的最小单元，一个 Pod 包含一组容器，Pod 内的容器共享相同的ip和端口空间

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

#### Kubernetes 命令行工具

	两个自带的命令行工具：

		kubectl                           调用 kube-apiserver 实现集群对象管理

		kubeadm                           调用 kube-apiserver 实现集群节点初始化

#### Kubernetes 对象

	k8s 对象描述了容器信息、容器使用资源、容器运行策略等

	对象是目标性记录，一旦创建对象，k8s系统将持续工作以确保对象存在

	k8s 对象管理方式：

		指令式命令                        通过命令行参数声明对象

		指令式对象配置                    通过 yaml 配置文件声明对象(最常用)

		声明式对象配置                    通过文件目录声明多个对象

	使用对象运行 nginx 容器示例：

		# 指令式命令
		kubectl create deployment nginx --image nginx

		# 指令式对象配置
		kubectl create -f nginx.yaml

		# 声明式对象配置
		kubectl apply -f configs/
