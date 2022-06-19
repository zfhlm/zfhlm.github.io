
# 联邦集群 prometheus

### 服务器准备

    三台服务器：

        192.168.140.130     监控节点一，部署 prometheus、nginx exporter、node exporter、grafana

        192.168.140.131     监控节点二，部署 prometheus、node exporter

        192.168.140.132     联邦节点，部署 prometheus、node exporter

    说明：

        监控节点一，监控本机的 nginx进程、服务器资源信息、prometheus自身进程

        监控节点二，监控本机的 服务器资源信息、prometheus自身进程

        联邦节点，监控本机的 服务器资源信息、prometheus自身进程，并对节点一、节点二的监控信息进行聚合

### 集群配置

    监控节点一，prometheus配置：

        scrape_configs:
          - job_name: "prometheus"
            scheme: http
            static_configs:
              - targets: ["192.168.140.130:9090"]
                labels:
                  cluster: mrh-cluster
                  service: prometheus
          - job_name: "node_exporter"
            scheme: http
            static_configs:
              - targets: ["192.168.140.130:9100"]
                labels:
                  cluster: mrh-cluster
                  service: linux-server
          - job_name: "nginx-vts-exporter"
            scheme: http
            static_configs:
              - targets: ["192.168.140.130:9913"]
                labels:
                  cluster: mrh-cluster
                  service: nginx

    监控节点二，prometheus配置：

        scrape_configs:
          - job_name: "prometheus"
            scheme: http
            static_configs:
              - targets: ["192.168.140.131:9090"]
                labels:
                  cluster: mrh-cluster
                  service: prometheus
          - job_name: "node_exporter"
            scheme: http
            static_configs:
              - targets: ["192.168.140.131:9100"]
                labels:
                  cluster: mrh-cluster
                  service: linux-server

    联邦节点，prometheus配置：

        scrape_configs:
          - job_name: "prometheus"
            scheme: http
            static_configs:
              - targets: ["192.168.140.132:9090"]
                labels:
                  cluster: mrh-cluster
                  service: prometheus
          - job_name: "node_exporter"
            scheme: http
            static_configs:
              - targets: ["192.168.140.132:9100"]
                labels:
                  cluster: mrh-cluster
                  service: linux-server
          # 抓取其他prometheus的监控信息
          - job_name: 'federate'
            scrape_interval: 15s
            honor_labels: true
            metrics_path: /federate
            params:
              'match[]':
                - '{job="prometheus"}'
                - '{job="node_exporter"}'
                - '{job="nginx_vts_exporter"}'
            static_configs:
              - targets:
                - '192.168.140.130:9090'
                - '192.168.140.131:9090'

### grafana展示

    数据源使用 http://192.168.140.132:9090

    使用 Node Exporter 模板进行配置，可以看到三台服务器信息
