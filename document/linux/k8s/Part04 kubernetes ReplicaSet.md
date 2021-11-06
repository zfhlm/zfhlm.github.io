
# kubernetes

	ReplicaSet 通常用来保证给定数量的、完全相同的 Pod 的可用性

	注意，一般不直接使用 ReplicaSet，而是使用 Deployment 来管理 Pod

	官网文档：https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.22/#replicaset-v1-apps

#### ReplicaSet

	创建配置，输入命令：

		cd /usr/local/kubernetes

		vi nginx-rs-config.yaml

	添加以下配置：

		apiVersion: apps/v1
		kind: ReplicaSet
		metadata:
		name: nginx
		spec:
		replicas: 3
		selector:
			matchLabels:
				app: nginx
		template:
			metadata:
				labels:
					app: nginx
			spec:
				containers:
				- name: nginx
					image: nginx
					ports:
						- containerPort: 80

	发布 ReplicaSet，输入命令：

		kubectl apply -f nginx-rs-config.yaml

		kubectl get rs -o wide

		kubectl get pod -o wide -w

		-> 可以看到运行了一个 rs 和 三个 Pod

			NAME          READY   STATUS    RESTARTS   AGE    IP            NODE     NOMINATED NODE   READINESS GATES
			nginx-m645f   1/1     Running   0          105s   10.244.2.12   k8s208   <none>           <none>
			nginx-n22mg   1/1     Running   0          105s   10.244.1.4    k8s207   <none>           <none>
			nginx-qhlzd   1/1     Running   0          105s   10.244.2.13   k8s208   <none>           <none>

	删除任意 Pod，输入命令：

		kubectl delete pod nginx-m645f

		kubectl get pod -o wide -w

		-> 可以看到又创建新的 Pod 来维持三个副本数
			
			NAME          READY   STATUS              RESTARTS   AGE     IP            NODE     NOMINATED NODE   READINESS GATES
			nginx-n22mg   1/1     Running             0          2m41s   10.244.1.4    k8s207   <none>           <none>
			nginx-qhlzd   1/1     Running             0          2m41s   10.244.2.13   k8s208   <none>           <none>
			nginx-tqq4b   0/1     ContainerCreating   0          3s      <none>        k8s207   <none>           <none>

	停止 ReplicaSet，输入命令：

		kubectl delete -f nginx-rs-config.yaml
