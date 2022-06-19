
# kubernetes

    Ingress 可以提供负载均衡、SSL 终结和基于名称的虚拟托管，基于七层的反向代理

    官方文档：https://kubernetes.io/docs/concepts/services-networking/ingress/

    Ingress Nginx：https://kubernetes.github.io/ingress-nginx/

#### Prepared

    运行测试 Pod 和 Service，输入命令：

        cd /usr/local/kubernetes

        vi nginx

#### Ingress Nginx

    创建 Tomcat 配置，输入命令：

        cd /usr/local/kubernetes

        vi tomcat-deploy.yaml

    添加以下配置：

        apiVersion: apps/v1
        kind: Deployment
        metadata:
          name: tomcat
        spec:
          replicas: 2
          selector:
            matchLabels:
              app: tomcat
          template:
            metadata:
              labels:
                app: tomcat
            spec:
              containers:
              - name: tomcat
                image: tomcat
                ports:
                - containerPort: 8080
        ---
        apiVersion: v1
        kind: Service
        metadata:
          name: tomcat
        spec:
          type: ClusterIP
          ports:
          - name: http
            port: 8080
            targetPort: 8080
          selector:
            app: tomcat
        ---
        apiVersion: networking.k8s.io/v1
        kind: Ingress
        metadata:
          name: tomcat-ingress
          annotations:
            kubernetes.io/ingress.class: "nginx"
        spec:
          rules:
            - http:
               paths:
               - path: /
                pathType: 'Prefix'
                backend:
                  service:
                    name: tomcat
                    port:
                      number: 8080

    运行 Tomcat，输入命令：

        kubectl apply -f tomcat-deploy.yaml

        kubectl get svc -o wide

        -> 输出信息

          NAME         TYPE        CLUSTER-IP    EXTERNAL-IP   PORT(S)    AGE   SELECTOR
          kubernetes   ClusterIP   10.1.0.1      <none>        443/TCP    32h   <none>
          tomcat       ClusterIP   10.1.109.89   <none>        8080/TCP   20s   app=tomcat

    运行 Ingress Nginx，输入命令：

        wget -o ingress-controller-v1.0.4.tar.gz https://github.com/kubernetes/ingress-nginx/archive/refs/tags/controller-v1.0.4.tar.gz

        tar -zxvf ingress-controller-v1.0.4.tar.gz

        mv ./ingress-nginx-controller-v1.0.4/deploy/static/provider/baremetal/deploy.yaml ./ingress-nginx-deploy.yaml

        kubectl apply -f ingress-nginx-deploy.yaml

        kubectl get svc -o wide -n ingress-nginx

        -> 输出信息

          NAME                                 TYPE        CLUSTER-IP     EXTERNAL-IP   PORT(S)                      AGE
          ingress-nginx-controller             NodePort    10.1.205.206   <none>        80:32236/TCP,443:30852/TCP   25s
          ingress-nginx-controller-admission   ClusterIP   10.1.30.75     <none>        443/TCP                      26s

    访问 Ingress Nginx 地址：

        http://192.168.140.206:32236

        http://192.168.140.207:32236

        http://192.168.140.208:32236
