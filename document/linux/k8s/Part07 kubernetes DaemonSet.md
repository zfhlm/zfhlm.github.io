
#### kubernetes

	DaemonSet 用于确保全部（或者某些）节点上运行一个 Pod 的副本

	官网文档：https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.22/#daemonset-v1-apps

#### DaemonSet

	创建配置，输入命令：

		cd /usr/local/kubernetes

		vi nginx-daemon-config.yaml

	添加以下配置：

		apiVersion: apps/v1
		kind: DaemonSet
		metadata:
		name: nginx
		spec:
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

	运行 nginx，输入命令：

		kubectl apply -f nginx-daemon-config.yaml

		kubectl get pod -o wide -w

		-> 每个节点都有个 nginx pod

			NAME          READY   STATUS    RESTARTS   AGE   IP            NODE     NOMINATED NODE   READINESS GATES
			nginx-nvk2s   1/1     Running   0          29s   10.244.2.32   k8s208   <none>           <none>
			nginx-w7t2z   1/1     Running   0          29s   10.244.1.12   k8s207   <none>           <none>
