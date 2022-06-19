
# 单点配置prometheus

### 下载安装包

    文档地址：https://prometheus.io/docs/introduction/overview/

    下载地址：https://prometheus.io/download/

    下载安装包：prometheus-2.36.1.linux-amd64.tar.gz

    上传到服务器目录：/usr/local/software

    服务器地址：192.168.140.130

### 解压配置

    解压安装包，输入命令：

        cd /usr/local/software

        tar -zxvf ./prometheus-2.36.1.linux-amd64.tar.gz

        mv ./prometheus-2.36.1.linux-amd64 ../

        cd ..

        ln -s prometheus-2.36.1.linux-amd64/ prometheus

    更改配置文件，输入命令：

        cd /usr/local/prometheus

        vi prometheus.yml

        =>

            # 全局配置
            global:
              # 抓取时间间隔
              scrape_interval: 15s
              # 抓取超时时间
              scrape_timeout: 10s
              # 告警规则计算时间间隔
              evaluation_interval: 15s

            # 抓取配置
            scrape_configs:
              - job_name: "prometheus"
                scheme: http
                static_configs:
                  - targets: ["192.168.140.130:9090"]
                    labels:
                      cluster: mrh-cluster
                      service: prometheus

### 启动访问

    输入命令：

        cd /usr/local/prometheus

        # 非后台守护进程方式启动
        ./prometheus --config.file=prometheus.yml

        # 后台守护进程方式启动
        nohup ./prometheus --config.file=prometheus.yml > /usr/local/prometheus/prometheus.log 2>&1 &

    访问页面：

        http://192.168.140.130:9090/metrics

        http://192.168.140.130:9090
