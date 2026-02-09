
# 存储配置 prometheus

### 使用外部存储

    prometheus 默认使用本地时序数据库进行数据读写操作，服务器断电或重启可能会导致 prometheus data 目录存储块损坏

    如果需要保证历史数据，需要配置远程读写，修改配置文件：

### 安装 InfluxDB 时序数据库

    执行命令
    
        wget https://dl.influxdata.com/influxdb/releases/influxdb-1.6.2.x86_64.rpm
        
        sudo yum localinstall influxdb-1.6.2.x86_64.rpm
        
    更改配置
    
        vim /etc/influxdb/influxdb.conf
        
        =>
        
            [meta]
              dir = "/usr/local/influxdb/meta"

            [data]
              dir = "/usr/local/influxdb/data"
              wal-dir = "/usr/local/influxdb/wal"
              
            [http]
              enabled = true
              bind-address = ":8086"
              auth-enabled = false
              max-body-size = 0
              max-concurrent-write-limit = 0
              max-enqueued-write-limit = 0
              enqueued-write-timeout = 0
              
            [[graphite]]
              enabled = false
              database = "graphite"
              retention-policy = ""
              bind-address = ":2003"
              protocol = "tcp"
              consistency-level = "one"
              
    创建存储目录
    
        mkdir -p /usr/local/influxdb/
        
        chown -R influxdb:influxdb /usr/local/influxdb/
    
    配置开机自启
    
        vi /etc/systemd/system/influxd.service
        
        =>
        
            [Unit]
            Description=InfluxDB
            After=syslog.target network-online.target remote-fs.target nss-lookup.target
            Wants=network-online.target
            
            [Service]
            Type=simple
            ExecStart=/usr/bin/influxd
            Restart=always
            RestartSec=10s
            
            [Install]
            WantedBy=multi-user.target
            
         systemctl daemon-reload
         
         systemctl start influxd
         
         systemctl enable influxd

    创建 prometheus 数据库
    
        influx
        
        show databases
        
        create database prometheus
        
        use prometheus

### 配置 prometheus 远程读写

    更改配置
    
        vi prometheus.yml
        
        =>
        
            # 远程读写
            remote_write:
              - url: "http://localhost:8086/api/v1/prom/write?db=prometheus"
            remote_read:
              - url: "http://localhost:8086/api/v1/prom/read?db=prometheus"

    重启查看是否存储成功
    
        influx

        use prometheus
        
        show measurements
        
    