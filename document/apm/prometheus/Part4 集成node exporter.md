
# prometheus 集成 node exporter

### 安装 node exporter

    服务器地址：

        192.168.140.130

    下载安装包，输入命令：

        cd /usr/local/software

        wget https://github.com/prometheus/node_exporter/releases/download/v1.3.1/node_exporter-1.3.1.linux-amd64.tar.gz

        tar -zxvf ./node_exporter-1.3.1.linux-amd64.tar.gz

        mv node_exporter-1.3.1.linux-amd64 ..

        cd ..

        ln -s node_exporter-1.3.1.linux-amd64 node_exporter

    启动Node Exporter，输入命令：

        cd node_exporter

        nohup ./node_exporter &

    访问地址：

        http://192.168.140.130:9100/metrics

### 集成到 prometheus

    修改 prometheus 配置文件，输入命令：

        cd /usr/local/prometheus

        vi prometheus.yml

        =>

            scrape_configs:
              - job_name: "node_exporter"
                metrics_path: /metrics
                scheme: http
                static_configs:
                  - targets: ["192.168.140.130:9100"]
                    labels:
                      cluster: mrh-cluster
                      service: linux-server

    重启 prometheus 进程，即完成所有配置
