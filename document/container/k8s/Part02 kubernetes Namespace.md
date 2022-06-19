
# kubernetes

    Kubernetes 支持多个虚拟集群，它们底层依赖于同一个物理集群。 这些虚拟集群被称为名字空间

    官方文档：https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.22/#namespace-v1-core

#### Namespace

    创建 Namespace 输入命令：

        cd /usr/local/kubernetes

        vi namespace.yaml

        =>

            apiVersion: v1
            kind: Namespace
            metadata:
              name: test

        kubectl apply -f namespace.yaml

    其他对象指定命名空间：

        metadata:
          namespace: test
