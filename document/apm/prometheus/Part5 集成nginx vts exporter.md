
# prometheus 集成 nginx vts exporter

###  nginx 添加 vts 模块

    下载 nginx vts module 源码，输入命令：

        cd /usr/local/software

        wget https://github.com/vozlt/nginx-module-vts/archive/refs/tags/v0.1.18.tar.gz

        tar -zxvf v0.1.18.tar.gz

    进入 nginx 安装目录，输入命令：

        cd /usr/local/nginx

        ./sbin/nginx -V

        -> 输出编译信息：configure arguments: --prefix=/usr/local/nginx --with-http_ssl_module

    添加 nginx vts 模块，进入 nginx 源码目录，输入命令：

        # 注意已安装的nginx对应版本号，使用源码重新编译
        cd /usr/local/software/nginx-1.9.9

        # 上一步的输出信息，加 --add-module
        ./configure --prefix=/usr/local/nginx --with-http_ssl_module --add-module=/usr/local/software/nginx-module-vts-0.1.18

        # 注意提前备份好 nginx
        make && make install

    添加 nginx vts 配置，输入命令：

        cd /usr/local/nginx

        vi conf/nginx.conf

        =>

            http {
                vhost_traffic_status_zone;
                vhost_traffic_status_filter_by_host on;
                ...
                server {
                    ...
                    location /status {
                      vhost_traffic_status_display;
                      vhost_traffic_status_display_format html;
                    }
                }
            }

### 安装 nginx vts exporter

    服务器地址：

        192.168.140.130

    下载 nginx vts exporter，输入命令：

        cd /usr/local/software

        wget https://github.com/hnlq715/nginx-vts-exporter/releases/download/v0.10.3/nginx-vts-exporter-0.10.3.linux-amd64.tar.gz

        tar -zxvf ./nginx-vts-exporter-0.10.3.linux-amd64.tar.gz

        mv nginx-vts-exporter-0.10.3.linux-amd64/ ..

        cd ..

        ln -s nginx-vts-exporter-0.10.3.linux-amd64 nginx-vts-exporter

    启动 nginx vts exporter，输入命令：

        cd /usr/local/nginx-vts-exporter

        ./nginx-vts-exporter --help

        nohup ./nginx-vts-exporter -nginx.scrape_uri=http://localhost/status/format/json &

        tail -f nohup.out

    访问地址：

        http://192.168.140.130:9913/metrics

### 集成到 prometheus

    修改 prometheus 配置文件，输入命令：

        cd /usr/local/prometheus

        vi prometheus.yml

        =>

            scrape_configs:
              - job_name: "nginx_vts_exporter"
                metrics_path: /metrics
                scheme: http
                static_configs:
                  - targets: ["192.168.140.130:9913"]
                    labels:
                      cluster: mrh-cluster
                      service: nginx

    重启 prometheus 进程，即完成所有配置
