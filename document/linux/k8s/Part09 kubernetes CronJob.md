
# kubernetes

	CronJob 用于创建基于时隔重复调度的 Jobs

	官网文档：https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.22/#cronjob-v1-batch

#### CronJob

	创建配置，输入命令：

		cd /usr/local/kubernetes

		vi cron-config.yaml

	添加以下配置：

		apiVersion: batch/v1
		kind: CronJob
		metadata:
		  name: hello
		spec:
		  schedule: "*/1 * * * *"
		  jobTemplate:
		    spec:
		      template:
		        spec:
		          containers:
		          - name: hello
		            image: busybox
		            imagePullPolicy: IfNotPresent
		            command: ['/bin/sh', '-c', 'date; echo Hello from the Kubernetes cluster']
		          restartPolicy: OnFailure

	运行 CronJob，输入命令：

		kubectl apply -f cron-config.yaml

		kubectl get cronjob -o wide

		kubectl get pod -o wide

		kubectl logs hello-27269760--1-6nwsx

		-> 输出信息

			Sat Nov  6 07:58:59 UTC 2021
			Hello from the Kubernetes cluster
