
# Kubernetes 工作负载资源

  * 官方文档：

        https://kubernetes.io/docs/home/

        https://kubernetes.io/docs/reference/kubernetes-api/workload-resources/

        https://kubernetes.io/docs/concepts/workloads/

## Pod

  * 文档地址：

        https://kubernetes.io/docs/concepts/workloads/pods/

        https://kubernetes.io/docs/tasks/configure-pod-container/

        https://kubernetes.io/docs/reference/kubernetes-api/workload-resources/pod-v1/

        https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.24/#pod-v1-core

  * Pod 运行状态：

        Pending                     # Pod 已被 Kubernetes 系统接受，但有一个或者多个容器尚未创建亦未运行。

        Running                     # Pod 已经绑定到了某个节点，Pod 中所有的容器都已被创建。至少有一个容器仍在运行，或者正处于启动或重启状态。

        Succeeded                   # Pod 中的所有容器都已成功终止，并且不会再重启。

        Failed                      # Pod 中的所有容器都已终止，并且至少有一个容器是因为失败终止。也就是说，容器以非 0 状态退出或者被系统终止。

        Unknown                     # 因为某些原因无法取得 Pod 的状态。这种情况通常是因为与 Pod 所在主机通信失败。

  * Pod 初始化容器、运行探针、生命周期钩子：

        initContainer               # 指定初始化工作的容器，一个或者多个按顺序执行

        startupProbe                # 启动探针

        readinessProbe              # 就绪探针

        livenessProbe               # 存活探针

        lifecycle.postStart         # 启动后执行

        lifecycle.preStop           # 停止前执行

  * Pod 对象配置，基于 nginx 示例：

        apiVersion: v1
        kind: Pod
        metadata:
          # 名称
          name: nginx
          # 命名空间
          namespace: mrh-cluster
          # 标签
          labels:
            cluster: mrh-cluster
            service: nginx
            created-by: mrh
            website: zfhlm.github.io
        spec:
          # 重启策略
          restartPolicy: Always
          # 选择存在以下 Label 的节点
          # nodeSelector:
          #   node-role.kubernetes.io/master
          # 容器配置
          containers:
          - name: nginx
            image: nginx
            imagePullPolicy: Always
            # 环境参数
            env:
            - name: test
              value: t1
            # 端口配置
            ports:
            - name: http
              protocol: TCP
              containerPort: 80
            # 资源限制
            resources:
              requests:
                cpu: 0.5
                memory: 32M
              limits:
                cpu: 0.5
                memory: 128M
            # 容器挂载，注意 name 对应 spec.volumes[n].name
            volumeMounts:
            - name: log
              mountPath: /var/log/nginx/
            # 就绪探针
            readinessProbe:
              initialDelaySeconds: 10
              periodSeconds: 5
              timeoutSeconds: 1
              tcpSocket:
                port: 80
            # 存活探针
            livenessProbe:
              initialDelaySeconds: 60
              timeoutSeconds: 2
              periodSeconds: 15
              tcpSocket:
                port: 80
            # 生命周期Hooks
            lifecycle:
              postStart:
                exec:
                  command: ['/bin/sh', '-c', 'echo postStart > /usr/share/nginx/html/index.html']
              preStop:
                exec:
                  command: ['/bin/sh', '-c', 'echo preStop > /usr/share/nginx/html/index.html']
          # 挂载配置
          volumes:
          - name: log
            # 宿主机目录
            hostPath:
              path: /var/log/nginx/

  * Pod 对象配置，基于 spring cloud 示例：

        apiVersion: v1
        kind: Pod
        metadata:
          name: nginx
          namespace: mrh-cluster
          labels:
            cluster: mrh-cluster
            service: mrh-spring-cloud-service-user
            created-by: mrh
            website: zfhlm.github.io
        spec:
          restartPolicy: Always
          containers:
          - name: mrh-spring-cloud-service-user
            image: mrh-spring-cloud-service-user:1.0
            imagePullPolicy: Always
            env:
            - name: SPRING_PROFILES_ACTIVE
              value: dev
            ports:
            - name: http
              protocol: TCP
              containerPort: 8888
            resources:
              requests:
                cpu: 1.0
                memory: 256M
              limits:
                cpu: 2.0
                memory: 2048M
            volumeMounts:
            - name: log
              mountPath: /usr/local/logs/
            # actuator 健康检测
            readinessProbe:
              initialDelaySeconds: 10
              periodSeconds: 5
              timeoutSeconds: 1
              httpGet:
                scheme: HTTP
                port: 8888
                path: /actuator/health
            # actuator 健康检测
            livenessProbe:
              initialDelaySeconds: 60
              timeoutSeconds: 2
              periodSeconds: 15
              httpGet:
                scheme: HTTP
                port: 8888
                path: /actuator/health
            # 停止前从注册中心移除当前实例
            lifecycle:
              preStop:
                exec:
                  command: ['/bin/sh', '-c', 'curl -X POST /actuator/serviceregistry -d {"status":"DOWN"} -H "Content-Type:application/json"']
          volumes:
          - name: log
            hostPath:
              path: /usr/local/logs/

## ReplicaSet

  * 文档地址：

        https://kubernetes.io/docs/concepts/workloads/controllers/replicaset/

        https://kubernetes.io/docs/reference/kubernetes-api/workload-resources/replica-set-v1/

        https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.24/#replicaset-v1-apps

  * ReplicaSet 对象配置，基于 nginx 示例：

        apiVersion: apps/v1
        kind: ReplicaSet
        metadata:
          name: nginx
          namespace: mrh-cluster
          labels:
            cluster: mrh-cluster
            created-by: mrh
            website: zfhlm.github.io
        spec:
          # Pod 副本数
          replicas: 3
          # Pod 匹配标签
          selector:
            matchLabels:
              cluster: mrh-cluster
              service: nginx
          # Pod 模板配置
          template:
            metadata:
              labels:
                cluster: mrh-cluster
                service: nginx
            spec:
              restartPolicy: Always
              containers:
              - name: nginx
                image: nginx
                imagePullPolicy: Always
                env:
                - name: test
                  value: t1
                ports:
                - name: http
                  protocol: TCP
                  containerPort: 80
                resources:
                  requests:
                    cpu: 0.1
                    memory: 32M
                  limits:
                    cpu: 0.2
                    memory: 128M
                volumeMounts:
                - name: log
                  mountPath: /var/log/nginx/
                readinessProbe:
                  initialDelaySeconds: 10
                  periodSeconds: 5
                  timeoutSeconds: 1
                  tcpSocket:
                    port: 80
                livenessProbe:
                  initialDelaySeconds: 60
                  timeoutSeconds: 2
                  periodSeconds: 15
                  tcpSocket:
                    port: 80
                lifecycle:
                  postStart:
                    exec:
                      command: ['/bin/sh', '-c', 'echo postStart > /usr/share/nginx/html/index.html']
                  preStop:
                    exec:
                      command: ['/bin/sh', '-c', 'echo preStop > /usr/share/nginx/html/index.html']
              volumes:
              - name: log
                hostPath:
                  path: /var/log/nginx/
