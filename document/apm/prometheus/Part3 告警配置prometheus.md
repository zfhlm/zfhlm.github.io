
# 告警配置 prometheus

    192.168.140.132     部署prometheus，端口9090

    192.168.140.132     部署alertmanager，端口9093

### 更改prometheus配置

    更改运行配置，输入命令：

        cd /usr/local/prometheus

        vi prometheus.yml

        =>

            # alertmanager 配置
            alerting:
              alertmanagers:
                - static_configs:
                  - targets: ["192.168.140.132:9093"]

            # 告警规则文件配置
            rule_files:
              - 'rules/*.yml'

    添加规则配置，输入命令：

        cd /usr/local/prometheus

        mkdir rules

        vi node-rules.yml

        =>

            groups:
            - name: memory-rule
              rules:
              - alert: "内存不足"
                expr: 100 - ((node_memory_MemAvailable * 100) / node_memory_MemTotal) > 10
                for: 1m
                labels:
                  level: Minor
                annotations:
                  summary: "当前内存剩余不足{{ $value }}"
            - name: up-rule
              rules:
              - alert: "进程已下线"
                expr: up == 0
                for: 1m
                labels:
                  level: Urgent
                annotations:
                  summary: "该进程状态为已下线"
