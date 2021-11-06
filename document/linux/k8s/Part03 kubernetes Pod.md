
# kubernetes

	Pod 集群逻辑主机，k8s 调度的最小单元，一个 Pod 包含一组容器，Pod 内的容器共享相同的ip和端口空间

	官网文档：https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.22/#pod-v1-core

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

#### Pod

	创建 Pod 配置，输入命令：

		cd /usr/local/kubernetes

		vi nginx-pod-config.yaml

	添加以下配置：

		apiVersion: v1
		kind: Pod
		metadata:
		  name: nginx
		spec:
		  containers:
		  - name: nginx
		    image: nginx
		    ports:
		    - containerPort: 80
		      hostPort: 80

	运行 Pod，输入命令：

		kubectl apply -f nginx-pod-config.yaml

		kubectl get pods -o wide

		curl $(kubectl get pods -o wide | grep nginx | awk -F ' ' '{print $7}')

	删除 Pod，输入命令：

		kubectl delete -f nginx-pod-config.yaml

#### Pod initContainers

	用于指定初始化工作的容器，一个或者多个按顺序执行

	创建 Pod 配置，输入命令：

		cd /usr/local/kubernetes

		vi nginx-pod-init-config.yaml

	添加以下配置：

		apiVersion: v1
		kind: Pod
		metadata:
		  name: nginx
		spec:
		  containers:
		  - name: nginx
		    image: nginx
		    ports:
		    - containerPort: 80
		      hostPort: 80
		  initContainers:
		  - name: centos
		    image: centos
		    command: ['sh', '-c','for i in {1..10}; do echo init; sleep 2; done']

	运行 Pod，输入命令：

		kubectl apply -f nginx-pod-init-config.yaml

		kubectl describe pod nginx

		kubectl get pod -o wide -w

		-> 等待20秒才开始PodInitializing

			NAME    READY   STATUS            RESTARTS   AGE   IP           NODE     NOMINATED NODE   READINESS GATES
			nginx   0/1     Init:0/1          0          6s    <none>       k8s208   <none>           <none>
			nginx   0/1     Init:0/1          0          7s    10.244.2.7   k8s208   <none>           <none>
			nginx   0/1     PodInitializing   0          27s   10.244.2.7   k8s208   <none>           <none>
			nginx   1/1     Running           0          31s   10.244.2.7   k8s208   <none>           <none>

	删除 Pod，输入命令：

		kubectl delete -f nginx-pod-init-config.yaml

#### Pod readiness

	readnessProbe 用于检测是否准备好对外提供服务，不正常则继续检测直到成功或指定条件为止

	创建 Pod 配置，输入命令：

		cd /usr/local/kubernetes

		vi nginx-pod-config.yaml

	添加以下配置：

		apiVersion: v1
		kind: Pod
		metadata:
		  name: nginx
		spec:
		  containers:
		  - name: nginx
		    image: nginx
		    ports:
		    - containerPort: 80
		      hostPort: 80
		    readinessProbe:
		      periodSeconds: 2
		      timeoutSeconds: 1
		      tcpSocket:
		        port: 8080

	运行 Pod，输入命令：

		kubectl apply -f nginx-pod-config.yaml

		kubectl get pod -o wide -w

		-> 不停检测无法提供服务 READY=0

			NAME    READY   STATUS              RESTARTS   AGE   IP           NODE     NOMINATED NODE   READINESS GATES
			nginx   0/1     ContainerCreating   0          3s    <none>       k8s208   <none>           <none>
			nginx   0/1     Running             0          5s    10.244.2.9   k8s208   <none>           <none>

#### Pod liveness

	livenessProbe 用于检测应用程序是否运行正常，不正常则重启 Pod 直到成功或指定条件为止

	创建 Pod 配置，输入命令：

		cd /usr/local/kubernetes

		vi nginx-pod-config.yaml

	添加以下配置：

		apiVersion: v1
		kind: Pod
		metadata:
		  name: nginx
		spec:
		  containers:
		  - name: nginx
		    image: nginx
		    ports:
		    - containerPort: 80
		      hostPort: 80
		    livenessProbe:
		      periodSeconds: 2
		      timeoutSeconds: 1
		      tcpSocket:
		        port: 8080

	运行 Pod，输入命令：

		kubectl apply -f nginx-pod-config.yaml

		kubectl describe pod nginx

		kubectl get pod -o wide -w

		-> 启动完成后一直重启

			NAME    READY   STATUS              RESTARTS     AGE   IP            NODE     NOMINATED NODE   READINESS GATES
			nginx   0/1     ContainerCreating   0            3s    <none>        k8s208   <none>           <none>
			nginx   0/1     Running             0            10s   10.244.2.10   k8s208   <none>           <none>
			nginx   1/1     Running             0            10s   10.244.2.10   k8s208   <none>           <none>
			nginx   0/1     Running             1 (6s ago)   19s   10.244.2.10   k8s208   <none>           <none>
			nginx   1/1     Running             1 (6s ago)   19s   10.244.2.10   k8s208   <none>           <none>
			nginx   0/1     Running             2 (6s ago)   29s   10.244.2.10   k8s208   <none>           <none>
			nginx   1/1     Running             2 (6s ago)   29s   10.244.2.10   k8s208   <none>           <none>
