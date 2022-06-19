
# kubernetes

    StatefulSet 用来管理某 Pod 集合的部署和扩缩， 并为这些 Pod 提供持久存储和持久标识符

    使用 StatefulSet 必须由 PersistentVolume 驱动，且需要 Headless Servive 来负责 Pod 的网络标识

    特点：

        稳定的、唯一的网络标识符

        稳定的、持久的存储

        有序的、优雅的部署和缩放

        有序的、自动的滚动更新

    可以使用 StatefulSet 进行服务编排，不建议用于部署 mysql 等服务

#### StatefulSet
