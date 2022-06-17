
# skywalking backend 监控告警配置

### 告警配置

    文档地址：

        https://skywalking.apache.org/docs/main/latest/en/setup/backend/backend-alarm/

    输入命令：

        cd /usr/local/skywalking

        vi config/alarm-settings.yml

        =>

            rules:

              # 响应时间告警配置
              service_resp_time_rule:
                metrics-name: service_resp_time
                op: ">"
                threshold: 1000
                period: 10
                count: 3
                silence-period: 5
                message: Response time of service {name} is more than 1000ms in 3 minutes of last 10 minutes.

              # 服务调用超时告警配置
              service_instance_resp_time_rule:
                metrics-name: service_instance_resp_time
                op: ">"
                threshold: 1000
                period: 10
                count: 2
                silence-period: 5
                message: Response time of service instance {name} is more than 1000ms in 2 minutes of last 10 minutes

              # 数据库告警配置
              database_access_resp_time_rule:
                metrics-name: database_access_resp_time
                threshold: 1000
                op: ">"
                period: 10
                count: 2
                message: Response time of database access {name} is more than 1000ms in 2 minutes of last 10 minutes

            # 告警回调接口，接口实现通知逻辑
            webhooks:
              - http://127.0.0.1/notify/
