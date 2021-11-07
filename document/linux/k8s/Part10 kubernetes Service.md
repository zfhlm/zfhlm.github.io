
# kubernetes

    Service 用于将运行在一组 Pods 上的应用程序公开为网络服务的抽象方法，基于四层的负载均衡

    有以下几种类型：

        ClusterIP     通过集群的内部 IP 暴露服务，默认类型，只能在集群内部访问

        NodePort      通过集群的每个 Node 上的 IP 和 port 暴露服务，允许设置 kube-proxy 过滤 NodeIP,可以对外访问

        LoadBalancer  使用云提供商的负载均衡器向外部暴露服务，可以对外访问

        ExternalName  将指定的域名或 IP 地址暴露为服务，只能在集群内部访问

    官方文档：https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.22/#service-v1-core

#### Deployment Prepared

    先创建 nginx deployment，输入命令：

        cd /usr/local/kubernetes

        vi nginx-deployment-config.yaml

    添加以下配置：

        apiVersion: apps/v1
        kind: Deployment
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

    运行 nginx deployment，输入命令：

        kubectl apply -f nginx-deployment-config.yaml

        kubectl get pod -o wide -w

#### Service ClusterIP

    创建 service 配置，输入命令：

        vi nginx-service-config.yaml

    添加以下配置：

        apiVersion: v1
        kind: Service
        metadata:
          name: nginx
        spec:
          type: ClusterIP
          ports:
          - name: http
            port: 80
            targetPort: 80
          selector:
            app: nginx

    运行 nginx service，输入命令：

        kubectl apply -f nginx-service-config.yaml

        kubectl get svc -o wide

        -> 输出 service 信息

            NAME         TYPE           CLUSTER-IP     EXTERNAL-IP   PORT(S)        AGE     SELECTOR
            nginx        LoadBalancer   10.1.237.254   <pending>     80:30519/TCP   35s     app=nginx

        kubectl get pod -o wide

        -> 输出三个 nginx pod

            NAME                     READY   STATUS    RESTARTS   AGE   IP            NODE     NOMINATED NODE   READINESS GATES
            nginx-7848d4b86f-fp85v   1/1     Running   0          12m   10.244.2.40   k8s208   <none>           <none>
            nginx-7848d4b86f-l9mlq   1/1     Running   0          12m   10.244.2.41   k8s208   <none>           <none>
            nginx-7848d4b86f-zwqm9   1/1     Running   0          12m   10.244.1.14   k8s207   <none>           <none>

        ipvsadm -Ln

        -> 输出 ipvs 代理信息，

            RemoteAddress:Port           Forward Weight ActiveConn InActConn       
            TCP  10.1.237.254:80 rr
            -> 10.244.1.14:80               Masq    1      0          0         
            -> 10.244.2.40:80               Masq    1      0          0         
            -> 10.244.2.41:80               Masq    1      1          0     

    访问 nginx service，输入命令：

        curl 10.1.237.254

        -> Welcome to nginx!

    移除 nginx service，输入命令：

        kubectl delete -f nginx-service-config.yaml

#### Service NodePort

    修改配置，输入命令：

        vi nginx-service-config.yaml

    更改以下配置：

        apiVersion: v1
        kind: Service
        metadata:
        name: nginx
        spec:
          type: NodePort
          ports:
          - name: http
            port: 80
            targetPort: 80
            nodePort: 30000
          selector:
            app: nginx

    运行 nginx service，输入命令：

        kubectl apply -f nginx-service-config.yaml

        kubectl get svc -o wide

    浏览器访问 nginx service：

        192.168.140.206:30000

        192.168.140.207:30000

        192.168.140.208:30000

        -> Welcome to nginx!

#### Service ExternalName

    创建配置文件，输入命令：

        vi baidu-external-config.yaml

    添加以下配置：

        apiVersion: v1
        kind: Service
        metadata:
        name: baidu
        spec:
          type: ExternalName
          externalName: www.baidu.com

    运行 service，输入命令：

        kubectl apply -f baidu-external-config.yaml

        kubectl get svc -o wide

    创建一个 centos pod，输入命令：

        vi centos-pod-config.yaml

    添加以下配置：

        apiVersion: v1
        kind: Pod
        metadata:
        name: centos
        spec:
        containers:
        - name: centos
          image: centos
          command: ['/usr/sbin/init']

    启动 centos pod，输入命令：

        kubectl apply -f centos-pod-config.yaml

    进入 centos 执行 ping，输入命令：

        kubectl exec -i -t centos -- /bin/bash

        ping baidu.default.svc.cluster.local

        -> 输出信息

            64 bytes from 14.215.177.38 (14.215.177.38): icmp_seq=1 ttl=127 time=13.1 ms
            64 bytes from 14.215.177.38 (14.215.177.38): icmp_seq=2 ttl=127 time=11.9 ms
            64 bytes from 14.215.177.38 (14.215.177.38): icmp_seq=3 ttl=127 time=11.7 ms
            64 bytes from 14.215.177.38 (14.215.177.38): icmp_seq=4 ttl=127 time=11.9 ms
            4 packets transmitted, 4 received, 0% packet loss, time 3005ms
