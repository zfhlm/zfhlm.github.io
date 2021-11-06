
# kubernetes

    Deployment 用于管理 ReplicaSet，并提供运行策略、更新策略、版本回滚等功能

    官网文档：https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.22/#deployment-v1-apps

#### Deployment

    创建配置，输入命令：

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

    发布 nginx，输入命令：

        kubectl apply -f nginx-deployment-config.yaml

        kubectl get deployment -o wide

        kubectl get rs -o wide

        kubectl get pod -o wide -w

    停止 nginx，输入命令：

        kubectl delete -f nginx-deployment-config.yaml

#### Deployment 版本升级

    创建配置，输入命令：

        cd /usr/local/kubernetes

        vi nginx-deployment-config.yaml

    添加以下配置：

        apiVersion: apps/v1
        kind: Deployment
        metadata:
        name: nginx
        spec:
        replicas: 3
        strategy:
          type: RollingUpdate
          rollingUpdate:
            maxSurge: 1
            maxUnavailable: 1
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

        kubectl apply -f nginx-deployment-config.yaml

        kubectl get pod -o wide

        -> 三个已运行 nginx Pod

            NAME                     READY   STATUS    RESTARTS   AGE     IP            NODE     NOMINATED NODE   READINESS GATES
            nginx-7848d4b86f-f6qj9   1/1     Running   0          4m12s   10.244.2.21   k8s208   <none>           <none>
            nginx-7848d4b86f-jnqvz   1/1     Running   0          4m12s   10.244.2.22   k8s208   <none>           <none>
            nginx-7848d4b86f-mwbgq   1/1     Running   0          4m12s   10.244.2.20   k8s208   <none>           <none>

        kubectl rollout history deployment nginx

        -> 升级历史信息

            REVISION  CHANGE-CAUSE
            1         <none>

    修改配置文件 nginx 镜像版本，输入命令：

        vi nginx-deployment-config.yaml

        => 更改以下配置

            spec.template.spec.containers[].image: nginx:1.21.3

    升级 nginx，输入命令：

        kubectl apply -f nginx-deployment-config.yaml

        kubectl get pod -o wide -w

        -> 可以看到 Pod 逐个被平滑替换

            NAME                     READY   STATUS              RESTARTS   AGE     IP            NODE     NOMINATED NODE   READINESS GATES
            nginx-7848d4b86f-42xn6   1/1     Running             0          86s     10.244.2.24   k8s208   <none>           <none>
            nginx-7848d4b86f-gksct   1/1     Running             0          86s     10.244.2.23   k8s208   <none>           <none>
            nginx-7848d4b86f-l4b44   1/1     Running             0          86s     10.244.1.9    k8s207   <none>           <none>
            nginx-f9cfb46d4-cgd7h    0/1     Pending             0          0s      <none>        <none>   <none>           <none>
            nginx-7848d4b86f-gksct   1/1     Terminating         0          4m59s   10.244.2.23   k8s208   <none>           <none>
            nginx-f9cfb46d4-cgd7h    0/1     Pending             0          0s      <none>        k8s208   <none>           <none>
            nginx-f9cfb46d4-cgd7h    0/1     ContainerCreating   0          0s      <none>        k8s208   <none>           <none>
            nginx-f9cfb46d4-srblf    0/1     Pending             0          0s      <none>        <none>   <none>           <none>
            nginx-f9cfb46d4-srblf    0/1     Pending             0          0s      <none>        k8s208   <none>           <none>
            nginx-f9cfb46d4-srblf    0/1     ContainerCreating   0          0s      <none>        k8s208   <none>           <none>
            nginx-7848d4b86f-gksct   0/1     Terminating         0          5m      10.244.2.23   k8s208   <none>           <none>
            nginx-7848d4b86f-gksct   0/1     Terminating         0          5m      10.244.2.23   k8s208   <none>           <none>
            nginx-7848d4b86f-gksct   0/1     Terminating         0          5m      10.244.2.23   k8s208   <none>           <none>
            nginx-f9cfb46d4-srblf    1/1     Running             0          10s     10.244.2.25   k8s208   <none>           <none>
            nginx-7848d4b86f-42xn6   1/1     Terminating         0          5m9s    10.244.2.24   k8s208   <none>           <none>
            nginx-f9cfb46d4-vlqrj    0/1     Pending             0          0s      <none>        <none>   <none>           <none>
            nginx-f9cfb46d4-vlqrj    0/1     Pending             0          0s      <none>        k8s208   <none>           <none>
            nginx-f9cfb46d4-vlqrj    0/1     ContainerCreating   0          0s      <none>        k8s208   <none>           <none>
            nginx-7848d4b86f-42xn6   0/1     Terminating         0          5m10s   10.244.2.24   k8s208   <none>           <none>
            nginx-7848d4b86f-42xn6   0/1     Terminating         0          5m10s   10.244.2.24   k8s208   <none>           <none>
            nginx-7848d4b86f-42xn6   0/1     Terminating         0          5m10s   10.244.2.24   k8s208   <none>           <none>
            nginx-f9cfb46d4-cgd7h    1/1     Running             0          14s     10.244.2.26   k8s208   <none>           <none>
            nginx-7848d4b86f-l4b44   1/1     Terminating         0          5m13s   10.244.1.9    k8s207   <none>           <none>
            nginx-7848d4b86f-l4b44   0/1     Terminating         0          5m17s   <none>        k8s207   <none>           <none>
            nginx-7848d4b86f-l4b44   0/1     Terminating         0          5m17s   <none>        k8s207   <none>           <none>
            nginx-7848d4b86f-l4b44   0/1     Terminating         0          5m17s   <none>        k8s207   <none>           <none>
            nginx-f9cfb46d4-vlqrj    1/1     Running             0          9s      10.244.2.27   k8s208   <none>           <none>

        kubectl describe pod nginx-f9cfb46d4-vlqrj

        -> 查看 pod 信息，使用的镜像 nginx 1.21.3

            Type    Reason     Age   From               Message
            ----    ------     ----  ----               -------
            Normal  Pulling    28s   kubelet            Pulling image "nginx:1.21.3"
            Normal  Scheduled  27s   default-scheduler  Successfully assigned default/nginx-f9cfb46d4-vlqrj to k8s208
            Normal  Pulled     18s   kubelet            Successfully pulled image "nginx:1.21.3" in 9.80931302s
            Normal  Created    18s   kubelet            Created container nginx
            Normal  Started    17s   kubelet            Started container nginx

#### Deployment 版本回滚

    查看版本历史，输入命令：

        kubectl rollout history deployment nginx

        -> 输出升级版本历史

            REVISION  CHANGE-CAUSE
            1         <none>
            2         <none>

    回退到版本1，输入命令：

        kubectl rollout undo deployment nginx --to-revision=1

        kubectl get pod -o wide -w

        -> 可以看到 Pod 被逐个回退

            NAME                     READY   STATUS              RESTARTS   AGE     IP            NODE     NOMINATED NODE   READINESS GATES
            nginx-f9cfb46d4-cgd7h    1/1     Running             0          47s     10.244.2.26   k8s208   <none>           <none>
            nginx-f9cfb46d4-srblf    1/1     Running             0          47s     10.244.2.25   k8s208   <none>           <none>
            nginx-f9cfb46d4-vlqrj    1/1     Running             0          37s     10.244.2.27   k8s208   <none>           <none>
            nginx-7848d4b86f-hzvdx   0/1     Pending             0          0s      <none>        <none>   <none>           <none>
            nginx-f9cfb46d4-cgd7h    1/1     Terminating         0          5m31s   10.244.2.26   k8s208   <none>           <none>
            nginx-7848d4b86f-hzvdx   0/1     Pending             0          0s      <none>        k8s207   <none>           <none>
            nginx-7848d4b86f-29mkl   0/1     Pending             0          0s      <none>        <none>   <none>           <none>
            nginx-7848d4b86f-29mkl   0/1     Pending             0          0s      <none>        k8s207   <none>           <none>
            nginx-7848d4b86f-29mkl   0/1     ContainerCreating   0          0s      <none>        k8s207   <none>           <none>
            nginx-7848d4b86f-hzvdx   0/1     ContainerCreating   0          0s      <none>        k8s207   <none>           <none>
            nginx-f9cfb46d4-cgd7h    0/1     Terminating         0          5m32s   <none>        k8s208   <none>           <none>
            nginx-f9cfb46d4-cgd7h    0/1     Terminating         0          5m32s   <none>        k8s208   <none>           <none>
            nginx-f9cfb46d4-cgd7h    0/1     Terminating         0          5m32s   <none>        k8s208   <none>           <none>
            nginx-7848d4b86f-hzvdx   1/1     Running             0          42s     10.244.1.10   k8s207   <none>           <none>
            nginx-f9cfb46d4-vlqrj    1/1     Terminating         0          6m3s    10.244.2.27   k8s208   <none>           <none>
            nginx-7848d4b86f-lp7sb   0/1     Pending             0          0s      <none>        <none>   <none>           <none>
            nginx-7848d4b86f-lp7sb   0/1     Pending             0          0s      <none>        k8s208   <none>           <none>
            nginx-7848d4b86f-lp7sb   0/1     ContainerCreating   0          0s      <none>        k8s208   <none>           <none>
            nginx-f9cfb46d4-vlqrj    0/1     Terminating         0          6m5s    10.244.2.27   k8s208   <none>           <none>
            nginx-f9cfb46d4-vlqrj    0/1     Terminating         0          6m5s    10.244.2.27   k8s208   <none>           <none>
            nginx-f9cfb46d4-vlqrj    0/1     Terminating         0          6m5s    10.244.2.27   k8s208   <none>           <none>
            nginx-7848d4b86f-29mkl   1/1     Running             0          44s     10.244.1.11   k8s207   <none>           <none>
            nginx-f9cfb46d4-srblf    1/1     Terminating         0          6m15s   10.244.2.25   k8s208   <none>           <none>
            nginx-f9cfb46d4-srblf    0/1     Terminating         0          6m16s   10.244.2.25   k8s208   <none>           <none>
            nginx-f9cfb46d4-srblf    0/1     Terminating         0          6m16s   10.244.2.25   k8s208   <none>           <none>
            nginx-f9cfb46d4-srblf    0/1     Terminating         0          6m16s   10.244.2.25   k8s208   <none>           <none>
            nginx-7848d4b86f-lp7sb   1/1     Running             0          5s      10.244.2.28   k8s208   <none>           <none>

        kubectl describe pod nginx-7848d4b86f-lp7sb

        -> 查看 pod 信息，使用的镜像 nginx lastest

          Type    Reason     Age   From               Message
          ----    ------     ----  ----               -------
          Normal  Pulling    88s   kubelet            Pulling image "nginx"
          Normal  Scheduled  87s   default-scheduler  Successfully assigned default/nginx-7848d4b86f-lp7sb to k8s208
          Normal  Pulled     85s   kubelet            Successfully pulled image "nginx" in 3.089412414s
          Normal  Created    85s   kubelet            Created container nginx
          Normal  Started    85s   kubelet            Started container nginx
