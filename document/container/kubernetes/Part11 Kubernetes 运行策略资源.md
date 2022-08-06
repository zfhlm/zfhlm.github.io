
# Kubernetes 运行策略资源

  * 官方文档：

    https://kubernetes.io/docs/home/

    https://kubernetes.io/docs/concepts/policy/

    https://kubernetes.io/docs/reference/kubernetes-api/policy-resources/

## LimitRange

  * 简单介绍：

        LimitRange 用于对命名空间下，对指定类型的资源进行限额，例如限制每个 Pod 最大内存使用量、最大 CPU 使用核数

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

## ResourceQuota

  * 简单介绍：

        ResourceQuota 用于对命名空间下，对指定类型资源进行总量限额，例如限制所有 Pod CPU 总使用核数


## NetworkPolicy

## PodDisruptionBudget

## PodSecurityPolicy
