
# Kubernetes 运行策略资源

  * 官方文档：

        https://kubernetes.io/docs/home/

        https://kubernetes.io/docs/concepts/policy/

        https://kubernetes.io/docs/reference/kubernetes-api/policy-resources/

  * 资源介绍：

        LimitRange              # 单例限额策略，例如：限制 namespace 每个 Pod 最大内存使用量、最大 CPU 使用核数

        ResourceQuota           # 总量限额策略，例如：限制 namespace 所有 Pod 总 CPU 核数、总内存使用量

        PodDisruptionBudget     # 中断预算策略，当节点驱逐 Pod 时，保障 Pod 可用数

        NetworkPolicy           # 网络策略，对 Pod 允许的网络流量进行控制

## LimitRange

  * 配置示例：

        apiVersion: v1
        kind: LimitRange
        metadata:
          name: mrh-cluster-limit-range
          namespace: mrh-cluster
          labels:
            cluster: mrh-cluster
            created-by: mrh
            website: zfhlm.github.io
        spec:
          limits:
            # 限制 Pod 资源额度
          - type: Pod
            max:
              cpu: '4.0'
              memory: 8Gi
            # 限制 PVC 存储大小
          - type: PersistentVolumeClaim
            max:
              storage: 100Gi
            min:
              storage: 1Gi

  * 查看限制情况：

        kubectl describe limitrange mrh-cluster-limit-range --namespace=mrh-cluster

        -->

            Name:                  mrh-cluster-limit-range
            Namespace:             mrh-cluster
            Type                   Resource  Min  Max    Default Request  Default Limit  Max Limit/Request Ratio
            ----                   --------  ---  ---    ---------------  -------------  -----------------------
            Pod                    cpu       -    4      -                -              -
            Pod                    memory    -    8Gi    -                -              -
            PersistentVolumeClaim  storage   1Gi  100Gi  -                -              -

## ResourceQuota

  * 配置示例：

        # 总量限额，假如 10 台 8核16G 服务器，分配到优先级高中低，分别为 60%、30%、10%
        # 高优先级总量限额
        apiVersion: v1
        kind: ResourceQuota
        metadata:
          name: resource-quota-critical-high
          namespace: mrh-cluster
          labels:
            created-by: mrh
            website: zfhlm.github.io
        spec:
          hard:
            limits.cpu: '48'
            limits.memory: 96Gi
          scopeSelector:
            matchExpressions:
            - operator : In
              scopeName: PriorityClass
              values: ['critical-high']
        -------------------------------------------------
        # 中优先级总量限额
        apiVersion: v1
        kind: ResourceQuota
        metadata:
          name: resource-quota-critical-middle
          namespace: mrh-cluster
          labels:
            created-by: mrh
            website: zfhlm.github.io
        spec:
          hard:
            limits.cpu: '24'
            limits.memory: 48Gi
          scopeSelector:
            matchExpressions:
            - operator : In
              scopeName: PriorityClass
              values: ['critical-middle']
        -------------------------------------------------
        # 低优先级总量限额
        apiVersion: v1
        kind: ResourceQuota
        metadata:
          name: resource-quota-critical-low
          namespace: mrh-cluster
          labels:
            created-by: mrh
            website: zfhlm.github.io
        spec:
          hard:
            limits.cpu: '8'
            limits.memory: 16Gi
          scopeSelector:
            matchExpressions:
            - operator : In
              scopeName: PriorityClass
              values: ['critical-low']

  * 查看限制情况：

        kubectl get ResourceQuota --namespace=mrh-cluster

        -->
            NAME                             AGE   REQUEST   LIMIT
            resource-quota-critical-high     83s             limits.cpu: 0/48, limits.memory: 0/96Gi
            resource-quota-critical-low      49s             limits.cpu: 0/8, limits.memory: 0/16Gi
            resource-quota-critical-middle   69s             limits.cpu: 500m/24, limits.memory: 32M/48Gi

## PodDisruptionBudget

  * 配置示例：

        apiVersion: policy/v1
        kind: PodDisruptionBudget
        metadata:
          name: pod-disruption-budget
          namespace: mrh-cluster
          labels:
            created-by: mrh
            website: zfhlm.github.io
        spec:
          # 最小可用数量
          minAvailable: 1
          # Pod 标签选择器
          selector:
            matchLabels:
              role: java
              application: mrh-spring-boot-service

  * 查看限制情况：

        kubectl -- get PodDisruptionBudget --namespace=mrh-cluster

        -->

            NAME                    MIN AVAILABLE   MAX UNAVAILABLE   ALLOWED DISRUPTIONS   AGE
            pod-disruption-budget   1               N/A               0                     19s

## NetworkPolicy

  * 配置示例：

        # 更加精细的控制，可以将 IP 段粒度细分进行控制，这里只做简单示例

        apiVersion: networking.k8s.io/v1
        kind: NetworkPolicy
        metadata:
          name: pod-network-policy
          namespace: mrh-cluster
          labels:
            created-by: mrh
            website: zfhlm.github.io
        spec:
          # Pod 标签选择器
          podSelector:
            matchLabels:
              role: java
              application: mrh-spring-boot-service
          # 控制流量类型：入口、出口、出入口按需配置
          policyTypes:
          - Ingress
          - Egress
          # 入口流量控制
          ingress:
          - from:
              # 允许访问的客户端 IP 段
            - ipBlock:
                cidr: 172.17.0.0/16
                except:
                - 172.17.255.0/24
                - 172.17.254.0/24
              # 允许访问的客户端命名空间
            - namespaceSelector:
                matchLabels:
                  created-by: mrh
              # 允许访问的客户端 Pod 标签
            - podSelector:
                matchLabels:
                  role: java
            # 允许访问的端口
            ports:
            - port: 8888
              protocol: TCP
          # 出口流量控制
          egress:
          - to:
              # 允许请求的服务端 IP 段
            - ipBlock:
                cidr: 172.17.0.0/16
                except:
                - 172.17.255.0/24
                - 172.17.254.0/24
              # 允许请求的服务端命名空间
            - namespaceSelector:
                matchLabels:
                  created-by: mrh
              # 允许请求的服务端 Pod 标签
            - podSelector:
                matchLabels:
                  role: java
            # 允许请求的端口
            ports:
            - port: 8888
              protocol: TCP
            - port: 8889
              protocol: TCP

  * 查看限制情况：

        kubectl describe NetworkPolicy pod-network-policy --namespace=mrh-cluster

        -->

            Name:         pod-network-policy
            Namespace:    mrh-cluster
            Created on:   2022-08-07 02:57:37 +0800 CST
            Labels:       created-by=mrh
                          website=zfhlm.github.io
            Annotations:  <none>
            Spec:
              PodSelector:     application=mrh-spring-boot-service,role=java
              Allowing ingress traffic:
                To Port: 8888/TCP
                From:
                  IPBlock:
                    CIDR: 172.17.0.0/16
                    Except: 172.17.255.0/24, 172.17.254.0/24
                From:
                  NamespaceSelector: created-by=mrh
                From:
                  PodSelector: role=java
              Allowing egress traffic:
                To Port: 8888/TCP
                To Port: 8889/TCP
                To:
                  IPBlock:
                    CIDR: 172.17.0.0/16
                    Except: 172.17.255.0/24, 172.17.254.0/24
                To:
                  NamespaceSelector: created-by=mrh
                To:
                  PodSelector: role=java
              Policy Types: Ingress, Egress
