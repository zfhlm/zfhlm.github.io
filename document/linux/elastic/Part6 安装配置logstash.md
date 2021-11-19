
# logstash

    logstash 能够动态地采集、转换和传输分散的数据，不受格式或复杂度的影响，利用 Grok 从非结构化数据中派生出结构

    logstash 资源占用比较高，一般从 kafka、filebeat、socket获取日志数据，进行深加工处理，然后输出到 elasticsearch

#### logstash 下载

    官方文档：https://www.elastic.co/guide/en/logstash/7.15/index.html

    下载地址：https://www.elastic.co/cn/downloads/past-releases#logstash

    下载安装包：logstash-7.15.1-linux-x86_64.tar.gz

    上传到服务器目录：/usr/local/software

#### logstash 安装

    下载并配置jdk1.8环境变量：

        (略)

    解压安装包，输入命令：

        cd /usr/local/software

        tar -zxvf ./logstash-7.15.1-linux-x86_64.tar.gz

        mv ./logstash-7.15.1 ../

        cd ..

        ln -s ./logstash-7.15.1 logstash

        cd ./logstash

    查看 logstash 配置文件：

        jvm.options                                #JVM相关配置

        startup.options                            #系统启动脚本配置

        log4j2.properties                          #日志输出配置

        logstash.yml                               #数据流管道配置(单管道)

        pipelines.yml                              #数据流管道配置(多管道，默认配置文件，一般在此文件进行配置)

        logstash-sample.conf                       #管道逻辑示例

    启动 logstash，输入命令：

        cd /usr/local/logstash

        # 前台进程启动
        ./bin/logstash

        # 守护进程启动
        nohup ./filebeat -e > /dev/null 2>&1 &

#### logstash 主要配置

    pipeline：

        数据流管道，logstash 运行时启动一到多个 pipeline，每个 pipeline 都有自己的 input、filter、output

    input：

        定义管道如何接收数据流，例如 beats、file、http、kafka、stdin、tcp

    filter：

        对接收的数据流进行加工处理，可以使用强大的 Grok 等功能统一日志格式

    output：

        输出数据流到指定目标，如elasticsearch

#### logstash + stdin + stdout

    修改配置文件，输入命令：

        cd /usr/local/logstash

        vi ./config/pipelines.yml

    添加以下配置内容：

        - pipeline.id: console
          pipeline.workers: 1
          config.string: |
            input {
              stdin {}
            }
            filter {
              mutate {
                remove_field => ['@version', 'host', '@timestamp']
              }
            }
            output {
              stdout {}
            }

    启动 logstash，输入命令：

        ./bin/logstash

    等待启动完成，控制台输入 hello，回车键确认，可以看到输出：

        {
            "message" => "hello"
        }

#### logstash + filebeat + elasticsearch

    修改配置文件，输入命令：

        cd /usr/local/logstash

        vi ./config/pipelines.yml

    添加以下配置内容：

        - pipeline.id: filebeat
          pipeline.workers: 1
          pipeline.batch.size: 100
          pipeline.batch.delay: 2000
          queue.type: persisted
          queue.max_bytes: 2gb
          config.string: |
            input {
              beats {
                port => 5044
              }
            }
            filter {
              mutate {
                remove_field => ['tags', '@version']
              }
            }
            output {
               elasticsearch {
                 hosts => ["192.168.140.193:9200", "192.168.140.194:9200", "192.168.140.195:9200"]
                 action => "index"
                 index => "logstash-%{+YYYY.MM.dd}"
              }
            }

#### logstash + kafka + elasticsearch

    修改配置文件，输入命令：

        cd /usr/local/logstash

        vi ./config/pipelines.yml

    添加以下配置内容：

        - pipeline.id: kafka
          pipeline.workers: 1
          pipeline.batch.size: 100
          pipeline.batch.delay: 2000
          queue.type: persisted
          queue.max_bytes: 2gb
          config.string: |
            input {
              kafka{
                group_id = "logstash"
                client_id => "logstash"
                bootstrap_servers => ["192.168.140.1:9092", "192.168.140.2:9092", "192.168.140.3:9092"]
                topics => "filebeat"
                batch_size => 5
                consumer_threads => 2
              }
            }
            output {
               elasticsearch {
                 hosts => ["192.168.140.193:9200", "192.168.140.194:9200", "192.168.140.195:9200"]
                 action => "index"
                 index => "logstash-%{+YYYY.MM.dd}"
              }
            }

#### logstash 结构化日志

    使用 filebeat 采集日志文件输出到 logstash 的日志格式：

        #普通日志
        {
            "message": "2021-10-20 11:20:03.024 INFO org.lushen.mrh.test.Application - 普通应用日志信息"
        }

        #微服务链路追踪日志
        {
            "message": "2021-10-20 11:20:03.024 INFO UserId TraceId SpanId org.lushen.mrh.test.DemoService - 微服务追踪日志信息"
        }

    使用 logstash 结构化成如下格式，并存储到 elasticsearch 索引 logstash-2021-10-20 中(使用%{+YYYY.MM.dd}有时区问题)：

        {
            "datetime": "2021-10-20 11:20:03.024",
            "level": "INFO",
            "package": "org.lushen.mrh.test.DemoService",
            "user": "UserId",
            "trace": "TraceId",
            "span": "SpanId",
            "message": "微服务追踪日志信息"
        }

    通过 ruby filter 达成以上需求，添加 logstash 配置（可以使用标准输入输出进行调试）：

        - pipeline.id: filebeat
          pipeline.workers: 1
          pipeline.batch.size: 100
          pipeline.batch.delay: 2000
          queue.type: persisted
          queue.max_bytes: 2gb
          config.string: |
            input {
              beats {
                port => 5044
              }
            }
            filter {
              ruby {
                code => "
                    message = event.get('message')
                    position = message.index(' - ')
                    if position != nil then
                        # 根据空格符截取
                        array = message[0, position].split(' ')
                        message = message[position+3, message.length]
                        if array.length == 4 then
                            date = array[0]
                            time = array[1]
                            level = array[2]
                            package = array[3]
                        elsif array.length == 7 then
                            date = array[0]
                            time = array[1]
                            level = array[2]
                            user = array[3]
                            trace = array[4]
                            span = array[5]
                            package = array[6]
                        end
                        # 添加到属性
                        if date != nil and time != nil then
                          event.set('date', date)
                          event.set('datetime', date+' '+time)
                        end
                        if level != nil then
                          event.set('level', level)
                        end
                        if package != nil then
                          event.set('package', package)
                        end
                        if message != nil then
                          event.set('message', message)
                        end
                        if user != nil then
                          event.set('user', user)
                        end
                        if trace != nil then
                          event.set('trace', trace)
                        end
                        if span != nil then
                          event.set('span', span)
                        end
                    end
                "
              }
              mutate {
                add_field => { "[@metadata][date]" => "%{[date]}" }
                remove_field => ['@version', 'host', 'date']
              }
            }
            output {
               elasticsearch {
                 hosts => ["192.168.140.193:9200", "192.168.140.194:9200", "192.168.140.195:9200"]
                 action => "index"
                 index => "logstash-%{[@metadata][date]}"
              }
            }

    使用 ruby 语法参考文档：

        https://www.ruby-lang.org/en/

        https://www.runoob.com/ruby/ruby-tutorial.html

#### logstash 自定义模板

    // 待完善
