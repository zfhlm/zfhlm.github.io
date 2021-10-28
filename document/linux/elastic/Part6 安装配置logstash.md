
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

#### logstash 控制台输入输出

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

#### logstash filebeat输入控制台输出

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
		        remove_field => ['tags', '@timestamp', '@version']
		      }
		    }
		    output {
		      stdout {}
		    }
	
	配置 filebeat 采集 nginx 日志，投递到 logstash，可以看到输出：
		
		{
			"server" => {
				"from" => "nginx",
				"ip" => "192.168.140.192"
			},
			"message" => "192.168.140.1 - - [27/Oct/2021:02:46:14 -0400] \"GET / HTTP/1.1\" 304 0 \"-......""
		}

#### logstash kafka输入控制台输出

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
		      stdout {}
		    }

#### logstash filebeat输入elasticsearch输出

	修改配置文件，输入命令：
	
		cd /usr/local/logstash
		
		vi ./config/pipelines.yml
	
	修改以下配置内容：
		
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

#### logstash 结构化日志

	


		
		