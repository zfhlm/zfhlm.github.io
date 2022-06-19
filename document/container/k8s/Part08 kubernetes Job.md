
# kubernetes

    Job 用于创建一个或者多个 Pods，并将继续重试 Pods 的执行，直到指定数量的 Pods 成功终止

    官网文档：https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.22/#job-v1-batch

#### Job

    创建配置，输入命令：

        cd /usr/local/kubernetes

        vi perl-job-config.yaml

    添加以下配置：

        apiVersion: batch/v1
        kind: Job
        metadata:
          name: pi
        spec:
          template:
            spec:
              containers:
              - name: pi
                image: perl
                command: ["perl",  "-Mbignum=bpi", "-wle", "print bpi(20)"]
              restartPolicy: Never
          backoffLimit: 4

    运行 Job，输入命令：

        kubectl apply -f perl-job-config.yaml

        kubectl get job -o wide

        kubectl get pod -o wide -w

        kubectl logs $(kubectl get pod -o wide | grep pi | awk -F ' ' '{print $1}')

        -> 3.1415926535897932385

    移除 Job，输入命令：

        kubectl delete -f perl-job-config.yaml
