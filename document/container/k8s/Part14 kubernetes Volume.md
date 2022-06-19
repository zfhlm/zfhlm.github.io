
# kubernetes

    Volume 用于临时存储或永久存储的 k8s Pod 挂载目录

    官方文档：https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.22/#volume-v1-core

#### emptyDir

    挂载空卷，输入命令：

        vi centos-pod.yaml

        =>

            apiVersion: v1
            kind: Pod
            metadata:
              name: centos
            spec:
              containers:
              - image: centos
               name: centos
               volumeMounts:
               - mountPath: /cache
                name: cache-volume
               command: ["/usr/sbin/init"]
              volumes:
              - name: cache-volume
                emptyDir: {}

        kubectl apply -f centos-pod.yaml

        kubectl get pod -o wide

        kubectl exec -it centos -- /bin/sh

        ls /cache

#### hostPath

    挂载本地宿主机卷，输入命令：

        mkdir /usr/local/logs

        echo test > /usr/local/logs/index.html

        vi centos-pod.yaml

        =>

            apiVersion: v1
            kind: Pod
            metadata:
              name: centos
            spec:
              containers:
              - image: centos
                name: centos
                volumeMounts:
                - mountPath: /usr/local/logs
                  name: logs-volume
                command: ["/usr/sbin/init"]
              volumes:
              - name: logs-volume
                hostPath:
                  path: /usr/local/logs
                  type: DirectoryOrCreate

        kubectl apply -f centos-pod.yaml

        kubectl get pod -o wide

        kubectl exec -it centos -- /bin/sh

        cd /usr/local/logs

        echo '12345' > index.html

        exit

    宿主机查看挂载目录，输入命令：

        cat /usr/local/logs/index.html

        -> 12345
