
# prometheus 集成 mysql exporter

### 安装 mysql exporter

    下载安装包，输入命令：

        cd /usr/local/software

        wget https://github.com/prometheus/mysqld_exporter/releases/download/v0.14.0/mysqld_exporter-0.14.0.linux-amd64.tar.gz

        tar -zxvf mysqld_exporter-0.14.0.linux-amd64.tar.gz

        mv mysqld_exporter-0.14.0.linux-amd64 .. & cd ..

        ln -s mysqld_exporter-0.14.0.linux-amd64 mysqld_exporter

     添加配置文件，输入命令：

        cd /usr/local/mysqld_exporter

        vi my.cnf

        =>

            [client]
            host=127.0.0.1
            port=3306
            user=root
            password=123456

    启动服务，输入命令：

        cd /usr/local/mysqld_exporter

        nohup ./mysqld_exporter --config.my-cnf=./my.cnf &

    访问地址：

        http://192.168.140.130:9104/metrics

### 集成到 prometheus

    修改 prometheus 配置文件，输入命令：

        cd /usr/local/prometheus

        vi prometheus.yml

        =>

            scrape_configs:
              - job_name: "mysqld_exporter"
                metrics_path: /metrics
                scheme: http
                static_configs:
                  - targets: ["192.168.140.130:9104"]
                    labels:
                      cluster: mrh-cluster
                      service: mysql

    重启 prometheus 进程，即完成所有配置
