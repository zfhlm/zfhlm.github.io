
# 告警配置 alertmanager

### 解压安装 alertmanager

    下载安装包：

        文档地址：https://prometheus.io/docs/alerting/latest/alertmanager/

        下载地址：https://prometheus.io/download/#alertmanager

        下载安装包：alertmanager-0.24.0.linux-amd64.tar.gz

        上传到服务器目录：/usr/local/software

     解压安装包，输入命令：

        cd /usr/local/software

        tar -zxvf alertmanager-0.24.0.linux-amd64.tar.gz

        mv alertmanager-0.24.0.linux-amd64 ..

        cd ..

        ln -s alertmanager-0.24.0.linux-amd64 alertmanager

### 编写告警模板

    编写邮件告警模板，输入命令：

        cd /usr/local/alertmanager

        mkdir templates

        vi templates/email.tmpl

        =>

            {{ define "email.dba.to" }}914589210@qq.com{{ end }}
            {{ define "email.dba.subject" }}数据库监控通知{{ end }}

            {{ define "email.devops.to" }}914589210@qq.com{{ end }}
            {{ define "email.devops.subject" }}服务器监控通知{{ end }}

            {{ define "email.developer.to" }}914589210@qq.com{{ end }}
            {{ define "email.developer.subject" }}服务实例监控通知{{ end }}

            {{ define "email.html" }}
              {{ if gt (len .Alerts.Firing) 0 }}
                {{ range .Alerts }}
                  监控类型：发生故障<br>
                  当前级别：{{ .Labels.level }}<br>
                  当前集群：{{ .Labels.cluster }}<br>
                  当前服务：{{ .Labels.service }}<br>
                  当前实例：{{ .Labels.instance }}<br>
                  故障名称：{{ .Labels.alertname }}<br>
                  故障详情：{{ .Annotations.summary }}<br>
                  发生时间：{{ .StartsAt.Local.Format "2006-01-02 15:04:05" }}<br>
                {{ end }}
              {{ end }}
              {{ if gt (len .Alerts.Resolved) 0 }}
                {{ range .Alerts }}
                  监控类型：恢复正常<br>
                  当前级别：{{ .Labels.level }}<br>
                  当前集群：{{ .Labels.cluster }}<br>
                  当前服务：{{ .Labels.service }}<br>
                  当前实例：{{ .Labels.instance }}<br>
                  故障名称：{{ .Labels.alertname }}<br>
                  故障详情：{{ .Annotations.summary }}<br>
                  发生时间：{{ .StartsAt.Local.Format "2006-01-02 15:04:05" }}<br>
                  恢复时间：{{ .EndsAt.Local.Format "2006-01-02 15:04:05" }}<br>
                {{ end }}
              {{ end }}
            {{ end }}

    编写企业微信告警模板，输入命令：

        cd /usr/local/alertmanager

        vi templates/wechat.tmpl

        =>

            {{ define "wechat.dba.agent.id" }}xxxxxx{{ end }}
            {{ define "wechat.dba.to.party" }}xxxxxx{{ end }}

            {{ define "wechat.devops.agent.id" }}xxxxxx{{ end }}
            {{ define "wechat.devops.to.party" }}xxxxxx{{ end }}

            {{ define "wechat.developer.agent.id" }}xxxxxx{{ end }}
            {{ define "wechat.developer.to.party" }}xxxxxx{{ end }}

            {{ define "wechat.message" }}
              {{ if gt (len .Alerts.Firing) 0 }}
                {{ range .Alerts }}
                  监控类型：发生故障
                  当前级别：{{ .Labels.level }}
                  当前集群：{{ .Labels.cluster }}
                  当前服务：{{ .Labels.service }}
                  当前实例：{{ .Labels.instance }}
                  故障名称：{{ .Labels.alertname }}
                  故障详情：{{ .Annotations.summary }}
                  发生时间：{{ .StartsAt.Local.Format "2006-01-02 15:04:05" }}
                {{ end }}
              {{ end }}
              {{ if gt (len .Alerts.Resolved) 0 }}
                {{ range .Alerts }}
                  监控类型：恢复正常
                  当前级别：{{ .Labels.level }}
                  当前集群：{{ .Labels.cluster }}
                  当前服务：{{ .Labels.service }}
                  当前实例：{{ .Labels.instance }}
                  故障名称：{{ .Labels.alertname }}
                  故障详情：{{ .Annotations.summary }}
                  发生时间：{{ .StartsAt.Local.Format "2006-01-02 15:04:05" }}
                  恢复时间：{{ .EndsAt.Local.Format "2006-01-02 15:04:05" }}
                {{ end }}
              {{ end }}
            {{ end }}

### 更改配置文件

    更改配置，输入命令：

        cd /usr/local/alertmanager

        vi alertmanager.yml

        =>

            # 全局配置
            global:
              # 未接收到告警标记则多长时间解除告警
              resolve_timeout: 5m
              # smtp邮件发送配置(根据实际配置调整)
              smtp_from: "914589210@qq.com"
              smtp_smarthost: 'smtp.qq.com:465'
              smtp_auth_username: "914589210@qq.com"
              smtp_auth_password: "auth_pass"
              smtp_require_tls: true
              # 企业微信发送配置(根据实际配置调整)
              wechat_api_url: 'https://qyapi.weixin.qq.com/cgi-bin/'
              wechat_api_secret: 'xxxxxx'
              wechat_api_corp_id: 'xxxxxx'

            # 模板配置
            templates:
              - '/usr/local/alertmanager/templates/email.tmpl'
              - '/usr/local/alertmanager/templates/wechat.tmpl'

            # 路由配置，注意，标签指的是 prometheus 配置 scrape_configs 各个 job 的 labels，根据标签的值进行分组
            route:
              # 分组标签，多个告警根据分组聚合发送
              group_by: ['cluster', 'service']
              # 分组等待时长，聚合时长内同一分组告警信息
              group_wait: 30s
              # 分组发送时间间隔
              group_interval: 5m
              # 未处理告警重复发送间隔
              repeat_interval: 30m
              # 默认告警接收人配置
              receiver: 'developer'
              # 子路由配置，可继承或覆盖路由配置
              routes:
                # 绝对匹配，发送给数据库管理员
                - match:
                    service: mysql
                  receiver: 'dba'
                # 正则匹配，发送给运维工程师
                - match_re:
                    service: nginx|prometheus|linux-server
                  receiver: 'devops'
                # 正则匹配，发送给开发工程师
                - match_re:
                    service: ^(micro|spring|application).*$
                  receiver: 'developer'

            # 告警接收人配置
            receivers:
              # 数据库管理员
              - name: dba
                # 邮件配置，注意引用了模板的值，以下同理
                email_configs:
                  - to: '{{ template "email.dba.to" . }}'
                    headers:
                      subject: '{{ template "email.dba.subject" . }}'
                    html: '{{ template "email.html" . }}'
                    send_resolved: true
                # 企业微信配置
                wechat_configs:
                  - agent_id: '{{ template "wechat.dba.agent.id" . }}'
                    to_party: '{{ template "wechat.dba.to.party" . }}'
                    message: '{{ template "wechat.message" . }}'
                    send_resolved: true
              # 运维工程师
              - name: devops
                # 邮件配置
                email_configs:
                  - to: '{{ template "email.devops.to" . }}'
                    headers:
                      subject: '{{ template "email.devops.subject" . }}'
                    html: '{{ template "email.html" . }}'
                    send_resolved: true
                # 企业微信配置
                wechat_configs:
                  - agent_id: '{{ template "wechat.devops.agent.id" . }}'
                    to_party: '{{ template "wechat.devops.to.party" . }}'
                    message: '{{ template "wechat.message" . }}'
                    send_resolved: true
              # 开发工程师
              - name: developer
                # 邮件配置
                email_configs:
                  - to: '{{ template "email.developer.to" . }}'
                    headers:
                      subject: '{{ template "email.developer.subject" . }}'
                    html: '{{ template "email.html" . }}'
                    send_resolved: true
                # 企业微信配置
                wechat_configs:
                  - agent_id: '{{ template "wechat.developer.agent.id" . }}'
                    to_party: '{{ template "wechat.developer.to.party" . }}'
                    message: '{{ template "wechat.message" . }}'
                    send_resolved: true

            # 告警抑制配置
            inhibit_rules:
              # 级别抑制，当告警 level=Urgent 时，忽略相同 cluster、service、instance 的 level=Minor 告警
              - source_match:
                  level: 'Urgent'
                target_match:
                  level: 'Minor'
                equal: ['cluster','service', 'instance']

### 启动 alertmanager

    输入命令：

        cd /usr/local/alertmanager

        nohup ./alertmanager &

    访问地址：

        http://192.168.140.132:9093/
