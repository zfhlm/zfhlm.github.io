
# filebeat

    用于转发和集中日志数据的轻量级传送程序

    一般 filebeat 采集的数据进行简单过滤、增减属性字段后，再将数据传输给 kafka 或 logstash

#### filebeat 下载

    官方文档：https://www.elastic.co/guide/en/beats/filebeat/current/index.html

    下载地址：https://www.elastic.co/cn/downloads/past-releases#filebeat

    下载安装包：filebeat-7.15.1-linux-x86_64.tar.gz

    上传到服务器目录：/usr/local/software

#### filebeat 安装

    解压安装包，输入命令：

        cd /usr/local/software

        tar -zxvf ./filebeat-7.15.1-linux-x86_64.tar.gz

        mv ./filebeat-7.15.1-linux-x86_64 ../filebeat-7.15.1

        cd ..

        ln -s ./filebeat-7.15.1 filebeat

    查看 filebeat 配置文件：

        cd /usr/local/filebeat

        # 默认配置文件
        cat ./filebeat.yml

        # 所有配置项示例
        cat ./filebeat.reference.yml

    调整 filebeat 输出日志级别(error, warning, info, debug)，输入命令：

        cd /usr/local/filebeat

        vi ./filebeat.yml

        #默认级别，一般调试时使用此级别
        => logging.level: info

        #生产环境使用此级别，防止产生大量扫描日志
        => logging.level: warning

    启动 filebeat 进程，输入命令：

        #配置启动环境
        ./filebeat setup -e

        #前台方式启动filebeat
        ./filebeat -e

        #后台进程启动filebeat，不输出日志
        nohup ./filebeat > /dev/null 2>&1 &

        #后台进程启动filebeat，输出日志到filebeat.log
        nohup ./filebeat > filebeat.log &

#### filebeat 插件(可选)

    插件可以简化配置过程，将 filebeat.yml 配置信息分散到各个所属插件，启用和关闭不用再修改 filebeat.yml

    查看插件列表，输入命令：

        cd /usr/local/filebeat

        ./filebeat --help

        ./filebeat modules --help

        ./filebeat modules list

    启用指定插件，输入命令：

        ./filebeat modules enable elasticsearch kafka kibana logstash

    更改插件配置，输入命令：

        ll ./modules.d

        vi ./modules.d/elasticsearch.yml

        vi ./modules.d/kafka.yml

        vi ./modules.d/kibana.yml

        vi ./modules.d/logstash.yml

    禁用指定插件，输入命令：

        ./filebeat modules disable elasticsearch kafka kibana logstash

#### filebeat 主要配置

    filebeat.inputs：

        定位和处理输入数据，例如 Log、Stdin、Syslog、filestream

        文档地址：https://www.elastic.co/guide/en/beats/filebeat/current/configuration-filebeat-options.html

    processors：

        对输入数据进行简单处理，例如 add_fields、add_host_metadata、add_locale、add_tags、drop_event、drop_fields、timestamp、truncate_fields

        文档地址：https://www.elastic.co/guide/en/beats/filebeat/current/filtering-and-enhancing-data.html

    output.*：

        处理后的数据输出，例如 Elasticsearch、Logstash、Kafka、Console等

        文档地址：https://www.elastic.co/guide/en/beats/filebeat/current/configuring-output.html

#### filebeat 控制台输入输出

    修改配置文件，输入命令：

        cd /usr/local/filebeat

        vi ./filebeat.yml

    添加以下配置：

        filebeat.inputs:
        - type: stdin
          enabled: true
          fields_under_root: true

        output.console:
          enabled: true
          pretty: true

        processors:
        - drop_fields:
            fields: ['ecs', 'input', 'agent', 'host', 'log']
        - add_fields:
            target: server
            fields:
              ip: '192.168.140.192'
              from: 'console'

    启动 filebeat，执行命令：

        ./filebeat -e

    控制台输入 test 并回车键确认，可以看到以下输出：

        {
          "@timestamp": "2021-10-26T17:30:23.334Z",
          "@metadata": {
            "beat": "filebeat",
            "type": "_doc",
            "version": "7.15.1"
          },
          "server": {
            "ip": "192.168.140.192",
            "from": "console"
          },
          "message": "test"
        }

#### filebeat 采集文件日志输出logstash

    修改配置文件，输入命令：

        cd /usr/local/filebeat

        vi ./filebeat.yml

    添加以下配置( type 可以选择 filestream 或 log，前者优化了某些性能)：

        filebeat.inputs:
        - type: filestream
          enabled: true
          encoding: utf-8
          fields_under_root: true
          paths:
            - /usr/local/nginx/logs/*.log
          exclude_lines: ['^DEBUG', '^TRACE']
          include_lines: ['^ERROR', '^WARN', '^INFO', '.*']
          multiline:
            pattern: '^\d{4}\/\d{2}\/\d{2}'
            negate:  true
            match:   after
          ignore_older: 36h
          clean_removed: true
          close_inactive: 5m
          scan_frequency: 10s

        output.console:
          enabled: true
          pretty: true

        processors:
        - drop_fields:
            fields: ['ecs', 'input', 'agent', 'host', 'log']
        - add_fields:
            target: server
            fields:
              ip: '192.168.140.192'
              from: 'nginx'

    启动 filebeat，执行命令：

        ./filebeat -e

    使用浏览器访问 nginx，可以看到控制台输出的采集信息：

        {
          "@timestamp": "2021-10-26T23:51:47.965Z",
          "@metadata": {
            "beat": "filebeat",
            "type": "_doc",
            "version": "7.15.1"
          },
          "server": {
            "ip": "192.168.140.192",
            "from": "nginx"
          },
          "message": "2021/10/26 19:19:50 [error] ......"
        }

    更改为指向 logstash，修改以上 output 输出配置：

        output.logstash:
          enabled: true
          hosts: ["192.168.140.192:5044"]
          worker: 2

#### filebeat 采集文件日志输出elasticsearch

    修改配置文件，输入命令：

        cd /usr/local/filebeat

        vi ./filebeat.yml

    更改以下 output 输出配置：

        output.elasticsearch:
          enabled: true
          worker: 2
          protocol: http
          hosts: ["192.168.140.192:9200"]
          path: /
          username: "filebeat"
          password: "123456"
          index: "filebeat-%{[agent.version]}-%{+yyyy.MM.dd}"

#### filebeat 采集文件日志输出kafka

    修改配置文件，输入命令：

        cd /usr/local/filebeat

        vi ./filebeat.yml

    更改以下 output 输出配置（配置key、partition等信息参考官方文档）：

        output.kafka:
          enabled: true
          hosts: ["192.168.140.1:9092", "192.168.140.2:9092", "192.168.140.3:9092"]
          version: 2.2.2
          topic: '%{[fields.log_topic]}'
          fields:
            log_topic: filebeat
